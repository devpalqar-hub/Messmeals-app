import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';

Future<Map<String, dynamic>?> showRenewSubscriptionSheet(
  BuildContext context, {
  required String customerProfileId,

  /// CURRENT VALUES
  String? currentPlanId,
  String? currentPartnerId,
  String? currentStartDate,
  String? currentEndDate,
  String? currentDiscount,
}) async {
  /// FORMAT DATE FOR DISPLAY
  String formatDisplayDate(String? date) {
    if (date == null || date.isEmpty) return '';

    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(date);

      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (e) {
      return date;
    }
  }

  final startCtrl = TextEditingController(
    text: formatDisplayDate(currentStartDate),
  );

  final endCtrl = TextEditingController(
    text: formatDisplayDate(currentEndDate),
  );

  final discountCtrl = TextEditingController(
    text: currentDiscount ?? '',
  );

  final planController = Get.put(PlanController());
  final partnerController = Get.put(PartnerController());

  if (planController.plans.isEmpty) {
    planController.fetchPlans();
  }

  if (partnerController.partners.isEmpty) {
    partnerController.fetchPartners();
  }

  String? selectedPlanId = currentPlanId;
  String? selectedPartnerId = currentPartnerId;

  return await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,

    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> pickDate(
            TextEditingController target,
          ) async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              target.text = DateFormat(
                'dd/MM/yyyy',
              ).format(picked);
            }
          }

          InputDecoration fieldDecoration({
            String? hint,
            Widget? suffixIcon,
          }) {
            return InputDecoration(
              hintText: hint,

              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),

              filled: true,
              fillColor: const Color(0xffF7F7F9),

              contentPadding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 20.h,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22.r),

                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22.r),

                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22.r),
              ),

              suffixIcon: suffixIcon,
            );
          }

          Widget label(String text) {
            return Text(
              text,

              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            );
          }

          return GetBuilder<PlanController>(
            builder: (planCtrl) {
              return GetBuilder<PartnerController>(
                builder: (partnerCtrl) {
                  final plans = planCtrl.plans;
                  final partners = partnerCtrl.partners;

                  final isLoading =
                      planCtrl.isLoading ||
                          partnerCtrl.isLoading;

                  return Container(
                    padding: EdgeInsets.only(
                      left: 22.w,
                      right: 22.w,
                      top: 22.h,
                      bottom:
                          MediaQuery.of(ctx)
                                  .viewInsets
                                  .bottom +
                              24.h,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(34.r),
                      ),
                    ),

                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          /// HANDLE
                          Center(
                            child: Container(
                              width: 55.w,
                              height: 5.h,

                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,

                                borderRadius:
                                    BorderRadius.circular(20.r),
                              ),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          /// HEADER
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Renew Subscription",

                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.5,
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () => Get.back(),

                                child: Container(
                                  width: 42.w,
                                  height: 42.w,

                                  decoration: const BoxDecoration(
                                    color: Color(0xffF4F4F4),
                                    shape: BoxShape.circle,
                                  ),

                                  child: Icon(
                                    Icons.close,
                                    size: 22.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 30.h),

                          if (isLoading)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.w),

                                child:
                                    const CircularProgressIndicator(),
                              ),
                            )
                          else ...[
                            /// PLAN
                            label("Meal Plan *"),

                            SizedBox(height: 10.h),

                            DropdownButtonFormField<String>(
                              value:
                                  plans.any(
                                    (e) =>
                                        e.id ==
                                        selectedPlanId,
                                  )
                                      ? selectedPlanId
                                      : null,

                              isExpanded: true,

                              items: plans.map((plan) {
                                return DropdownMenuItem<String>(
                                  value: plan.id,

                                  child: Text(
                                    plan.planName,

                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),

                              onChanged: (v) {
                                setState(() {
                                  selectedPlanId = v;
                                });
                              },

                              decoration: fieldDecoration(
                                hint: "Select plan",

                                suffixIcon: const Icon(
                                  Icons
                                      .keyboard_arrow_down_rounded,
                                ),
                              ),

                              icon: const SizedBox.shrink(),
                            ),

                            SizedBox(height: 24.h),

                            /// DATES
                            Row(
                              children: [
                                /// START DATE
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      label("Start Date *"),

                                      SizedBox(height: 10.h),

                                      TextField(
                                        controller: startCtrl,
                                        readOnly: true,

                                        onTap: () {
                                          pickDate(startCtrl);
                                        },

                                        decoration:
                                            fieldDecoration(
                                          suffixIcon: Icon(
                                            Icons
                                                .calendar_month_outlined,

                                            size: 22.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 14.w),

                                /// END DATE
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      label("End Date *"),

                                      SizedBox(height: 10.h),

                                      TextField(
                                        controller: endCtrl,
                                        readOnly: true,

                                        onTap: () {
                                          pickDate(endCtrl);
                                        },

                                        decoration:
                                            fieldDecoration(
                                          suffixIcon: Icon(
                                            Icons
                                                .calendar_month_outlined,

                                            size: 22.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            /// DELIVERY PARTNER
                            label("Delivery Partner *"),

                            SizedBox(height: 10.h),

                            DropdownButtonFormField<String>(
                              value:
                                  partners.any(
                                    (e) =>
                                        e.id ==
                                        selectedPartnerId,
                                  )
                                      ? selectedPartnerId
                                      : null,

                              isExpanded: true,

                              items: partners.map((partner) {
                                return DropdownMenuItem<String>(
                                  value: partner.id,

                                  child: Text(
                                    partner.name,

                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),

                              onChanged: (v) {
                                setState(() {
                                  selectedPartnerId = v;
                                });
                              },

                              decoration: fieldDecoration(
                                hint: "Select partner",

                                suffixIcon: const Icon(
                                  Icons
                                      .keyboard_arrow_down_rounded,
                                ),
                              ),

                              icon: const SizedBox.shrink(),
                            ),

                            SizedBox(height: 24.h),

                            /// DISCOUNT
                            label("Discount"),

                            SizedBox(height: 10.h),

                            TextField(
                              controller: discountCtrl,

                              keyboardType:
                                  TextInputType.number,

                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),

                              decoration: fieldDecoration(
                                hint: "Discount",
                              ),
                            ),

                            SizedBox(height: 38.h),

                            /// BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 62.h,

                              child: ElevatedButton(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.black,

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      22.r,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  if (selectedPlanId ==
                                          null ||
                                      selectedPartnerId ==
                                          null ||
                                      startCtrl
                                          .text
                                          .isEmpty ||
                                      endCtrl
                                          .text
                                          .isEmpty) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Please fill all required fields",
                                    );

                                    return;
                                  }

                                  final partner =
                                      partners.firstWhere(
                                    (p) =>
                                        p.id ==
                                        selectedPartnerId,
                                  );

                                  final partnerProfileId =
                                      partner
                                          .deliveryPartnerProfile
                                          ?.id;

                                  if (partnerProfileId ==
                                          null ||
                                      partnerProfileId
                                          .isEmpty) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Invalid delivery partner profile ID",
                                    );

                                    return;
                                  }

                                  String toIso(
                                    String date,
                                  ) {
                                    final parsed =
                                        DateFormat(
                                      'dd/MM/yyyy',
                                    ).parse(date);

                                    return DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(parsed);
                                  }

                                  Navigator.pop(
                                    ctx,
                                    {
                                      "planId":
                                          selectedPlanId,

                                      "start":
                                          toIso(
                                        startCtrl.text,
                                      ),

                                      "end":
                                          toIso(
                                        endCtrl.text,
                                      ),

                                      "partnerId":
                                          partnerProfileId,

                                      "discount":
                                          discountCtrl
                                                  .text
                                                  .trim()
                                                  .isEmpty
                                              ? "0"
                                              : discountCtrl
                                                  .text
                                                  .trim(),
                                    },
                                  );
                                },

                                child: Text(
                                  "Renew Subscription",

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10.h),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}