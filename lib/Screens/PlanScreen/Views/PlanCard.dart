import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  IconData? getMealIcon(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast':
        return Icons.local_drink;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.nights_stay;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 🧩 Robust image URL builder
    final displayImage = () {
      print("🔹 Raw imageUrl from backend: $imageUrl");

      if (imageUrl == null || imageUrl!.isEmpty) {
        print("⚠️ No image URL found — showing placeholder.");
        return "https://via.placeholder.com/100x100.png?text=No+Image";
      }

      final cleanUrl = imageUrl!.replaceAll("\\", "/");
      print("🧹 Cleaned URL: $cleanUrl");

      if (cleanUrl.startsWith("http")) {
        print("🌍 Using full image URL: $cleanUrl");
        return cleanUrl;
      }

      final finalUrl = "$baseUrl/$cleanUrl".replaceAll("//uploads", "/uploads");
      print("✅ Final image URL to load: $finalUrl");
      return finalUrl;
    }();

    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- Left Image ----------
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                displayImage,
                height: 65.w,
                width: 65.w,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 65.w,
                    width: 65.w,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 65.w,
                  width: 65.w,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 28),
                ),
              ),
            ),
            SizedBox(width: 14.w),

            /// ---------- Right Content ----------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------- Title + Price ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff1A1D29),
                          ),
                        ),
                      ),
                      Text(
                        "₹${price.toStringAsFixed(0)}",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1A1D29),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  /// ---------- Description + Min Price ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: const Color(0xff6B7280),
                            fontWeight: FontWeight.w400,
                          ),
                          softWrap: true,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Min: ₹${minPrice.toStringAsFixed(0)}",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff6B7280),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  /// ---------- Meals + Edit/Delete ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (meals.any((m) => m.toLowerCase() == 'breakfast'))
                              const Icon(Icons.local_drink,
                                  size: 18, color: Colors.black54),
                            if (meals.any((m) => m.toLowerCase() == 'lunch'))
                              const Icon(Icons.restaurant,
                                  size: 18, color: Colors.black54),
                            if (meals.any((m) => m.toLowerCase() == 'dinner'))
                              const Icon(Icons.nights_stay,
                                  size: 18, color: Colors.black54),
                            ...meals.map(
                              (meal) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  meal,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: Colors.black87,
                            onPressed: onEdit,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_sharp, size: 20),
                            color: Colors.black87,
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
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
