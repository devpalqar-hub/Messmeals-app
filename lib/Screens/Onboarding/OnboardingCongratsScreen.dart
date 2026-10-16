import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/Onboarding/OnboardingWizardScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

/// Shown right after a successful signup, before the admin's first look at
/// the dashboard — offers to walk through setting up the mess profile, menu,
/// plan and first customer, or to skip straight to the dashboard.
class OnboardingCongratsScreen extends StatefulWidget {
  const OnboardingCongratsScreen({super.key});

  @override
  State<OnboardingCongratsScreen> createState() =>
      _OnboardingCongratsScreenState();
}

class _OnboardingCongratsScreenState extends State<OnboardingCongratsScreen> {
  @override
  void initState() {
    super.initState();
    // Signup just created the mess on the backend — load it now so
    // selectedMessId is ready by the time the wizard's real screens
    // (Mess Profile / Menu / Plan / Customer) need it. permanent: true
    // matches how DashboardScreen registers it (see HomeView.dart) — without
    // it, GetX disposes the controller as soon as this screen is popped,
    // since the onboarding flow never visits DashboardScreen itself.
    Get.put(HomeScreenController(), permanent: true).fetchMyMesses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92.w,
                height: 92.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.celebration_outlined,
                  color: Colors.white,
                  size: 44.sp,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                "Your Mess is Created!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Let's get it ready for customers — set up your\nmess profile, menu, plan and first customer.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.off(() => const OnboardingWizardScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    "Manage Mess Profile",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () {
                    Get.offAll(() => DashboardScreen());
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    "Go to Dashboard",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
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
