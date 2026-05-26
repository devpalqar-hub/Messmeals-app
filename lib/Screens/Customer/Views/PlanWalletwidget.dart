import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class PlanWalletWidget extends StatefulWidget {
  final TextEditingController walletController;
  final TextEditingController discountController;

  final String? selectedPlanId;
  final String? selectedDeliveryPartnerId;

  final DateTime? startDate;
  final DateTime? endDate;
  

  final Function(String?) onPlanChanged;
  final Function(String?) onPartnerChanged;

  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;

  const PlanWalletWidget({
    super.key,
    required this.walletController,
    required this.discountController,
    required this.selectedPlanId,
    required this.selectedDeliveryPartnerId,
    required this.startDate,
    required this.endDate,
    required this.onPlanChanged,
    required this.onPartnerChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  State<PlanWalletWidget> createState() =>
      _PlanWalletWidgetState();
}
DateTime? selectedStartDate;
  DateTime? selectedEndDate;
class _PlanWalletWidgetState
    extends State<PlanWalletWidget> {
  final PlanController planController =
      Get.put(PlanController());

  final PartnerController partnerController =
      Get.put(PartnerController());

  

  @override
  void initState() {
    super.initState();

    planController.ensureLoaded();
    partnerController.ensureLoaded();
     selectedStartDate = widget.startDate;
    selectedEndDate = widget.endDate;
  }
  
  

  Future<void> pickDate(bool isStart) async {
    DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? (selectedStartDate ??
                  DateTime.now())
              : (selectedEndDate ??
                  DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          selectedStartDate = pickedDate;
        } else {
          selectedEndDate = pickedDate;
        }
      });

      // send to parent
      if (isStart) {
        widget.onStartDateChanged(
            pickedDate);
      } else {
        widget.onEndDateChanged(
            pickedDate);
      }
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat(
      "dd MMM yyyy",
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlanController>(
      builder: (_) {
        return GetBuilder<PartnerController>(
          builder: (_) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// Header
                  Row(
                    children: [
                      Container(
                        height: 45.h,
                        width: 45.w,
                        decoration:
                            BoxDecoration(
                          color: const Color(
                              0xffE7F4F2),
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      14.r),
                        ),
                        child: Icon(
                          Icons
                              .calendar_month_outlined,
                          color:
                              AppColors
                                  .primary,
                        ),
                      ),

                      SizedBox(
                          width: 14.w),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "Plan & Subscription",
                            style:
                                TextStyle(
                              fontSize:
                                  16.sp,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          SizedBox(
                              height:
                                  4.h),

                          const Text(
                            "Select plan and wallet details",
                            style:
                                TextStyle(
                              color: Color(
                                  0xff6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  title(
                      "Meal Plan *"),

                  SizedBox(
                      height: 5.h),

                  dropdownField(
  hint: "Select Meal Plan",
  selectedId: widget.selectedPlanId,
  ids: planController.plans
      .map((e) => e.id)
      .toList(),

  names: planController.plans
      .map((e) => e.planName)
      .toList(),

  onChanged: widget.onPlanChanged,
),

                  SizedBox(
                      height: 15.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            title(
                                "Start Date *"),

                            SizedBox(
                                height:
                                    5.h),

                            GestureDetector(
  onTap: () => pickDate(true),
  child: dateField(
    hint: selectedStartDate == null
        ? "Select Start Date"
        : formatDate(
            selectedStartDate,
          ),
  ),
)
                          ],
                        ),
                      ),

                      SizedBox(
                          width: 14.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            title(
                                "End Date *"),

                            SizedBox(
                                height:
                                    5.h),
GestureDetector(
  onTap: () => pickDate(false),
  child: dateField(
    hint: selectedEndDate == null
        ? "Select End Date"
        : formatDate(
            selectedEndDate,
          ),
  ),
)
                          ],
                        ),
                      )
                    ],
                  ),

                  SizedBox(
                      height: 15.h),

                  title(
                      "Delivery Partner"),

                  SizedBox(
                      height: 5.h),
dropdownField(
  hint: "Select Delivery Partner",
  selectedId: widget.selectedDeliveryPartnerId,

  ids: partnerController.partners
      .map(
        (e) => e.deliveryPartnerProfile?.id ?? "",
      )
      .toList(),

  names: partnerController.partners
      .map(
        (e) => e.name,
      )
      .toList(),

  onChanged: widget.onPartnerChanged,
),

                  SizedBox(
                      height: 20.h),

                  Container(
                    width:
                        double.infinity,
                    padding:
                        EdgeInsets.all(
                            18.w),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                              0xffF2F5F5),
                      borderRadius:
                          BorderRadius.circular(
                              16.r),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        title(
                            "Wallet Amount"),

                        SizedBox(
                            height:
                                5.h),

                        amountField(
                          widget
                              .walletController,
                        ),

                        SizedBox(
                            height:
                                15.h),

                        title(
                            "Discount Amount"),

                        SizedBox(
                            height:
                                5.h),

                        amountField(
                          widget
                              .discountController,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                      height: 30.h)
                ],
              ),
            );
          },
        );
      },
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
  required String? selectedId,
  required List<String> ids,
  required List<String> names,
  required Function(String?) onChanged,
}) {
  return Container(
    height: 56.h,
    padding: EdgeInsets.symmetric(
      horizontal: 14.w,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(
        14.r,
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,

        value: ids.contains(selectedId)
            ? selectedId
            : null,

        hint: Text(hint),

        items: List.generate(
          ids.length,
          (index) {
            return DropdownMenuItem<
                String>(
              value: ids[index], // stored value

              child: Text(
                names[index], // shown text
              ),
            );
          },
        ),

        onChanged: (value) {
          onChanged(value);

          setState(() {});
        },
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
      padding:
          EdgeInsets.symmetric(
              horizontal: 14.w),
      decoration:
          BoxDecoration(
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
      padding:
          EdgeInsets.symmetric(
              horizontal: 14.w),
      decoration:
          BoxDecoration(
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
          )
        ],
      ),
    );
  }
}