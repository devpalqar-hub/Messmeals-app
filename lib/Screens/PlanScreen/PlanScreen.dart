import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/PlanScreen/Views/AddPlanBottomSheet.dart';
import 'package:mess/Screens/PlanScreen/Views/PlanCard.dart';
import 'package:mess/Screens/Utils/TitleText.dart';
import 'package:mess/main.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlanController planController = Get.put(PlanController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      planController.fetchPlans(page: 1);
    });

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- HEADER ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TittleText(text: "Plans"),
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddPlanBottomSheet(),
                      ).then((_) {
                        planController.refreshPlans();
                      });
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text("Add", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0474B9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 13.h),
                    ),
                  ),
                ],
              ),

              Obx(() {
                return Text(
                  "${planController.plans.length} Plans added",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                );
              }),

              SizedBox(height: 16.h),

              /// ---------- SEARCH BAR ----------
              TextField(
                onChanged: (value) => planController.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: "Search plans...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
                    borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// ---------- PLANS LIST ----------
              Expanded(
                child: Obx(() {
                  if (planController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (planController.errorMessage.isNotEmpty) {
                    return Center(child: Text(planController.errorMessage.value));
                  }

                  final filteredPlans = planController.filteredPlans;

                  if (filteredPlans.isEmpty) {
                    return const Center(child: Text("No matching plans"));
                  }

                  return RefreshIndicator(
                    onRefresh: planController.refreshPlans,
                    child: ListView.separated(
                      itemCount: filteredPlans.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final plan = filteredPlans[index];

                       final imageUrl = plan.images.isNotEmpty
    ? (() {
        final rawUrl = plan.images.first.url;
        final cleanUrl = rawUrl.replaceAll("\\", "/");
        if (cleanUrl.startsWith("http")) return cleanUrl;
        
        return "$baseUrl/$cleanUrl".replaceAll("//uploads", "/uploads");
      })()
    : "https://via.placeholder.com/60";



                        return PlanCard(
  title: plan.planName,
  description: plan.description,
  price: double.tryParse(plan.price) ?? 0,
  minPrice: double.tryParse(plan.minPrice) ?? 0,
  meals: plan.variations.map((v) => v.title).toList(),
  imageUrl: imageUrl,
  onDelete: () {
    _showDeleteDialog(context, planController, plan.id);
  },
  onEdit: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPlanBottomSheet(
        isEdit: true,
        planId: plan.id,
        planName: plan.planName,
        price: plan.price,
        minPrice: plan.minPrice,
        description: plan.description,
        imageUrl: imageUrl,
        selectedVariations: plan.variations.map((v) => v.id).toList(),
      ),
    ).then((_) {
      planController.refreshPlans(); // 🔄 refresh after editing
    });
  },
);

                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
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
    builder: (BuildContext ctx) {
      return Dialog(
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
                color: Colors.redAccent,
                size: 45.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                "Delete Plan?",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to delete this plan?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // close dialog
                        await controller.deletePlan(planId);
                        await controller.refreshPlans();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
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
