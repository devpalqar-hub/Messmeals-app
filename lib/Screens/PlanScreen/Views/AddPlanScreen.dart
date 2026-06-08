import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final String? planType;

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
    this.planType,
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
    planType = widget.planType ?? "MONTHLY";

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

  Widget title(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111827), // Matched Home Screen dark text
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
          // Matched Home Screen shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
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
          backgroundColor: Colors.white, // Matched Home Screen background
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
              color: Colors.white,
              child: SizedBox(
                height: 45.h, // Matched typical Home Screen button heights
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
                            // if (descCtrl.text.trim().isEmpty) {
                            //   Fluttertoast.showToast(
                            //     msg: "Please enter description",
                            //   );
                            //   return;
                            // }
                            if (priceCtrl.text.trim().isEmpty) {
                              Fluttertoast.showToast(msg: "Please enter price");
                              return;
                            }
                            if (minPriceCtrl.text.trim().isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Please enter selling price",
                              );
                              return;
                            }
                            if (selectedVariationIds.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Please select variations",
                              );
                              return;
                            }

                            if (planType.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Please select plantype",
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
                              //  imageFiles: selectedImages,
                              // existingImage: existingImages,
                            );

                            if (success) {
                              Get.back();
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10.r,
                      ), // Matched Home Screen radius
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
                            style: GoogleFonts.poppins(
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
                                  Icons
                                      .arrow_back_ios_new_outlined, // Matched Home Screen back arrow style
                                  size: 18.sp,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                widget.isEdit ? "Edit Plan" : "Create Plan",
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff111827),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Padding(
                            padding: EdgeInsets.only(left: 30.w),
                            child: Text(
                              widget.isEdit
                                  ? "Update mess plan details"
                                  : "Add a new mess plan",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
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
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: 20.h,
                    ),
                    child: Column(
                      children: [
                        /// IMAGE SECTION
                        // sectionCard(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       title("Plan Image"),
                        //       SizedBox(height: 12.h),
                        //       Wrap(
                        //         spacing: 14.w,
                        //         runSpacing: 14.h,
                        //         children: [
                        //           /// EXISTING NETWORK IMAGES
                        //           ...existingImages.map((url) {
                        //             return _imageBox(
                        //               image: NetworkImage(url),
                        //               onRemove: () {
                        //                 setState(() {
                        //                   existingImages.remove(url);
                        //                 });
                        //               },
                        //             );
                        //           }).toList(),

                        //           /// NEWLY PICKED FILE IMAGES
                        //           ...selectedImages.map((file) {
                        //             return _imageBox(
                        //               image: FileImage(file),
                        //               onRemove: () {
                        //                 setState(() {
                        //                   selectedImages.remove(file);
                        //                 });
                        //               },
                        //             );
                        //           }).toList(),

                        //           /// ADD BUTTON
                        //           GestureDetector(
                        //             onTap: pickImages,
                        //             child: DottedBorder(
                        //               color: Colors.grey.shade300,
                        //               strokeWidth: 1.2,
                        //               dashPattern: const [6, 4],
                        //               borderType: BorderType.RRect,
                        //               radius: Radius.circular(10.r),
                        //               child: SizedBox(
                        //                 width: 100.w,
                        //                 height: 100.w,
                        //                 child: Column(
                        //                   mainAxisAlignment:
                        //                       MainAxisAlignment.center,
                        //                   children: [
                        //                     Icon(
                        //                       Icons.add_a_photo_outlined,
                        //                       size: 24.sp,
                        //                       color: AppColors.primary,
                        //                     ),
                        //                     SizedBox(height: 8.h),
                        //                     Text(
                        //                       "Upload",
                        //                       style: GoogleFonts.poppins(
                        //                         color: AppColors.primary,
                        //                         fontSize: 12.sp,
                        //                         fontWeight: FontWeight.w500,
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        // SizedBox(height: 20.h),

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
                              // SizedBox(height: 16.h),
                              // title("Description *"),
                              // SizedBox(height: 10.h),
                              // commonTextField(
                              //   controller: descCtrl,
                              //   hintText: "Balanced weekday meal plan",
                              //   maxLines: 4,
                              // ),
                              SizedBox(height: 16.h),
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
                                        title("Selling Price (₹)"),
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

                        SizedBox(height: 20.h),

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
                                    // padding: EdgeInsets.all(16.w),
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    //   borderRadius: BorderRadius.circular(10.r),
                                    //   border: Border.all(
                                    //     color: Colors.grey.shade200,
                                    //   ),
                                    // ),
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
                                                  horizontal: 16.w,
                                                  vertical: 10.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      isSelected
                                                          ? AppColors.primary
                                                              .withOpacity(0.1)
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
                                                      size: 16.sp,
                                                      color:
                                                          isSelected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.grey,
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      variation.title,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            isSelected
                                                                ? AppColors
                                                                    .primary
                                                                : Colors
                                                                    .black87,
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

                        SizedBox(height: 20.h),

                        /// PLAN TYPE
                        sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title("Plan Type *"),
                              SizedBox(height: 12.h),
                              _planTypeTile(
                                title: "Monthly Plan",
                                value: "MONTHLY",
                                icon: Icons.calendar_month_outlined,
                              ),
                              SizedBox(height: 12.h),
                              _planTypeTile(
                                title: "Daily Plan",
                                value: "DAILY",
                                icon: Icons.calendar_today_outlined,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : Colors.grey.shade400,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.primary : const Color(0xFF111827),
                ),
              ),
            ),
            Icon(
              icon,
              color: selected ? AppColors.primary : Colors.grey.shade500,
              size: 20.sp,
            ),
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
    // Removed fixed height to allow natural expansion for multiline and proper internal padding
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111827),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
        width: 100.w,
        height: 100.w,
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
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: Icon(Icons.close, size: 14.sp, color: Colors.black87),
          ),
        ),
      ),
    ],
  );
}
