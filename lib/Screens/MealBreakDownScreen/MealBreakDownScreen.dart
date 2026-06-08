import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/MealBreakDownScreen/Services/MealAnalyticsController.dart';

// ── Colour tokens ────────────────────────────────────────────────────────────
class _C {
  static const surface = Colors.white;
  static const border = Color(0xFFEEEEF0);
  static const primary = Color(0xFF07A4A5);
  static const primaryLight = Color(0xFFE4F9F9);
  static const primaryMid = Color(0x4F07A4A5);
  static const amber = Color(0xFF854F0B);
  static const amberLight = Color(0xFFFAEEDA);
  static const amberBorder = Color(0xFFEF9F27);
  static const green = Color(0xFF3B6D11);
  static const greenLight = Color(0xFFEAF3DE);
  static const greenMid = Color(0xFF639922);
  static const pink = Color(0xFF993556);
  static const pinkLight = Color(0xFFFBEAF0);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
}
// ─────────────────────────────────────────────────────────────────────────────

class MealsAnalyticsScreen extends StatelessWidget {
  MealsAnalyticsScreen({super.key});

  final MealsAnalyticsController ctrl = Get.put(MealsAnalyticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: GetBuilder<MealsAnalyticsController>(
        builder: (__) {
          if (ctrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _C.primary),
            );
          }

          if (ctrl.analyticsData == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 48.sp,
                    color: _C.textTertiary,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No data available',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: _C.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = ctrl.analyticsData!;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date pill ──────────────────────────────────────────────
                _DatePill(date: ctrl.selectedDate),
                SizedBox(height: 20.h),

                // ── Summary cards ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Food to Prepare',
                        value: data.totalVariationDeliveries.toString(),
                        icon: Icons.restaurant_menu_rounded,
                        iconColor: _C.amber,
                        iconBg: _C.amberLight,
                        borderColor: _C.amberBorder,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Deliveries',
                        value: data.totalDeliveries.toString(),
                        icon: Icons.group_rounded,
                        iconColor: _C.primary,
                        iconBg: _C.primaryLight,
                        borderColor: _C.primaryMid,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // ── Variation overview ─────────────────────────────────────
                if (data.byVariation.isNotEmpty) ...[
                  _SectionHeader(title: 'Overall Variation Count'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children:
                        data.byVariation.map((v) {
                          return _VariationChip(
                            label: v.title,
                            count: v.totalCount.toString(),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 24.h),
                ],

                // ── By plan ────────────────────────────────────────────────
                _SectionHeader(title: 'Preparation by Plan'),
                SizedBox(height: 12.h),

                data.byPlan.isEmpty
                    ? Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'No plan data available.',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: _C.textTertiary,
                        ),
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.byPlan.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, i) => _PlanCard(plan: data.byPlan[i]),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _C.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.border),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18.sp,
          color: _C.textPrimary,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Food Preparation Analytics',
        style: GoogleFonts.poppins(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: IconButton(
            icon: Icon(CupertinoIcons.calendar, color: _C.primary, size: 22.sp),
            onPressed: () => ctrl.selectDate(context),
            tooltip: 'Pick date',
          ),
        ),
      ],
    );
  }
}

// ── Date pill ────────────────────────────────────────────────────────────────
class _DatePill extends StatelessWidget {
  const _DatePill({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _C.primaryLight,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _C.primaryMid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 14.sp, color: _C.primary),
          SizedBox(width: 6.w),
          Text(
            DateFormat('EEEE, MMM d, yyyy').format(date),
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: _C.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Top stat card ────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
  });

  final String title, value;
  final IconData icon;
  final Color iconColor, iconBg, borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26.sp,
              fontWeight: FontWeight.w500,
              color: _C.textPrimary,
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: _C.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Variation chip ───────────────────────────────────────────────────────────
class _VariationChip extends StatelessWidget {
  const _VariationChip({required this.label, required this.count});
  final String label, count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _C.primaryLight,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _C.primaryMid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: _C.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan card ────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final dynamic plan; // replace with your actual type

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: _C.greenLight,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.assignment_rounded,
                        size: 14.sp,
                        color: _C.greenMid,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      plan.planName,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _C.primaryMid),
                  ),
                  child: Text(
                    '${plan.totalDeliveries} deliveries',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: _C.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: _C.border),

          // Variation rows
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
            child: Wrap(
              spacing: 16.w,
              runSpacing: 10.h,
              children:
                  (plan.variations as List).map((v) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                            color: _C.greenMid,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          v.title,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: _C.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${v.totalCount}',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: _C.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
