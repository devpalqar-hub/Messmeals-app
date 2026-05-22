import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Customer/ScheduleDelivery.dart';

class Step2PlanWallet extends StatefulWidget {
  const Step2PlanWallet({super.key});

  @override
  State<Step2PlanWallet> createState() => _Step2PlanWalletState();
}

class _Step2PlanWalletState extends State<Step2PlanWallet> {
  final Color primary = const Color(0xff0B8A7B);

  String? mealPlan;
  String? deliveryPartner;

  final TextEditingController walletController =
      TextEditingController(text: "0.00");

  final TextEditingController discountController =
      TextEditingController(text: "0.00");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),

              /// TOP BAR
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24.sp,
                      color: Colors.black,
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        "Add Customer",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff111827),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 24.w),
                ],
              ),

              SizedBox(height: 28.h),

              /// STEP INDICATOR
              Row(
                children: [
                  buildCompletedStep(
                    number: "1",
                    title: "Basic Info",
                  ),

                  buildLine(active: true),

                  buildActiveStep(
                    number: "2",
                    title: "Plan & Wallet",
                  ),

                  buildLine(),

                  buildStep(
                    number: "3",
                    title: "Schedule",
                  ),

                  buildLine(),

                  buildStep(
                    number: "4",
                    title: "Review",
                  ),
                ],
              ),

              SizedBox(height: 34.h),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      /// PLAN CARD HEADER
                      Row(
                        children: [
                          Container(
                            height: 52.h,
                            width: 52.h,
                            decoration: BoxDecoration(
                              color: const Color(0xffE7F4F2),
                              borderRadius:
                                  BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              color: primary,
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
                                  fontSize: 20.sp,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      const Color(0xff111827),
                                ),
                              ),

                              SizedBox(height: 4.h),

                              Text(
                                "Select plan and wallet details",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color:
                                      const Color(0xff6B7280),
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30.h),

                      /// MEAL PLAN
                      title("Meal Plan *"),

                      SizedBox(height: 10.h),

                      dropdownField(
                        hint: "Select Meal Plan",
                        icon: Icons.restaurant_menu_outlined,
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

                      SizedBox(height: 22.h),

                      /// DATES
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                title("Start Date *"),

                                SizedBox(height: 10.h),

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
                                  CrossAxisAlignment.start,
                              children: [
                                title("End Date *"),

                                SizedBox(height: 10.h),

                                dateField(
                                  hint:
                                      "Select end date",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 22.h),

                      /// DELIVERY PARTNER
                      title("Delivery Partner"),

                      SizedBox(height: 10.h),

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

                      SizedBox(height: 26.h),

                      /// WALLET CARD
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: const Color(0xffF2F5F5),
                          borderRadius:
                              BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            /// HEADER
                            Row(
                              children: [
                                Container(
                                  height: 44.h,
                                  width: 44.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(
                                            12.r),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: primary,
                                    size: 22.sp,
                                  ),
                                ),

                                SizedBox(width: 12.w),

                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      "Wallet & Discount",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        color:
                                            const Color(
                                                0xff111827),
                                      ),
                                    ),

                                    SizedBox(
                                        height: 3.h),

                                    Text(
                                      "Set wallet amount and discount (if any)",
                                      style:
                                          TextStyle(
                                        fontSize:
                                            13.sp,
                                        color:
                                            const Color(
                                                0xff6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            /// WALLET
                            title("Wallet Amount"),

                            SizedBox(height: 10.h),

                            amountField(
                              controller:
                                  walletController,
                            ),

                            SizedBox(height: 20.h),

                            /// DISCOUNT
                            title(
                              "Discount Amount (Optional)",
                            ),

                            SizedBox(height: 10.h),

                            amountField(
                              controller:
                                  discountController,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),

              /// CONTINUE BUTTON
              Container(
                width: double.infinity,
                height: 58.h,
                margin: EdgeInsets.only(bottom: 14.h),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () {
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(    
                        builder: (context) =>
                            const Step3ScheduleDelivery(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TITLE
  Widget title(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xff111827),
      ),
    );
  }

  /// STEP LINE
  Widget buildLine({bool active = false}) {
    return Expanded(
      child: Container(
        height: 1.5,
        color: active
            ? primary
            : const Color(0xffD1D5DB),
      ),
    );
  }

  /// ACTIVE STEP
  Widget buildActiveStep({
    required String number,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          height: 34.h,
          width: 34.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ],
    );
  }

  /// COMPLETED STEP
  Widget buildCompletedStep({
    required String number,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          height: 34.h,
          width: 34.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xffE7F4F2),
            border: Border.all(color: primary),
          ),
          child: Icon(
            Icons.check,
            color: primary,
            size: 18.sp,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xff374151),
          ),
        ),
      ],
    );
  }

  /// NORMAL STEP
  Widget buildStep({
    required String number,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          height: 34.h,
          width: 34.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: const Color(0xffD1D5DB),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: const Color(0xff374151),
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff6B7280),
          ),
        ),
      ],
    );
  }

  /// DROPDOWN FIELD
  Widget dropdownField({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xff6B7280),
          ),
          hint: Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: const Color(0xff6B7280),
              ),

              SizedBox(width: 12.w),

              Text(
                hint,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xff6B7280),
                ),
              ),
            ],
          ),
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: TextStyle(fontSize: 14.sp),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// DATE FIELD
  Widget dateField({
    required String hint,
  }) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18.sp,
            color: const Color(0xff6B7280),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xff6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AMOUNT FIELD
  Widget amountField({
    required TextEditingController controller,
  }) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Text(
            "₹",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff374151),
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xff6B7280),
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xff374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}