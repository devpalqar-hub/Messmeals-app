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

  late VariationController variationController;
  late PlanController planController;

  List<String> selectedVariationIds = [];
  File? selectedImage;
  String? existingImage;

 

  @override
  void initState() {
    super.initState();

    variationController = Get.find();
    planController = Get.find();

    variationController.ensureLoaded();

    if (widget.isEdit) {
      planNameController.text = widget.planName ?? '';
      priceController.text = widget.price ?? '';
      minPriceController.text = widget.minPrice ?? '';
      descriptionController.text = widget.description ?? '';
      selectedVariationIds = List.from(widget.selectedVariations ?? []);
      existingImage = widget.imageUrl;

     
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
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
                _header(),
                SizedBox(height: 20.h),

                _buildTextField("Plan Name *", planNameController, required: true),
                _buildTextField("Price *", priceController, required: true, keyboardType: TextInputType.number),
                _buildTextField("Minimum Price *", minPriceController, required: true, keyboardType: TextInputType.number),
                _buildTextField("Description *", descriptionController, required: true, maxLines: 2),

                SizedBox(height: 10.h),
              
                _imageSection(),
                _variationSection(),

                SizedBox(height: 25.h),
                _buttons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Column(
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
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ================= PLAN TYPE =================

  

  // ================= IMAGE =================

  Widget _imageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Plan Image *"),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 140.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade300),
              color: const Color(0xFFF6F6F7),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: selectedImage != null
                  ? Image.file(selectedImage!, fit: BoxFit.cover)
                  : (existingImage != null && existingImage!.isNotEmpty)
                      ? Image.network(existingImage!, fit: BoxFit.cover)
                      : const Center(child: Text("Tap to upload image")),
            ),
          ),
        ),
        SizedBox(height: 18.h),
      ],
    );
  }

  

  Widget _variationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delivery Variations *"),
        SizedBox(height: 10.h),
        GetBuilder<VariationController>(
          builder: (vCtrl) {
            if (vCtrl.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vCtrl.variations.isEmpty) {
              return const Text("No variations available");
            }

            return Column(
              children: vCtrl.variations.map((v) {
                return Row(
                  children: [
                    Checkbox(
                    activeColor: Colors.black,
                    checkColor: Colors.white,
                      value: selectedVariationIds.contains(v.id),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedVariationIds.add(v.id);
                          } else {
                            selectedVariationIds.remove(v.id);
                          }
                        });
                      },
                    ),
                    Text(v.title),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

 

  Widget _buttons() {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,   
            
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          child:  Text("Cancel",style: TextStyle(color:Colors.black),),
        ),
      ),
      SizedBox(width: 10.w),

      Expanded(
        child: GetBuilder<PlanController>(
          builder: (pCtrl) {
            return ElevatedButton(
              onPressed: pCtrl.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: pCtrl.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.isEdit ? "Update Plan" : "Save Plan",
                    ),
            );
          },
        ),
      ),
    ],
  );
}

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || selectedVariationIds.isEmpty) {
      Get.snackbar("Error", "Fill all required fields");
      return;
    }

    if (!widget.isEdit && selectedImage == null) {
      Get.snackbar("Error", "Image required");
      return;
    }

    final success = await planController.savePlan(
      id: widget.isEdit ? widget.planId : null,
      planName: planNameController.text.trim(),
      price: priceController.text.trim(),
      minPrice: minPriceController.text.trim(),
      description: descriptionController.text.trim(),
      variationIds: selectedVariationIds,
      imageFile: selectedImage,
      existingImage: existingImage,
     
    );

    if (success) {
      Get.snackbar("Success", "Plan saved successfully");
      Navigator.pop(context);
    }
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
          Text(label),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: required
                ? (v) => v == null || v.isEmpty ? 'Required' : null
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F6F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}