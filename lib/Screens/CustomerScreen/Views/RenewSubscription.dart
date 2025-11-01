import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';

Future<Map<String, dynamic>?> showRenewSubscriptionSheet(
  BuildContext context, {
  required String customerProfileId, // ✅ pass from CustomerDetailsScreen
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
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
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

          return Obx(() {
            final plans = planController.plans;
            final partners = partnerController.partners;
            final isLoading = planController.isLoading.value ||
                partnerController.isLoading.value;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Renew Subscription',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
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
                      const SizedBox(height: 10),

                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        const Text('Meal Plan *', style: caption),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedPlanId,
                          items: plans
                              .map((plan) => DropdownMenuItem(
                                    value: plan.id,
                                    child: Text(plan.planName),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => selectedPlanId = v),
                          decoration: inputDec(
                            hint: 'Select plan',
                            suffixIcon: const Icon(
                                Icons.keyboard_arrow_down_rounded),
                          ),
                          icon: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Start Date *', style: caption),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: startCtrl,
                                    readOnly: true,
                                    onTap: () => pickDate(startCtrl),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('End Date *', style: caption),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: endCtrl,
                                    readOnly: true,
                                    onTap: () => pickDate(endCtrl),
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
                          ],
                        ),
                        const SizedBox(height: 16),

                        const Text('Delivery Partner *', style: caption),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedPartnerId,
                          items: partners
                              .map((partner) => DropdownMenuItem(
                                    value: partner.id,
                                    child: Text(partner.name),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => selectedPartnerId = v),
                          decoration: inputDec(
                            hint: 'Select partner',
                            suffixIcon: const Icon(
                                Icons.keyboard_arrow_down_rounded),
                          ),
                          icon: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),

                        const Text('Discount', style: caption),
                        const SizedBox(height: 8),
                        TextField(
                          controller: discountCtrl,
                          decoration: inputDec(hint: 'Discount'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedPlanId == null ||
                                  selectedPartnerId == null ||
                                  startCtrl.text.isEmpty ||
                                  endCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please fill all required fields')),
                                );
                                return;
                              }

                              final plan = plans.firstWhere(
                                  (p) => p.id == selectedPlanId);
                              final partner = partners.firstWhere(
                                  (p) => p.id == selectedPartnerId);

                              final partnerProfileId =
                                  partner.deliveryPartnerProfile?.id;
                              if (partnerProfileId == null ||
                                  partnerProfileId.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Invalid delivery partner profile ID')),
                                );
                                return;
                              }

                              setState(() => isSubmitting = true);

                              String _toIso(String formattedDate) {
                                final parts = formattedDate.split(' ');
                                final month = _monToNum(parts[0]);
                                final day =
                                    parts[1].replaceAll(',', '');
                                final year = parts[2];
                                return "$year-$month-$day";
                              }

                              final controller =
                                  Get.put(CustomerController());
                              final success = await controller.renewSubscription(
                                planId: plan.id,
                                startDate: _toIso(startCtrl.text),
                                endDate: _toIso(endCtrl.text),
                                deliveryPartnerId: partnerProfileId,
                                discount: discountCtrl.text.isEmpty
                                    ? '0'
                                    : discountCtrl.text,
                                customerProfileId: customerProfileId, // ✅ direct
                              );

                              setState(() => isSubmitting = false);

                              if (success) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Subscription renewed successfully!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Internal server error, please try again.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D6EBA),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Renew Subscription',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),

                if (isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
              ],
            );
          });
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
