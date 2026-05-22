import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class PlanWalletWidget extends StatefulWidget {
  const PlanWalletWidget({super.key});

  @override
  State<PlanWalletWidget> createState() =>
      _PlanWalletWidgetState();
}

class _PlanWalletWidgetState
    extends State<PlanWalletWidget> {
  String? mealPlan;
  String? deliveryPartner;

  final TextEditingController walletController =
      TextEditingController(text: "0.00");

  final TextEditingController discountController =
      TextEditingController(text: "0.00");

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [
              Container(
                height: 45.h,
                width: 45.w,
                decoration: BoxDecoration(
                  color: const Color(0xffE7F4F2),
                  borderRadius:
                      BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Plan & Subscription",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    "Select plan and wallet details",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(
                          0xff6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 24.h),

          title("Meal Plan *"),

          SizedBox(height: 5.h),

          dropdownField(
            hint: "Select Meal Plan",
            icon:
                Icons.restaurant_menu_outlined,
            value: mealPlan,
            items: const [
              "Basic Plan",
              "Premium Plan",
              "Monthly Plan",
            ],
            onChanged: (v) {
              setState(() {
                mealPlan = v;
              });
            },
          ),

          SizedBox(height: 15.h),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    title("Start Date *"),
                    SizedBox(height: 5.h),
                    dateField(
                      hint:
                          "Select start date",
                    ),
                  ],
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    title("End Date *"),
                    SizedBox(height: 5.h),
                    dateField(
                      hint:
                          "Select end date",
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          title("Delivery Partner"),

          SizedBox(height: 5.h),

          dropdownField(
            hint:
                "Select Delivery Partner",
            icon: Icons.person_outline,
            value: deliveryPartner,
            items: const [
              "Rahul Delivery",
              "Fast Delivery",
            ],
            onChanged: (v) {
              setState(() {
                deliveryPartner = v;
              });
            },
          ),

          SizedBox(height: 20.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: const Color(
                  0xffF2F5F5),
              borderRadius:
                  BorderRadius.circular(
                      16.r),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                title("Wallet Amount"),

                SizedBox(height: 5.h),

                amountField(
                    walletController),

                SizedBox(height: 15.h),

                title(
                  "Discount Amount",
                ),

                SizedBox(height: 5.h),

                amountField(
                    discountController),
              ],
            ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget title(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }

  Widget dropdownField({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?)
        onChanged,
  }) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(
          horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                14.r),
      ),
      child:
          DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: items
              .map(
                (e) =>
                    DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget dateField({
    required String hint,
  }) {
    return Container(
      height: 56.h,
      alignment:
          Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
          horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                14.r),
      ),
      child: Text(hint),
    );
  }

  Widget amountField(
      TextEditingController
          controller) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(
          horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                14.r),
      ),
      child: Row(
        children: [
          const Text("₹"),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller:
                  controller,
              decoration:
                  const InputDecoration(
                border:
                    InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}