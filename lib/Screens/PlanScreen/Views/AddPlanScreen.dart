import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/PlanScreen/Service/VariationController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class AddPlanScreen extends StatefulWidget {
  final bool isEdit;

  final String? planId;
  final String? planName;
  final String? description;
  final String? price;
  final String? minPrice;
  final List<String> imageUrl;
  final List<String>? selectedVariations;

  const AddPlanScreen({
    super.key,
    this.isEdit = false,
    this.planId,
    this.planName,
    this.description,
    this.price,
    this.minPrice,
    this.imageUrl = const [],
    this.selectedVariations,
  });

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  final PlanController controller = Get.put(PlanController());

  final VariationController variationController = Get.put(
    VariationController(),
  );

  final TextEditingController nameCtrl = TextEditingController();

  final TextEditingController descCtrl = TextEditingController();

  final TextEditingController priceCtrl = TextEditingController();

  final TextEditingController minPriceCtrl = TextEditingController();

  List<File> selectedImages = [];
  List<String> existingImages = []; // for edit mode (network images)

  List<String> selectedVariationIds = [];

  String planType = "MONTHLY";

  @override
  void initState() {
    super.initState();

    variationController.fetchVariations();

    nameCtrl.text = widget.planName ?? '';
    descCtrl.text = widget.description ?? '';
    priceCtrl.text = widget.price ?? '';
    minPriceCtrl.text = widget.minPrice ?? '';

    if (widget.selectedVariations != null) {
      selectedVariationIds = List<String>.from(widget.selectedVariations!);
    }

    existingImages = List<String>.from(widget.imageUrl);
    }

  Future<void> pickImages() async {
    final picked = await ImagePicker().pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        selectedImages.addAll(picked.map((e) => File(e.path)).toList());
      });
    }
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,

      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),

      filled: true,
      fillColor: Colors.white,

      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),

        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),

        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),

        borderSide: BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }

  Widget title(String text) {
    return Text(
      text,

      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10.r),

        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 26, 25, 25).withOpacity(0.04),
            blurRadius: 20.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlanController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color(0xffF7F9FB),

          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),

            color: Colors.white,

            child: SizedBox(
              height: 56.h,

              child: ElevatedButton(
                onPressed:
                    controller.isLoading
                        ? null
                        : () async {
                          if (nameCtrl.text.trim().isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please enter plan name",
                            );
                            return;
                          }

                          if (descCtrl.text.trim().isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please enter description",
                            );
                            return;
                          }

                          if (priceCtrl.text.trim().isEmpty) {
                            Fluttertoast.showToast(msg: "Please enter price");
                            return;
                          }

                          if (minPriceCtrl.text.trim().isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please enter minimum price",
                            );
                            return;
                          }

                          if (selectedVariationIds.isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please select variations",
                            );
                            return;
                          }

                          final success = await controller.savePlan(
                            id: widget.isEdit ? widget.planId : null,

                            planName: nameCtrl.text.trim(),

                            price: priceCtrl.text.trim(),

                            minPrice: minPriceCtrl.text.trim(),

                            description: descCtrl.text.trim(),

                            variationIds: selectedVariationIds,

                            isMonthlyPlan: planType == "MONTHLY",

                            isDailyPlan: planType == "DAILY",

                            imageFiles: selectedImages,

                            existingImage: existingImages,
                          );

                          if (success) {
                            Get.back();
                          }
                        },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
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
                          widget.isEdit ? "Update Plan" : "Create Plan",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
          ),

          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 18.h,
                  ),

                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),

                                child: Icon(
                                  Icons.arrow_back,
                                  size: 24.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                widget.isEdit ? "Edit Plan" : "Create Plan",

                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xff111827),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 4.h),

                          Padding(
                            padding: EdgeInsets.only(left: 35.w),
                            child: Text(
                              widget.isEdit
                                  ? "Update mess plan"
                                  : "Add a new mess plan",

                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),

                    child: Column(
                      children: [
                        /// IMAGE SECTION
                        sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              title("Plan Image"),

                              SizedBox(height: 8.h),

                              Wrap(
                                spacing: 14.w,
                                runSpacing: 14.h,
                                children: [
                                  /// EXISTING NETWORK IMAGES
                                  ...existingImages.map((url) {
                                    return _imageBox(
                                      image: NetworkImage(url),
                                      onRemove: () {
                                        setState(() {
                                          existingImages.remove(url);
                                        });
                                      },
                                    );
                                  }).toList(),

                                  /// NEWLY PICKED FILE IMAGES
                                  ...selectedImages.map((file) {
                                    return _imageBox(
                                      image: FileImage(file),
                                      onRemove: () {
                                        setState(() {
                                          selectedImages.remove(file);
                                        });
                                      },
                                    );
                                  }).toList(),

                                  /// ADD BUTTON
                                  GestureDetector(
                                    onTap: pickImages,
                                    child: DottedBorder(
                                      color: Colors.grey.shade300,
                                      strokeWidth: 1.2,
                                      dashPattern: const [6, 4],
                                      borderType: BorderType.RRect,
                                      radius: Radius.circular(10.r),
                                      child: Container(
                                        width: 110.w,
                                        height: 110.w,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 28.sp,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(height: 5.h),
                                            Text(
                                              "Upload",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15.h),

                        /// DETAILS
                        sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              title("Plan Name *"),

                              SizedBox(height: 10.h),
                              commonTextField(
                                controller: nameCtrl,
                                hintText: "Weekly Lunch Plan",
                              ),

                              SizedBox(height: 10.h),

                              title("Description *"),

                              SizedBox(height: 10.h),

                              commonTextField(
                                controller: descCtrl,
                                hintText: "Balanced weekday meal plan",
                                maxLines: 4,
                              ),

                              SizedBox(height: 20.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        title("Price (₹)"),

                                        SizedBox(height: 10.h),

                                        commonTextField(
                                          controller: priceCtrl,
                                          hintText: "999",
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 14.w),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        title("Min Price (₹)"),

                                        SizedBox(height: 10.h),

                                        commonTextField(
                                          controller: minPriceCtrl,
                                          hintText: "799",
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15.h),

                        /// VARIATIONS
                        sectionCard(
                          child: GetBuilder<VariationController>(
                            builder: (variationCtrl) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  title("Select Variations *"),

                                  SizedBox(height: 15.h),

                                  Container(
                                    width: double.infinity,

                                    padding: EdgeInsets.all(16.w),

                                    decoration: BoxDecoration(
                                      color: Colors.white,

                                      borderRadius: BorderRadius.circular(10.r),

                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),

                                    child: Wrap(
                                      spacing: 10.w,

                                      runSpacing: 10.h,

                                      children:
                                          variationCtrl.variations.map((
                                            variation,
                                          ) {
                                            final isSelected =
                                                selectedVariationIds.contains(
                                                  variation.id,
                                                );

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    selectedVariationIds.remove(
                                                      variation.id,
                                                    );
                                                  } else {
                                                    selectedVariationIds.add(
                                                      variation.id,
                                                    );
                                                  }
                                                });
                                              },

                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),

                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w,
                                                  vertical: 12.h,
                                                ),

                                                decoration: BoxDecoration(
                                                  color:
                                                      isSelected
                                                          ? AppColors.primary
                                                          : Colors.white,

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.r,
                                                      ),

                                                  border: Border.all(
                                                    color:
                                                        isSelected
                                                            ? AppColors.primary
                                                            : Colors
                                                                .grey
                                                                .shade300,
                                                  ),
                                                ),

                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,

                                                  children: [
                                                    Icon(
                                                      isSelected
                                                          ? Icons.check_circle
                                                          : Icons
                                                              .radio_button_unchecked,

                                                      size: 18.sp,

                                                      color:
                                                          isSelected
                                                              ? Colors.white
                                                              : Colors.grey,
                                                    ),

                                                    SizedBox(width: 8.w),

                                                    Text(
                                                      variation.title,

                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            isSelected
                                                                ? Colors.white
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 15.h),

                        /// PLAN TYPE
                        sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              title("Plan Type *"),

                              SizedBox(height: 10.h),

                              _planTypeTile(
                                title: "Monthly Plan",

                                value: "MONTHLY",

                                icon: Icons.calendar_month,
                              ),

                              SizedBox(height: 12.h),

                              _planTypeTile(
                                title: "Daily Plan",

                                value: "DAILY",

                                icon: Icons.calendar_today,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _planTypeTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final selected = planType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          planType = value;
        });
      },

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),

          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,

            width: 1.3,
          ),
        ),

        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,

              color: selected ? AppColors.primary : Colors.grey,
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Text(
                title,

                style: TextStyle(
                  fontSize: 14.sp,

                  fontWeight: FontWeight.w700,

                  color: selected ? AppColors.primary : Colors.black,
                ),
              ),
            ),

            Icon(icon, color: Color(0xFF343434)),
          ],
        ),
      ),
    );
  }
}

Widget commonTextField({
  required TextEditingController controller,
  required String hintText,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return SizedBox(
    height: maxLines > 1 ? null : 52.h,

    child: TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,

      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),

        filled: true,
        fillColor: Colors.white,

        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: maxLines > 1 ? 14.h : 0,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),

          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),

          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),

          borderSide: BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    ),
  );
}

Widget _imageBox({
  required ImageProvider image,
  required VoidCallback onRemove,
}) {
  return Stack(
    children: [
      Container(
        width: 110.w,
        height: 110.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          image: DecorationImage(image: image, fit: BoxFit.cover),
        ),
      ),

      Positioned(
        top: 6,
        right: 6,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, size: 16.sp),
          ),
        ),
      ),
    ],
  );
}
