import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/Customer/Views/Basicinfowiget.dart';
import 'package:mess/Screens/Customer/Views/PlanWalletwidget.dart';
import 'package:mess/Screens/Customer/Views/Reviewwidget.dart';
import 'package:mess/Screens/Customer/Views/ScheduleDelivery.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/Utils/AppBar.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/step.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {

  final CustomerController customerController =
      Get.put(CustomerController());

  final PlanController planController =
      Get.put(PlanController());

  final PartnerController partnerController =
      Get.put(PartnerController());

  /// STEP
  int currentStep = 1;

  /// BASIC INFO
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  /// PLAN & WALLET
  String? selectedPlanId;
  String? selectedDeliveryPartnerId;

  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController walletController =
      TextEditingController(text: "0");

  final TextEditingController discountController =
      TextEditingController(text: "0");

  /// SCHEDULE
  String? deliveryType;
  String? preferredTime;

  List<String> selectedDays = [];

  /// SAFE PLAN NAME (UI ONLY)
  String get selectedPlanName {
    try {
      return planController.plans
          .firstWhere((e) => e.id == selectedPlanId)
          .planName;
    } catch (_) {
      return "";
    }
  }
  String get selectedPartnerName {
  try {
    final partner = partnerController.partners.firstWhere(
      (e) =>
          e.deliveryPartnerProfile?.id ==
          selectedDeliveryPartnerId,
    );

    return partner.name;
  } catch (_) {
    return "-";
  }
}

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    locationController.dispose();
    walletController.dispose();
    discountController.dispose();
    super.dispose();
  }

  Future<void> submitCustomer() async {
    bool success = await customerController.addCustomer(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      location: locationController.text.trim(),

      planId: selectedPlanId ?? "",
      deliveryPartnerId: selectedDeliveryPartnerId ?? "",

      startDate: startDate?.toIso8601String() ?? "",
      endDate: endDate?.toIso8601String() ?? "",

      walletAmount: walletController.text.trim(),
      discountAmount: discountController.text.trim(),

      deliveryType: deliveryType ?? "",
      preferredTime: preferredTime ?? "",
      deliveryDays: selectedDays,
    );

    if (success) {
      Get.back();
    }
  }

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

              const CustomAppBar(title: "Add Customer"),

              SizedBox(height: 28.h),

              /// STEP INDICATOR
              Row(
                children: [
                  StepWidget(number: "1", title: "Basic Info", active: currentStep >= 1),
                  StepLine(active: currentStep > 1),
                  StepWidget(number: "2", title: "Plan & Wallet", active: currentStep >= 2),
                  StepLine(active: currentStep > 2),
                  StepWidget(number: "3", title: "Schedule", active: currentStep >= 3),
                  StepLine(active: currentStep > 3),
                  StepWidget(number: "4", title: "Review", active: currentStep >= 4),
                ],
              ),

              SizedBox(height: 30.h),

              Expanded(
                child: IndexedStack(
                  index: currentStep - 1,
                  children: [

                    BasicInfoWidget(
                      nameController: nameController,
                      phoneController: phoneController,
                      emailController: emailController,
                      addressController: addressController,
                      locationController: locationController,
                    ),

                    PlanWalletWidget(
                      walletController: walletController,
                      discountController: discountController,
                      selectedPlanId: selectedPlanId,
                      selectedDeliveryPartnerId: selectedDeliveryPartnerId,
                      startDate: startDate,
                      endDate: endDate,

                      onPlanChanged: (v) => setState(() => selectedPlanId = v),
                      onPartnerChanged: (v) => setState(() => selectedDeliveryPartnerId = v),
                      onStartDateChanged: (d) => setState(() => startDate = d),
                      onEndDateChanged: (d) => setState(() => endDate = d),
                    ),

                    ScheduleDeliveryWidget(
                      selectedDays: selectedDays,
                      deliveryType: deliveryType,
                      preferredTime: preferredTime,

                      onTypeChanged: (v) => setState(() => deliveryType = v),
                      onTimeChanged: (v) => setState(() => preferredTime = v),
                      onDaysChanged: (d) => setState(() => selectedDays = d),
                    ),

                    ReviewWidget(
                      name: nameController.text,
                      phone: phoneController.text,
                      email: emailController.text,
                      address: addressController.text,
                      location: locationController.text,

                      mealPlan: selectedPlanName, 
                      startDate: startDate?.toString() ?? "",
                      endDate: endDate?.toString() ?? "",
                      deliveryPartner: selectedPartnerName, 
                      

                      walletAmount: walletController.text,
                      discountAmount: discountController.text,

                      deliveryType: deliveryType ?? "",
                      deliveryDays: selectedDays,
                      preferredTime: preferredTime ?? "",
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                height: 50.h,
                margin: EdgeInsets.only(bottom: 14.h),

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),

                  onPressed: () async {
                    if (currentStep < 4) {
                      setState(() => currentStep++);
                    } else {
                      await submitCustomer();
                    }
                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentStep == 4 ? "Add Customer" : "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        currentStep == 4
                            ? Icons.check
                            : Icons.arrow_forward,
                        color: Colors.white,
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
}