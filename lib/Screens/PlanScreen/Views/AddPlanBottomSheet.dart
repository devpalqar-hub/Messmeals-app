import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mess/Screens/PlanScreen/Service/VariationController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';

class AddPlanBottomSheet extends StatefulWidget {
  final bool isEdit;
  final String? planId;
  final String? planName;
  final String? price;
  final String? minPrice;
  final String? description;
  final String? imageUrl;
  final List<String>? selectedVariations;

  const AddPlanBottomSheet({
    super.key,
    this.isEdit = false,
    this.planId,
    this.planName,
    this.price,
    this.minPrice,
    this.description,
    this.imageUrl,
    this.selectedVariations,
  });

  @override
  State<AddPlanBottomSheet> createState() => _AddPlanBottomSheetState();
}

class _AddPlanBottomSheetState extends State<AddPlanBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  final planNameController = TextEditingController();
  final priceController = TextEditingController();
  final minPriceController = TextEditingController();
  final descriptionController = TextEditingController();

  final VariationController variationController =
      Get.find<VariationController>();
  final PlanController planController = Get.find<PlanController>();

  List<String> selectedVariationIds = [];
  File? selectedImage;

  @override
  void initState() {
    super.initState();

    variationController.fetchVariations();

    if (widget.isEdit) {
      planNameController.text = widget.planName ?? '';
      priceController.text = widget.price ?? '';
      minPriceController.text = widget.minPrice ?? '';
      descriptionController.text = widget.description ?? '';
      selectedVariationIds = widget.selectedVariations ?? [];
    }
  }

  @override
  void dispose() {
    planNameController.dispose();
    priceController.dispose();
    minPriceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          left: 20.w,
          right: 20.w,
          top: 20.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4.h,
                    width: 40.w,
                    margin: EdgeInsets.only(bottom: 18.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),

                Text(
                  widget.isEdit ? "Edit Plan" : "Add New Plan",
                  style: GoogleFonts.poppins(
                      fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),

                SizedBox(height: 20.h),

                _buildTextField("Plan Name *", planNameController, required: true),
                _buildTextField("Price *", priceController,
                    required: true, keyboardType: TextInputType.number),
                _buildTextField("Minimum Price *", minPriceController,
                    required: true, keyboardType: TextInputType.number),
                _buildTextField("Description *", descriptionController,
                    required: true, maxLines: 2),

                SizedBox(height: 10.h),

                Text("Plan Image *",
                    style: GoogleFonts.poppins(
                        fontSize: 14.sp, fontWeight: FontWeight.w500)),

                SizedBox(height: 8.h),

                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 140.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                      color: const Color(0xFFF6F6F7),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.file(selectedImage!, fit: BoxFit.cover),
                          )
                        : widget.isEdit && widget.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Image.network(widget.imageUrl!,
                                    fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      color: Colors.grey, size: 32.sp),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "Tap to upload image (Size < 1MB)",
                                    style: GoogleFonts.poppins(
                                        fontSize: 13.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                  ),
                ),

                SizedBox(height: 18.h),

                Text("Delivery Variations *",
                    style: GoogleFonts.poppins(
                        fontSize: 14.sp, fontWeight: FontWeight.w500)),

                SizedBox(height: 10.h),

                Obx(() {
                  if (variationController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    children: variationController.variations.map((v) {
                      return _buildCheckbox(
                        v.title,
                        v.id,
                        selectedVariationIds.contains(v.id),
                      );
                    }).toList(),
                  );
                }),

                SizedBox(height: 25.h),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: const BorderSide(color: Colors.black12),
                          ),
                        ),
                        child: Text("Cancel",
                            style:
                                GoogleFonts.poppins(fontSize: 15.sp)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: GetBuilder<PlanController>(
                        builder: (controller) {
                          return ElevatedButton(
                            onPressed: controller.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate() ||
                                        selectedVariationIds.isEmpty) {
                                      _showSnack("Fill all required fields");
                                      return;
                                    }

                                    if (!widget.isEdit &&
                                        selectedImage == null) {
                                      _showSnack("Please upload plan image");
                                      return;
                                    }

                                    final success = widget.isEdit
                                        ? await controller.editPlan(
                                            id: widget.planId!,
                                            planName:
                                                planNameController.text.trim(),
                                            price:
                                                priceController.text.trim(),
                                            minPrice: minPriceController.text
                                                .trim(),
                                            description: descriptionController
                                                .text
                                                .trim(),
                                            imageFile: selectedImage,
                                            variationIds:
                                                selectedVariationIds,
                                          )
                                        : await controller.addPlan(
                                            planName:
                                                planNameController.text.trim(),
                                            price:
                                                priceController.text.trim(),
                                            minPrice: minPriceController.text
                                                .trim(),
                                            description: descriptionController
                                                .text
                                                .trim(),
                                            imageFile: selectedImage!,
                                            variationIds:
                                                selectedVariationIds,
                                          );

                                    if (success && mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.r),
                              ),
                            ),
                            child: controller.isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : Text(widget.isEdit
                                    ? "Update Plan"
                                    : "Save Plan"),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: required
                ? (v) => v == null || v.isEmpty
                    ? 'This field is required'
                    : null
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F6F7),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, String id, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected
              ? selectedVariationIds.remove(id)
              : selectedVariationIds.add(id);
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xffF3F3F5),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 16)
                  : null,
            ),
            SizedBox(width: 10.w),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15.sp, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
