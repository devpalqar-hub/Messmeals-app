import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/MenuScreen/Views/AddMenuScreen.dart';
import 'package:mess/Screens/PlanScreen/Views/AddPlanScreen.dart';
import 'package:mess/Screens/SettingsScreen/MessProfileSettingsScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

/// Post-signup setup wizard — walks a new mess admin through the mess
/// profile, menu, plan and first customer, in that order. Each step opens
/// the same real screen used elsewhere in the app (so saving here is the
/// exact same create/update flow, not a separate copy), and can be skipped.
class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  int currentStep = 1; // 1..4
  final Map<int, bool> stepDone = {1: false, 2: false, 3: false, 4: false};

  static const int totalSteps = 4;

  void _finish() {
    Get.offAll(() => DashboardScreen());
  }

  void _goNext() {
    if (currentStep >= totalSteps) {
      _finish();
    } else {
      setState(() => currentStep++);
    }
  }

  void _goBack() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    } else {
      Get.back();
    }
  }

  Future<void> _openStepScreen() async {
    switch (currentStep) {
      case 1:
        await Get.to(() => const MessProfileSettingsScreen());
        break;
      case 2:
        await Get.to(() => const AddMenuScreen());
        break;
      case 3:
        await Get.to(() => const AddPlanScreen());
        break;
      case 4:
        await Get.to(() => const AddCustomerScreen());
        break;
    }
    if (mounted) setState(() => stepDone[currentStep] = true);
  }

  _StepContent get _content {
    switch (currentStep) {
      case 1:
        return _StepContent(
          icon: Icons.storefront_outlined,
          title: "Set up your Mess Profile",
          subtitle:
              "Add your logo, cover photo, food type and tags — this is what customers see first.",
          actionLabel: "Edit Mess Profile",
        );
      case 2:
        return _StepContent(
          icon: Icons.restaurant_menu_outlined,
          title: "Create your weekly Menu",
          subtitle:
              "Add what you'll serve for breakfast, lunch and dinner across the week.",
          actionLabel: "Create Menu",
        );
      case 3:
        return _StepContent(
          icon: Icons.menu_book_outlined,
          title: "Create your first Plan",
          subtitle:
              "Bundle your menu into a plan with pricing and delivery days customers can subscribe to.",
          actionLabel: "Create Plan",
        );
      default:
        return _StepContent(
          icon: Icons.person_add_alt_outlined,
          title: "Add your first Customer",
          subtitle:
              "Add a customer's details and subscribe them to a plan to start deliveries.",
          actionLabel: "Add Customer",
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final done = stepDone[currentStep] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — back, "Step X of 4", Skip
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      width: 34.w,
                      height: 34.w,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 17.sp,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  Text(
                    "Step $currentStep of $totalSteps",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  GestureDetector(
                    onTap: _finish,
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Text(
                        "Skip",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: currentStep / totalSteps,
                  minHeight: 5.h,
                  backgroundColor: const Color(0xFFF1F3F5),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),

            SizedBox(height: 10.h),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        content.icon,
                        color: AppColors.primaryDark,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    Text(
                      content.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      content.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: OutlinedButton.icon(
                        onPressed: _openStepScreen,
                        icon: Icon(
                          done
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          size: 18.sp,
                          color:
                              done ? AppColors.primary : AppColors.primaryDark,
                        ),
                        label: Text(
                          done ? "${content.actionLabel} ✓" : content.actionLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                done ? AppColors.primary : AppColors.primaryDark,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                done ? AppColors.primary : Colors.grey.shade300,
                            width: done ? 1.4 : 1,
                          ),
                          backgroundColor:
                              done
                                  ? AppColors.primary.withOpacity(0.06)
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom actions — Skip for now / Continue
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50.h,
                      child: OutlinedButton(
                        onPressed: _goNext,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          "Skip for now",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _goNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          currentStep == totalSteps ? "Finish" : "Continue",
                          style: GoogleFonts.poppins(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepContent {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;

  _StepContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });
}
