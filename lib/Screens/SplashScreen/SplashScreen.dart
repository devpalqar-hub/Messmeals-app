import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/OnboardingScreen/onboarding_screen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/main.dart';

/// SPLASH SCREEN
/// Shown once on cold start while we resolve the session, then routes
/// to the Dashboard (already logged in) or the Login screen. Matches the
/// app's minimal theme: a plain white background and the app logo — no
/// imagery, gradients, or decorative chrome.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _loaderOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    if (login == "IN") {
      Get.offAll(() => DashboardScreen());
    } else if (!onboardingSeen) {
      Get.offAll(() => OnboardingScreen());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  "assets/appLogo.png",
                  width: 200.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            FadeTransition(
              opacity: _loaderOpacity,
              child: Column(
                children: [
                  SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Loading…",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
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
