import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/Customer/Views/customer_card.dart';
import 'package:mess/Screens/Customer/Views/customer_summary_card.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppTourController.dart';
import 'package:mess/Screens/Utils/EmptyStateAddButton.dart';
import 'package:mess/Screens/Utils/TourKeys.dart';
import 'package:mess/Screens/Utils/TourStop.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerController customerController = Get.put(CustomerController());

  final PlanController planController = Get.put(PlanController());

  final TextEditingController searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String selectedPlanId = "";
  String searchQuery = "";
  String selectedSubscriptionFilter = "";

  @override
  void initState() {
    super.initState();

    planController.fetchPlans();
    customerController.fetchCustomers(refresh: true);
    customerController.fetchCustomerSummary();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final nearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearBottom &&
        customerController.hasMore &&
        !customerController.isLoading &&
        !customerController.isMoreLoading) {
      _loadCustomers(reset: false);
    }
  }

  void _loadCustomers({bool reset = true}) {
    customerController.fetchCustomers(
      refresh: reset,
      search: searchQuery.isEmpty ? null : searchQuery,
      planId: selectedPlanId.isEmpty ? null : selectedPlanId,
      subscriptionFilter:
          selectedSubscriptionFilter.isEmpty
              ? null
              : selectedSubscriptionFilter,
    );
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _openAddCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    );
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

                  GetBuilder<CustomerController>(
                    builder:
                        (c) => tourStop(
                          context,
                          key: TourKeys.customersAdd,
                          tourId: AppTourController.customersTour,
                          step: 1,
                          total: c.customers.isNotEmpty ? 3 : 2,
                          title: 'Tap here to add a Customer',
                          description:
                              'Enter their details, pick a plan and delivery schedule, and top up their wallet.',
                          child: GestureDetector(
                            onTap: _openAddCustomer,
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
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
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
                        ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              /// ================= SUMMARY CARD =================
              GetBuilder<CustomerController>(
                builder: (controller) {
                  return CustomerSummaryCard(
                    summary: controller.summary,
                    isLoading: controller.isSummaryLoading,
                  );
                },
              ),

              SizedBox(height: 16.h),

              /// ================= SEARCH + FILTER =================
              Row(
                children: [
                  /// SEARCH
                  Expanded(
                    child: GetBuilder<CustomerController>(
                      builder:
                          (c) => tourStop(
                            context,
                            key: TourKeys.customersSearch,
                            tourId: AppTourController.customersTour,
                            step: 2,
                            total: c.customers.isNotEmpty ? 3 : 2,
                            title: 'Tap here to find a Customer',
                            description:
                                'Search by name, phone or email — the list filters as you type.',
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
                                        hintText:
                                            "Search by name, phone or email",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

              SizedBox(height: 10.h),

              /// ================= SUBSCRIPTION FILTER =================
              Row(
                children: [
                  _subscriptionFilterChip(
                    label: "All Customers",
                    selected: selectedSubscriptionFilter.isEmpty,
                    onTap: () {
                      setState(() => selectedSubscriptionFilter = "");
                      _loadCustomers(reset: true);
                    },
                  ),
                  SizedBox(width: 8.w),
                  _subscriptionFilterChip(
                    label: "Ending in 7 Days",
                    selected: selectedSubscriptionFilter == "ending_soon",
                    onTap: () {
                      setState(
                        () => selectedSubscriptionFilter = "ending_soon",
                      );
                      _loadCustomers(reset: true);
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              /// ================= CUSTOMER LIST =================
              Expanded(
                child: GetBuilder<CustomerController>(
                  builder: (controller) {
                    if (controller.isLoading && controller.customers.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Customers walkthrough — only runs when the owner tapped
                    // this tab from the tour prompt, not on every open. Starts
                    // once the list has loaded, so we know if there's a card.
                    if (!controller.isLoading && !controller.isSummaryLoading) {
                      AppTourController.instance.startIfRequested(
                        context,
                        AppTourController.customersTour,
                        [
                          TourKeys.customersAdd,
                          TourKeys.customersSearch,
                          if (controller.customers.isNotEmpty)
                            TourKeys.customersCard,
                        ],
                      );
                    }

                    if (controller.customers.isEmpty) {
                      return EmptyStateAddButton(
                        icon: Icons.group_outlined,
                        title: "No customers yet",
                        subtitle: "Add your first customer to get started",
                        buttonLabel: "Add Customer",
                        onAdd: _openAddCustomer,
                      );
                    }

                    final showLoadingFooter = controller.isMoreLoading;
                    final itemCount =
                        controller.customers.length +
                        (showLoadingFooter ? 1 : 0);

                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: itemCount,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        if (index >= controller.customers.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: const Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            ),
                          );
                        }

                        final customer = controller.customers[index];

                        return tourStop(
                          context,
                          key: TourKeys.customersCard,
                          tourId: AppTourController.customersTour,
                          step: 3,
                          total: 3,
                          title: 'Tap a Customer to open their details',
                          description:
                              'See their wallet, subscriptions and history — and top up, pause, renew or cancel a plan.',
                          // Only the first card carries the tour stop.
                          enabled: index == 0,
                          child: CustomerCard(
                            name: customer.name,
                            phone: customer.phone,
                            initials:
                                customer.name.isNotEmpty
                                    ? customer.name[0].toUpperCase()
                                    : "",
                            customer: customer,
                          ),
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

  Widget _subscriptionFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primaryDark : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
