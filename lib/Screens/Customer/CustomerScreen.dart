import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/Customer/Views/customer_card.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerController customerController = Get.put(CustomerController());

  final PlanController planController = Get.put(PlanController());

  final TextEditingController searchCtrl = TextEditingController();

  String selectedPlanId = "";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    planController.fetchPlans();
    customerController.fetchCustomers(refresh: true);
  }

  void _loadCustomers({bool reset = true}) {
    customerController.fetchCustomers(
      refresh: reset,
      search: searchQuery.isEmpty ? null : searchQuery,
      planId: selectedPlanId.isEmpty ? null : selectedPlanId,
    );
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 18.h),

              /// ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customers",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "Customer List",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddCustomerScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18.sp),
                          SizedBox(width: 5.w),
                          Text(
                            "Add Customer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              /// ================= SEARCH + FILTER =================
              Row(
                children: [
                  /// SEARCH
                  Expanded(
                    child: Container(
                      height: 45.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: searchCtrl,
                              onChanged: (value) {
                                searchQuery = value;
                                _loadCustomers(reset: true);
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search by name, phone or email",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  /// PLAN DROPDOWN
                  GetBuilder<PlanController>(
                    builder: (controller) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                selectedPlanId.isEmpty ? null : selectedPlanId,
                            hint: const Text("All Plans"),

                            items: [
                              const DropdownMenuItem(
                                value: "",
                                child: Text("All Plans"),
                              ),
                              ...controller.plans.map((plan) {
                                return DropdownMenuItem(
                                  value: plan.id,
                                  child: Text(plan.planName),
                                );
                              }),
                            ],

                            onChanged: (value) {
                              setState(() {
                                selectedPlanId = value ?? "";
                              });

                              _loadCustomers(reset: true);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              /// ================= CUSTOMER LIST =================
              Expanded(
                child: GetBuilder<CustomerController>(
                  builder: (controller) {
                    if (controller.isLoading && controller.customers.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.customers.isEmpty) {
                      return const Center(child: Text("No customers found"));
                    }

                    return ListView.separated(
                      itemCount: controller.customers.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final customer = controller.customers[index];

                        return CustomerCard(
                          name: customer.name,
                          phone: customer.phone,
                          initials:
                              customer.name.isNotEmpty
                                  ? customer.name[0].toUpperCase()
                                  : "",
                          customer: customer,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
