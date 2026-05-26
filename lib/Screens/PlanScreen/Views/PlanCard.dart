import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/main.dart';
class PlanCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final double minPrice;
  final List<String> meals;
  final String? imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlanCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.minPrice,
    required this.meals,
    this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  String get displayImage {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return "https://via.placeholder.com/300";
    }
    final clean = imageUrl!.replaceAll("\\", "/");
    return clean.startsWith("http")
        ? clean
        : "$baseUrl/$clean".replaceAll("//uploads", "/uploads");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight( // 🔥 KEY for full height image
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           Container(
  padding: EdgeInsets.all(10.w),
  decoration: BoxDecoration(
    color: Colors.grey.shade100, // 👈 soft background
    borderRadius: BorderRadius.circular(12.r),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10.r),
    child: Image.network(
      displayImage,
      height: 70.w,
      width: 100.w,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 70.w,
        width: 70.w,
        color: AppColors.primary.withOpacity(0.1),
        child: Icon(Icons.image_not_supported, size: 22.sp),
      ),
    ),
  ),
),

            /// CONTENT
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE + ACTIONS
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onEdit,
                              child: Icon(Icons.edit_outlined, size: 18.sp),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: onDelete,
                              child: Icon(Icons.delete_outline, size: 18.sp),
                            ),
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 6.h),

                    /// DESCRIPTION
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    /// PRICE
                    Row(
                      children: [
                        Text(
                          "₹${price.toStringAsFixed(0)}",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "Min ₹${minPrice.toStringAsFixed(0)}",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// MEALS
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: meals.map((meal) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            meal,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}