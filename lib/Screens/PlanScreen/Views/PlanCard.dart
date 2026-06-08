import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final double price;
  final double minPrice;
  final List<String> meals;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.minPrice,
    required this.meals,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 2.h,
      ), // More compact vertical spacing
      padding: EdgeInsets.all(12.w), // Slimmer internal padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r), // Slightly tighter corners
        border: Border.all(
          color: Colors.grey.shade200,
        ), // Lighter, thinner border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp, // Reduced font size
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16.sp, // Smaller icons
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete_outline,
                      size: 16.sp,
                      color: Colors.red.shade400, // Subtle red for delete
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8.h), // Tighter spacing
          /// PRICE ROW
          Row(
            children: [
              Text(
                "₹${price.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary, // Using primary color for emphasis
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  "Min ₹${minPrice.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp, // Reduced font size
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// MEALS CHIPS
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children:
                meals.map((meal) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ), // More compact chips
                    decoration: BoxDecoration(
                      color:
                          Colors
                              .grey
                              .shade100, // Neutral background for chips so price stands out
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      meal,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp, // Smaller font for chips
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
