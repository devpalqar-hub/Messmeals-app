import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerScreen extends StatelessWidget {
  const HomeShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              // Avatar Shimmer
              Container(
                height: 40.w,
                width: 40.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Shimmer
                  Container(
                    height: 16.sp,
                    width: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Mess Name Shimmer
                  Container(
                    height: 12.sp,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Bell Icon Shimmer
              Container(
                height: 24.w,
                width: 24.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // 1. Total Revenue Main Card Shimmer
                Container(
                  height: 140.h,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),

                SizedBox(height: 10.h),

                // 2. Stats Row Shimmer (Orders, Customers, Partners, Avg)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color:
                        Colors
                            .white, // In shimmer, background becomes base color
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildStatItemShimmer(),
                      _buildDividerShimmer(),
                      _buildStatItemShimmer(),
                      _buildDividerShimmer(),
                      _buildStatItemShimmer(),
                      _buildDividerShimmer(),
                      _buildStatItemShimmer(),
                    ],
                  ),
                ),

                SizedBox(height: 10.sp),

                // 3. Revenue Summary Title Shimmer
                Padding(
                  padding: EdgeInsets.only(left: 14.w),
                  child: Container(
                    height: 16.sp,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // 4. Revenue Summary Cards Row Shimmer
                Row(
                  children: [
                    Expanded(child: _buildRevenueCardShimmer()),
                    Expanded(child: _buildRevenueCardShimmer()),
                  ],
                ),

                SizedBox(height: 20.h),

                // 5. Quick Actions Title Shimmer
                Padding(
                  padding: EdgeInsets.only(left: 14.w),
                  child: Container(
                    height: 16.sp,
                    width: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // 6. Quick Actions Cards Row Shimmer
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      Expanded(child: _buildQuickActionShimmer()),
                      SizedBox(width: 8.w),
                      Expanded(child: _buildQuickActionShimmer()),
                      SizedBox(width: 8.w),
                      Expanded(child: _buildQuickActionShimmer()),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets for Internal Components ---

  Widget _buildStatItemShimmer() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 35.w,
              width: 35.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(height: 10.sp, width: 40.w, color: Colors.white),
            SizedBox(height: 5.h),
            Container(height: 18.sp, width: 30.w, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerShimmer() {
    return Container(height: 70.h, width: 1.2, color: Colors.white);
  }

  Widget _buildRevenueCardShimmer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30.w,
            width: 30.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12.sp, width: 60.w, color: Colors.white),
                SizedBox(height: 8.h),
                Container(height: 18.sp, width: 50.w, color: Colors.white),
                SizedBox(height: 8.h),
                Container(height: 10.sp, width: 40.w, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40.w,
            width: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(height: 16.h),
          Container(height: 12.sp, width: 60.w, color: Colors.white),
        ],
      ),
    );
  }
}
