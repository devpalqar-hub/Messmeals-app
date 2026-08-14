import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/OnboardingScreen/onboarding_screen.dart';
import 'package:mess/main.dart';

/// SPLASH / ONBOARDING ENTRY SCREEN
/// Shown once on cold start while we resolve the session, then routes
/// to the Dashboard (already logged in) or the Login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final Color primaryGreen = const Color(0xFF5BA43A);
  final Color darkGreen = const Color(0xFF2F5A20);

  late final AnimationController _logoController;
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final AnimationController _bgController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringScale;
  late final Animation<Offset> _brandSlide;
  late final Animation<double> _brandOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    // Slow ambient drift for the background image (subtle, non-distracting).
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Breathing glow ring behind the logo mark.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Logo entrance — pop in with a slight overshoot.
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _ringScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Brand wordmark + tagline + loader — staggered fade/slide.
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _brandSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _brandOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
    );
    _loaderOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _fadeController.forward();
    });

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2600));
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
    _logoController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// AMBIENT BACKGROUND IMAGE
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final scale = 1.08 + (_bgController.value * 0.06);
              return Transform.scale(scale: scale, child: child);
            },
            child: Image.asset("assets/Firefly.png", fit: BoxFit.cover),
          ),

          /// DARK BRAND GRADIENT OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  darkGreen.withOpacity(0.88),
                  Colors.black.withOpacity(0.75),
                  darkGreen.withOpacity(0.92),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          /// SOFT DECORATIVE GLOW BLOBS
          Positioned(
            top: -60.h,
            right: -50.w,
            child: _glowBlob(220.w, primaryGreen.withOpacity(0.25)),
          ),
          Positioned(
            bottom: -80.h,
            left: -60.w,
            child: _glowBlob(260.w, primaryGreen.withOpacity(0.18)),
          ),

          /// MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  const Spacer(flex: 4),

                  /// LOGO MARK WITH PULSING GLOW RING
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      final pulse = 1.0 + (_pulseController.value * 0.08);
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: _ringScale.value * pulse,
                                child: Container(
                                  height: 150.h,
                                  width: 150.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 112.h,
                                width: 112.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryGreen.withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  size: 56.sp,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32.h),

                  /// BRAND WORDMARK
                  SlideTransition(
                    position: _brandSlide,
                    child: FadeTransition(
                      opacity: _brandOpacity,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Mess",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 34.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: "Meals",
                              style: GoogleFonts.poppins(
                                color: primaryGreen,
                                fontSize: 34.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  /// ADMIN PILL
                  SlideTransition(
                    position: _brandSlide,
                    child: FadeTransition(
                      opacity: _brandOpacity,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          "ADMIN",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  /// TAGLINE
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        "Manage your mess, effortlessly",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  /// BOTTOM LOADER
                  FadeTransition(
                    opacity: _loaderOpacity,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 22.h,
                          width: 22.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryGreen,
                            ),
                            backgroundColor: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          "Loading your dashboard…",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 36.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowBlob(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
        ),
      ),
    );
  }
}
