import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<Map<String, dynamic>?> showRenewSubscriptionSheet(
  BuildContext context, {
  required String customerProfileId,
}) async {
  final startCtrl = TextEditingController();
  final endCtrl = TextEditingController();
  final discountCtrl = TextEditingController();

  final planController = Get.put(PlanController());
  final partnerController = Get.put(PartnerController());

  if (planController.plans.isEmpty) planController.fetchPlans();
  if (partnerController.partners.isEmpty) partnerController.fetchPartners();

  String? selectedPlanId;
  String? selectedPartnerId;
  bool isSubmitting = false;

  return await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> pickDate(TextEditingController target) async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: ctx,
              initialDate: now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 5),
            );
            if (picked != null) {
              target.text =
                  '${_mon(picked.month)} ${picked.day}, ${picked.year}';
            }
          }

          InputDecoration inputDec({String? hint, Widget? suffixIcon}) {
            return InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF2F3F7),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              suffixIcon: suffixIcon,
            );
          }

          const caption = TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black,
          );

          return GetBuilder<PlanController>(
            builder: (planCtrl) {
              return GetBuilder<PartnerController>(
                builder: (partnerCtrl) {
                  final plans = planCtrl.plans;
                  final partners = partnerCtrl.partners;
                  final isLoading =
                      planCtrl.isLoading || partnerCtrl.isLoading;

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 20.h,
                          bottom:
                              MediaQuery.of(ctx).viewInsets.bottom + 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Renew Subscription',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            if (isLoading)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else ...[
                              const Text('Meal Plan *', style: caption),
                              SizedBox(height: 8.h),
                              DropdownButtonFormField<String>(
                                value: selectedPlanId,
                                items: plans
                                    .map((plan) => DropdownMenuItem(
                                          value: plan.id,
                                          child: Text(plan.planName),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => selectedPlanId = v),
                                decoration: inputDec(
                                  hint: 'Select plan',
                                  suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                ),
                                icon: const SizedBox.shrink(),
                              ),

                              SizedBox(height: 16.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Start Date *',
                                            style: caption),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: startCtrl,
                                          readOnly: true,
                                          onTap: () =>
                                              pickDate(startCtrl),
                                          decoration: inputDec(
                                            suffixIcon: const Icon(
                                              Icons.calendar_today_rounded,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('End Date *',
                                            style: caption),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: endCtrl,
                                          readOnly: true,
                                          onTap: () =>
                                              pickDate(endCtrl),
                                          decoration: inputDec(
                                            suffixIcon: Icon(
                                              Icons.calendar_today_rounded,
                                              size: 18.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              const Text('Delivery Partner *',
                                  style: caption),
                              SizedBox(height: 8.h),
                              DropdownButtonFormField<String>(
                                value: selectedPartnerId,
                                items: partners
                                    .map((partner) => DropdownMenuItem(
                                          value: partner.id,
                                          child: Text(partner.name),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(
                                    () => selectedPartnerId = v),
                                decoration: inputDec(
                                  hint: 'Select partner',
                                  suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                ),
                                icon: const SizedBox.shrink(),
                              ),

                              SizedBox(height: 16.h),

                              const Text('Discount', style: caption),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: discountCtrl,
                                decoration:
                                    inputDec(hint: 'Discount'),
                                keyboardType: TextInputType.number,
                              ),

                              SizedBox(height: 20.h),

                              SizedBox(
                                width: double.infinity,
                                height: 48.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (selectedPlanId == null ||
                                        selectedPartnerId == null ||
                                        startCtrl.text.isEmpty ||
                                        endCtrl.text.isEmpty) {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Please fill all required fields');
                                      return;
                                    }

                                    final partner =
                                        partners.firstWhere((p) =>
                                            p.id ==
                                            selectedPartnerId);

                                    final partnerProfileId =
                                        partner
                                            .deliveryPartnerProfile
                                            ?.id;

                                    if (partnerProfileId == null ||
                                        partnerProfileId.isEmpty) {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Invalid delivery partner profile ID');
                                      return;
                                    }

                                    String toIso(String formattedDate) {
                                      final parts =
                                          formattedDate.split(' ');
                                      final month =
                                          _monToNum(parts[0]);
                                      final day = parts[1]
                                          .replaceAll(',', '');
                                      final year = parts[2];
                                      return "$year-$month-$day";
                                    }

                                    // ✅ RETURN DATA (NO API CALL)
                                    Navigator.pop(ctx, {
                                      "planId": selectedPlanId,
                                      "start":
                                          toIso(startCtrl.text),
                                      "end": toIso(endCtrl.text),
                                      "partnerId":
                                          partnerProfileId,
                                      "discount":
                                          discountCtrl.text
                                                  .isEmpty
                                              ? '0'
                                              : discountCtrl.text,
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Renew Subscription',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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

String _mon(int m) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[m - 1];
}

String _monToNum(String mon) {
  const map = {
    'Jan': '01',
    'Feb': '02',
    'Mar': '03',
    'Apr': '04',
    'May': '05',
    'Jun': '06',
    'Jul': '07',
    'Aug': '08',
    'Sep': '09',
    'Oct': '10',
    'Nov': '11',
    'Dec': '12',
  };
  return map[mon] ?? '01';
}