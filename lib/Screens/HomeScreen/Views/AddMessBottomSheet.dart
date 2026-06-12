import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/Utils/Colors.dart';
// import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';

class AddMessBottomSheet extends StatefulWidget {
  const AddMessBottomSheet({super.key});

  @override
  State<AddMessBottomSheet> createState() => _AddMessBottomSheetState();
}

class _AddMessBottomSheetState extends State<AddMessBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  //final TextEditingController _descController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    // _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Proceed with your API / Controller logic here

      HomeScreenController hctrl = Get.find();
      hctrl.addNewMess(
        name: _nameController.text.trim(),
        zipCode: _zipController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isMandatory = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black87),
      decoration: InputDecoration(
        labelText: isMandatory ? "$label *" : label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: Colors.grey[600],
        ),
        alignLabelWithHint: true,
        // Reduced padding for a more compact look
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        filled: true,
        fillColor: Colors.grey.shade50,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: PrimaryColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        errorStyle: const TextStyle(height: 0.8),
      ),
      validator: (value) {
        if (isMandatory && (value == null || value.trim().isEmpty)) {
          return "Required";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      builder: (__) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add New Mess",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.back(),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Name Field
                    _buildTextField(
                      label: "Name",
                      controller: _nameController,
                      isMandatory: true,
                    ),
                    SizedBox(height: 12.h),

                    // Side-by-Side: Phone & Zip Code
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Phone",
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildTextField(
                            label: "Zip Code",
                            controller: _zipController,
                            isMandatory: true,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Address Field
                    _buildTextField(
                      label: "Address",
                      controller: _addressController,
                      maxLines: 2,
                    ),
                    SizedBox(height: 30.h),

                    // Description Field
                    // _buildTextField(
                    //   label: "Description",
                    //   controller: _descController,
                    //   maxLines: 2,
                    // ),
                    //    SizedBox(height: 18.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _submit,
                        child:
                            (__.addMessLoading)
                                ? CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 1,
                                )
                                : Text(
                                  "Create",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
