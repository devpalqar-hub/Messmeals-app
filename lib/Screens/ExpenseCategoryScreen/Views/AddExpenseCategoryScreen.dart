import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/ExpenseCategoryScreen/Service/ExpenseCategoryController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class AddExpenseCategoryScreen extends StatefulWidget {
  final bool isEdit;
  final String? categoryId;
  final String? name;
  final String? description;

  const AddExpenseCategoryScreen({
    super.key,
    this.isEdit = false,
    this.categoryId,
    this.name,
    this.description,
  });

  @override
  State<AddExpenseCategoryScreen> createState() =>
      _AddExpenseCategoryScreenState();
}

class _AddExpenseCategoryScreenState extends State<AddExpenseCategoryScreen> {
  final ExpenseCategoryController controller = Get.put(
    ExpenseCategoryController(),
  );

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameCtrl.text = widget.name ?? '';
    descCtrl.text = widget.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseCategoryController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF111827)),
            title: Text(
              widget.isEdit ? "Edit Category" : "Add Category",
              style: TextStyle(
                color: const Color(0xFF111827),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
              child: SizedBox(
                height: 45.h,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading
                          ? null
                          : () async {
                            if (nameCtrl.text.trim().isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Please enter category name",
                              );
                              return;
                            }

                            final success = await controller.saveCategory(
                              id: widget.isEdit ? widget.categoryId : null,
                              name: nameCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                            );

                            if (success) Get.back();
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child:
                      controller.isLoading
                          ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            widget.isEdit
                                ? "Update Category"
                                : "Create Category",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name *",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  commonInputField(controller: nameCtrl, hintText: "Groceries"),
                  SizedBox(height: 16.h),
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  commonInputField(
                    controller: descCtrl,
                    hintText: "Food and vegetable purchases",
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget commonInputField({
  required TextEditingController controller,
  required String hintText,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF111827),
    ),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.2),
      ),
    ),
  );
}
