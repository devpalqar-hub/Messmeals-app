import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/MenuScreen/Service/MenuController.dart';
import 'package:mess/Screens/PlanScreen/Service/VariationController.dart';

import 'package:mess/Screens/MenuScreen/Views/AddMenuScreen.dart';
import 'package:mess/Screens/MenuScreen/Views/MenuTimetableCard.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/EmptyStateAddButton.dart';
import 'package:mess/Screens/Utils/TitleText.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _openAddMenu(MessMenuController controller) async {
    await Get.to(() => const AddMenuScreen());
    controller.refreshMenus();
  }

  @override
  Widget build(BuildContext context) {
    final MessMenuController menuController = Get.put(MessMenuController());
    final VariationController variationController = Get.put(
      VariationController(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      menuController.fetchMenus(page: 1);
      variationController.ensureLoaded();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<MessMenuController>(
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------- HEADER ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TittleText(text: "Menus"),
                      ElevatedButton.icon(
                        onPressed: () => _openAddMenu(controller),
                        icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                        label: Text(
                          "Add Menu",
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
                    "${controller.menus.length} Menus added",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 16.h),

                  /// ---------- SEARCH ----------
                  TextField(
                    onChanged: (value) => controller.updateSearch(value),
                    decoration: InputDecoration(
                      hintText: "Search menus...",
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
                        borderSide: BorderSide(color: Colors.grey, width: 1.5.w),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// ---------- LIST ----------
                  Expanded(child: _buildMenuList(context, controller)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, MessMenuController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Text(controller.errorMessage, style: TextStyle(fontSize: 14.sp)),
      );
    }

    final menus = controller.filteredMenus;

    if (controller.menus.isEmpty) {
      return EmptyStateAddButton(
        icon: Icons.restaurant_menu_outlined,
        title: "No menus yet",
        subtitle: "Create your first weekly menu to get started",
        buttonLabel: "Add Menu",
        onAdd: () => _openAddMenu(controller),
      );
    }

    if (menus.isEmpty) {
      return Center(
        child: Text("No matching menus", style: TextStyle(fontSize: 14.sp)),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshMenus,
      child: GetBuilder<VariationController>(
        builder: (variationCtrl) {
          return ListView.builder(
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];

              return MenuTimetableCard(
                menu: menu,
                variations: variationCtrl.variations,
                onDelete: () {
                  _showDeleteDialog(context, controller, menu.id);
                },
                onEdit: () {
                  Get.to(
                    () => AddMenuScreen(
                      isEdit: true,
                      menuId: menu.id,
                      name: menu.name,
                      isActive: menu.isActive,
                      schedule: menu.schedule,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

void _showDeleteDialog(
  BuildContext context,
  MessMenuController controller,
  String menuId,
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
                "Delete Menu?",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to delete this menu? Plans linked to it will lose this menu.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
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
                        Navigator.pop(ctx);
                        await controller.deleteMenu(menuId);
                        await controller.refreshMenus();
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
