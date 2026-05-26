import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PlanScreen/Models/PlanModel.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/PlanScreen/Service/VariationController.dart';

import 'package:mess/Screens/PlanScreen/Views/AddPlanScreen.dart';
import 'package:mess/Screens/PlanScreen/Views/PlanCard.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/TitleText.dart';
import 'package:mess/main.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlanController planController = Get.put(PlanController());
    final VariationController variationController = Get.put(
      VariationController(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      planController.fetchPlans(page: 1);
    });

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<PlanController>(
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------- HEADER ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TittleText(text: "Plans"),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Get.to(() => AddPlanScreen());

                          controller.refreshPlans();
                        },
                        icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                        label: Text(
                          "Add Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 25.w,
                            vertical: 13.h,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  /// ---------- COUNT ----------
                  Text(
                    "${controller.plans.length} Plans added",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 16.h),

                  /// ---------- SEARCH ----------
                  TextField(
                    onChanged: (value) {
                      controller.searchQuery = value;
                      controller.update(); // 🔥 rebuild list
                    },
                    decoration: InputDecoration(
                      hintText: "Search plans...",
                      hintStyle: TextStyle(fontSize: 14.sp),
                      prefixIcon: Icon(Icons.search, size: 20.sp),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.5.w,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// ---------- LIST ----------
                  Expanded(child: _buildPlanList(controller)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlanList(PlanController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Text(controller.errorMessage, style: TextStyle(fontSize: 14.sp)),
      );
    }

    final plans = controller.filteredPlans;

    if (plans.isEmpty) {
      return Center(
        child: Text("No matching plans", style: TextStyle(fontSize: 14.sp)),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshPlans,
      child: ListView.separated(
        itemCount: plans.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final plan = plans[index];

          final List<String> imageUrls =
              plan.images.map((img) {
                final rawUrl = img.url;
                final cleanUrl = rawUrl.replaceAll("\\", "/");

                if (cleanUrl.startsWith("http")) return cleanUrl;

                return "$baseUrl/$cleanUrl".replaceAll("//uploads", "/uploads");
              }).toList();

          final imageUrl =
              imageUrls.isNotEmpty
                  ? imageUrls.first
                  : "https://via.placeholder.com/60";
          ;

          return PlanCard(
            title: plan.planName,
            description: plan.description,
            price: double.tryParse(plan.price) ?? 0,
            minPrice: double.tryParse(plan.minPrice) ?? 0,
            meals: plan.variations.map((v) => v.title).toList(),
            imageUrl: imageUrl,
            onDelete: () {
              _showDeleteDialog(context, controller, plan.id);
            },
            onEdit: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (_) => AddPlanScreen(
                      isEdit: true,
                      planId: plan.id,
                      planName: plan.planName,
                      price: plan.price,
                      minPrice: plan.minPrice,
                      description: plan.description,
                      imageUrl: imageUrls,
                      selectedVariations:
                          plan.variations.map((v) => v.id).toList(),
                    ),
              ).then((_) {
                controller.refreshPlans();
              });
            },
          );
        },
      ),
    );
  }
}

void _showDeleteDialog(
  BuildContext context,
  PlanController controller,
  String planId,
) {
  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color.fromARGB(255, 240, 162, 156),
                size: 45.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                "Delete Plan?",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to delete this plan?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx); // ✅ FIX (close dialog first)
                        await controller.deletePlan(planId);
                        await controller.refreshPlans();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
