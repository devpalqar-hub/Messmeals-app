import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/Customer/Views/Basicinfowiget.dart';
import 'package:mess/Screens/Customer/Views/PlanSchedule.dart';
import 'package:mess/Screens/Customer/Views/Reviewwidget.dart';
import 'package:mess/Screens/Customer/Views/WalletWidget.dart';
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
  final CustomerController customerController = Get.put(CustomerController());
  final PlanController planController = Get.put(PlanController());
  final PartnerController partnerController = Get.put(PartnerController());

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

  final TextEditingController walletController = TextEditingController(
    text: "0",
  );
  final TextEditingController discountController = TextEditingController(
    text: "0",
  );

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
        (e) => e.deliveryPartnerProfile?.id == selectedDeliveryPartnerId,
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

  // =====================================================================
  // BUG #2406 / #2408 — Validate each step before proceeding
  // =====================================================================
  bool _validateCurrentStep() {
    switch (currentStep) {
      case 1:
        // Basic Info: name, phone, address are required
        if (nameController.text.trim().isEmpty) {
          _showError("Please enter the customer name");
          return false;
        }
        final phone = phoneController.text.trim();
        if (phone.isEmpty) {
          _showError("Please enter the phone number");
          return false;
        }
        // BUG #2409 — basic phone format validation (10 digits)
        if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
          _showError("Please enter a valid 10-digit phone number");
          return false;
        }
        if (addressController.text.trim().isEmpty) {
          _showError("Please enter the address");
          return false;
        }
        return true;

      case 2:
        // Plan & Schedule: plan, dates, delivery type required
        if (selectedPlanId == null || selectedPlanId!.isEmpty) {
          _showError("Please select a meal plan");
          return false;
        }
        if (startDate == null) {
          _showError("Please select a start date");
          return false;
        }
        if (endDate == null) {
          _showError("Please select an end date");
          return false;
        }
        // BUG #2425 — end date must be after start date
        if (endDate!.isBefore(startDate!) ||
            endDate!.isAtSameMomentAs(startDate!)) {
          _showError("End date must be after the start date");
          return false;
        }
        if (deliveryType == null || deliveryType!.isEmpty) {
          _showError("Please select a delivery type");
          return false;
        }
        return true;

      case 3:
        // Wallet — no mandatory fields, always valid
        return true;

      case 4:
        // Review step — all already validated
        return true;

      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
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
      CustomerController ctrl = Get.find();
      ctrl.fetchCustomers(refresh: true);
      Get.back();
    }
  }

  // =====================================================================
  // BUG #2407 — Back button goes to previous step, not home
  // =====================================================================
  Future<bool> _onWillPop() async {
    if (currentStep > 1) {
      setState(() => currentStep--);
      return false; // Don't pop the route
    }
    return true; // Allow pop on step 1 (go back to CustomerScreen)
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),

                // =====================================================================
                // BUG #2407 — Custom back button that respects step navigation
                // =====================================================================
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentStep > 1) {
                          setState(() => currentStep--);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Add Customer",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 34.w), // Balance the back button
                  ],
                ),

                SizedBox(height: 28.h),

                /// STEP INDICATOR
                Row(
                  children: [
                    StepWidget(
                      number: "1",
                      title: "Basic Info",
                      active: currentStep >= 1,
                    ),
                    StepLine(active: currentStep > 1),
                    StepWidget(
                      number: "2",
                      title: "Plan & Wallet",
                      active: currentStep >= 2,
                    ),
                    StepLine(active: currentStep > 2),
                    StepWidget(
                      number: "3",
                      title: "Schedule",
                      active: currentStep >= 3,
                    ),
                    StepLine(active: currentStep > 3),
                    StepWidget(
                      number: "4",
                      title: "Review",
                      active: currentStep >= 4,
                    ),
                  ],
                ),

                SizedBox(height: 30.h),

                Expanded(
                  child: IndexedStack(
                    index: currentStep - 1,
                    children: [
                      // BUG #2408 — required fields marked with * in BasicInfoWidget
                      BasicInfoWidget(
                        nameController: nameController,
                        phoneController: phoneController,
                        emailController: emailController,
                        addressController: addressController,
                        locationController: locationController,
                      ),

                      PlanScheduleWidget(
                        selectedPlanId: selectedPlanId,
                        selectedDeliveryPartnerId: selectedDeliveryPartnerId,
                        startDate: startDate,
                        endDate: endDate,
                        onPlanChanged:
                            (v) => setState(() => selectedPlanId = v),
                        onPartnerChanged:
                            (v) =>
                                setState(() => selectedDeliveryPartnerId = v),
                        onStartDateChanged:
                            (d) => setState(() => startDate = d),
                        // BUG #2425 — only allow end dates after start date
                        onEndDateChanged: (d) {
                          if (startDate != null && d.isBefore(startDate!)) {
                            _showError("End date cannot be before start date");
                            return;
                          }
                          setState(() => endDate = d);
                        },
                        selectedDays: selectedDays,
                        deliveryType: deliveryType,
                        preferredTime: preferredTime,
                        onTypeChanged: (v) => setState(() => deliveryType = v),
                        onTimeChanged: (v) => setState(() => preferredTime = v),
                        onDaysChanged: (d) => setState(() => selectedDays = d),
                      ),

                      WalletWidget(
                        walletController: walletController,
                        discountController: discountController,
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
                        ChangeStep: (editvalue) {
                          setState(() {
                            currentStep = editvalue;
                          });
                        },
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
                    // BUG #2406 — validate before going to next step
                    onPressed: () async {
                      if (currentStep < 4) {
                        if (_validateCurrentStep()) {
                          setState(() => currentStep++);
                        }
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
                          currentStep == 4 ? Icons.check : Icons.arrow_forward,
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
      ),
    );
  }
}
