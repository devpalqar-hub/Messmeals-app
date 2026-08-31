import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/ExpenseCategoryScreen/Service/ExpenseCategoryController.dart';
import 'package:mess/Screens/ExpenseCategoryScreen/Views/AddExpenseCategoryScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/TitleText.dart';

class ExpenseCategoryScreen extends StatelessWidget {
  const ExpenseCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseCategoryController controller = Get.put(
      ExpenseCategoryController(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCategories();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: TittleText(text: "Expense Categories", size: 18.sp),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<ExpenseCategoryController>(
            builder: (ctrl) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Get.to(() => const AddExpenseCategoryScreen());
                      },
                      icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                      label: Text(
                        "Add Category",
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
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(child: _buildList(context, ctrl)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ExpenseCategoryController controller,
  ) {
    if (controller.isLoading && controller.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          controller.errorMessage,
          style: TextStyle(fontSize: 14.sp),
        ),
      );
    }

    if (controller.categories.isEmpty) {
      return Center(
        child: Text(
          "No categories yet",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchCategories,
      child: ListView.separated(
        itemCount: controller.categories.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (category.description.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          category.description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Get.to(
                      () => AddExpenseCategoryScreen(
                        isEdit: true,
                        categoryId: category.id,
                        name: category.name,
                        description: category.description,
                      ),
                    );
                  },
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 14.w),
                GestureDetector(
                  onTap: () => _confirmDelete(context, controller, category.id),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18.sp,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ExpenseCategoryController controller,
    String id,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete category?"),
            content: const Text("This cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await controller.deleteCategory(id);
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
