import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
import 'package:mess/Screens/CustomerScreen/Views/CustomerCard.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';

class CustomersScreen extends StatelessWidget {
  CustomersScreen({super.key});

  final CustomerController customerController = Get.put(CustomerController());
  final PlanController planController = Get.put(PlanController());

  final RxString selectedPlan = "All Plans".obs;
  final RxString searchQuery = "".obs;

  @override
  Widget build(BuildContext context) {
    // Fetch initial data
    customerController.fetchCustomers(refresh: true);
    planController.fetchPlans();

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Obx(() {
            if (customerController.isLoading.value ||
                planController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final customers = customerController.customers;

            // 🔍 Filter customers by search (any field) + plan
          final filteredCustomers = customers.where((c) {
  final query = searchQuery.value.toLowerCase();

  // ✅ Safely extract plan name (if exists)
  final planName = c.activeSubscriptions.isNotEmpty
      ? c.activeSubscriptions.first.plan.name.toLowerCase()
      : '';

  // ✅ Match search text against multiple fields
  final matchesSearch = query.isEmpty ||
      c.name.toLowerCase().contains(query) ||
      c.phone.toLowerCase().contains(query) ||
      c.email.toLowerCase().contains(query) ||
      c.address.toLowerCase().contains(query) ||
      planName.contains(query);

  // ✅ Match selected plan filter
  final matchesPlan = selectedPlan.value == "All Plans"
      ? true
      : planName == selectedPlan.value.toLowerCase();

  return matchesSearch && matchesPlan;
}).toList();


            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- HEADER ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Customers",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddCustomerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0474B9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.w, vertical: 1.h),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
                Text(
                  "${filteredCustomers.length} total",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 16.h),

                /// ---------- SEARCH + PLAN FILTER ----------
                Row(
                  children: [
                    /// 🔍 Search Field (any type)
                   Expanded(
  child: TextField(
    onChanged: (value) => searchQuery.value = value,
    decoration: InputDecoration(
      hintText: "Search anything...",
      prefixIcon: const Icon(Icons.search, size: 20),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
      ),
    ),
  ),
),

                    SizedBox(width: 10.w),

                    /// 🔽 Plan Dropdown
                    Obx(() {
                      final planNames = [
                        "All Plans",
                        ...planController.plans.map((p) => p.planName).toList()
                      ];

                      if (!planNames.contains(selectedPlan.value)) {
                        selectedPlan.value = "All Plans";
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPlan.value,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey),
                            items: planNames
                                .map(
                                  (name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedPlan.value = value;
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                SizedBox(height: 16.h),

                /// ---------- CUSTOMER LIST ----------
                Expanded(
                  child: Obx(() {
                    if (customerController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (filteredCustomers.isEmpty) {
                      return const Center(child: Text("No customers found"));
                    }

                    return RefreshIndicator(
                      onRefresh: () => customerController.fetchCustomers(
                        refresh: true,
                      ),
                      child: ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return CustomerCard(customer: customer);
                        },
                      ),
                    );
                  }),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
