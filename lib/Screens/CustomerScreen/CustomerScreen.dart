import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
import 'package:mess/Screens/CustomerScreen/Views/CustomerCard.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart'; // ✅ import PlanController

class CustomersScreen extends StatelessWidget {
  CustomersScreen({super.key});

  final CustomerController customerController = Get.put(CustomerController());
  final PlanController planController = Get.put(PlanController());

  final RxString selectedPlan = "All Plans".obs;
  final RxString searchQuery = "".obs;

  @override
  Widget build(BuildContext context) {
    // Fetch initial customers and plans
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
            final plans = planController.plans;

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
                        padding:
                            EdgeInsets.symmetric(horizontal: 25.w, vertical: 1.h),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
                Text(
                  "${customers.length} total",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 16.h),

                /// ---------- SEARCH + PLAN FILTER ----------
                Row(
                  children: [
                    /// 🔍 Search Field
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search customers by plan...",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onChanged: (value) async {
                          searchQuery.value = value;
                          await customerController.fetchCustomers(
                            refresh: true,
                            planName: selectedPlan.value == "All Plans"
                                ? value
                                : selectedPlan.value,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),

                    /// 🔽 Plan Dropdown
                    Obx(
                      () => Container(
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
                            items: [
                              const DropdownMenuItem(
                                value: "All Plans",
                                child: Text("All Plans"),
                              ),
                              ...plans.map(
                                (plan) => DropdownMenuItem(
                                  value: plan.planName,
                                  child: Text(plan.planName),
                                ),
                              ),
                            ],
                            onChanged: (value) async {
                              if (value != null) {
                                selectedPlan.value = value;

                                await customerController.fetchCustomers(
                                  refresh: true,
                                  planName: value == "All Plans" ? "" : value,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                /// ---------- CUSTOMER LIST ----------
                Expanded(
                  child: Obx(() {
                    if (customerController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final customers = customerController.customers;
                    if (customers.isEmpty) {
                      return const Center(child: Text("No customers found"));
                    }

                    return RefreshIndicator(
                      onRefresh: () => customerController.fetchCustomers(
                        refresh: true,
                        planName: selectedPlan.value == "All Plans"
                            ? ""
                            : selectedPlan.value,
                      ),
                      child: ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
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
