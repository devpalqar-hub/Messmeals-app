import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
import 'package:mess/Screens/CustomerScreen/Views/CustomerCard.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerController customerController =
      Get.put(CustomerController());
  final PlanController planController = Get.put(PlanController());

  String selectedPlan = "All Plans";
  String searchQuery = "";
/// goi
  @override
  void initState() {
    super.initState();
    customerController.fetchCustomers(refresh: true);
    planController.fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<CustomerController>(
            builder: (customerCtrl) {
              return GetBuilder<PlanController>(
                builder: (planCtrl) {
                  if (customerCtrl.isLoading||
                      planCtrl.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final customers = customerCtrl.customers;

                
                  final filteredCustomers = customers.where((c) {
                    final query = searchQuery.toLowerCase();

                    final planName = c.activeSubscriptions.isNotEmpty
                        ? c.activeSubscriptions.first.plan.name.toLowerCase()
                        : '';

                    final matchesSearch = query.isEmpty ||
                        c.name.toLowerCase().contains(query) ||
                        c.phone.toLowerCase().contains(query) ||
                        c.email.toLowerCase().contains(query) ||
                        c.address.toLowerCase().contains(query) ||
                        planName.contains(query);

                    final matchesPlan = selectedPlan == "All Plans"
                        ? true
                        : planName == selectedPlan.toLowerCase();

                    return matchesSearch && matchesPlan;
                  }).toList();

                  final planNames = [
                    "All Plans",
                    ...planCtrl.plans.map((p) => p.planName),
                  ];

                  if (!planNames.contains(selectedPlan)) {
                    selectedPlan = "All Plans";
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Customers",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AddCustomerScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.add,
                                size: 18.sp,
                                color: Colors.white),
                            label: Text(
                              "Add",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xff0474B9),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25.w,
                                  vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),
                      Text(
                        "${filteredCustomers.length} total",
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600]),
                      ),

                      SizedBox(height: 16.h),

                      Row(
                        children: [
                       
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search anything...",
                                prefixIcon:
                                    const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                      color:
                                          Colors.grey[300]!),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                      color:
                                          Colors.grey[300]!),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10.w),

                          
                          Container(
                            height: 48.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: Colors.grey[300]!),
                            ),
                            child:
                                DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedPlan,
                                items: planNames
                                    .map(
                                      (name) =>
                                          DropdownMenuItem(
                                        value: name,
                                        child: Text(name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedPlan = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      Expanded(
                        child: filteredCustomers.isEmpty
                            ? Center(
                                child: Text(
                                  "No customers found",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    customerController
                                        .fetchCustomers(
                                            refresh: true),
                                child: ListView.builder(
                                  padding:
                                      EdgeInsets.only(top: 8.h),
                                  itemCount:
                                      filteredCustomers.length,
                                  itemBuilder:
                                      (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 10.h),
                                      child: CustomerCard(
                                        customer:
                                            filteredCustomers[
                                                index],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
