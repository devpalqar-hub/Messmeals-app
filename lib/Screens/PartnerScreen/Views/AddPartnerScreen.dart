import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PartnerScreen/Model/PartnerModel.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';

class AddPartnerScreen extends StatefulWidget {
  final bool isEdit;
  final Partner? partner;

  const AddPartnerScreen({super.key, this.isEdit = false, this.partner});

  @override
  State<AddPartnerScreen> createState() => _AddPartnerScreenState();
}

class _AddPartnerScreenState extends State<AddPartnerScreen> {
  final _formKey = GlobalKey<FormState>();
   final PartnerController controller = Get.put(PartnerController());

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  String status = 'Active';

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.partner != null) {
      final partner = widget.partner!;
      nameController.text = partner.name;
      phoneController.text = partner.phone;
      emailController.text = partner.email;
      addressController.text = partner.deliveryPartnerProfile?.address ?? "";
      status = partner.isActive ? "Active" : "Inactive";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEdit ? "Edit Partner" : "Add Partner",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            fontFamily: "Inter",
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.only(bottom: 20.w, left: 16.w, right: 16.w),
          child: Row(
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
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff07A4A5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = false;

                      if (widget.isEdit && widget.partner != null) {
                        success = await controller.updatePartner(
                          id: widget.partner!.id,
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          status: status == "Active",
                        );
                      } else {
                        success = await controller.addPartner(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          address: addressController.text.trim(),
                        );
                      }

                      if (success) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  child: Text(
                    widget.isEdit ? "Update Partner" : "Add Partner",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: GetBuilder<PartnerController>(
        builder: (controller) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ---------- BASIC INFO ----------
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Basic Information",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: const Color(0xff1A1D29),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // BUG #2413 — Name marked with * as required
                            _buildTextField(
                              label: "Full Name",
                              hint: "Enter full name",
                              controller: nameController,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Name is required";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 14.h),

                            // BUG #2410 — Phone validation for delivery partners
                            // BUG #2413 — Phone marked with * as required
                            _buildTextField(
                              label: "Phone Number",
                              hint: "+91 98765 43210",
                              controller: phoneController,
                              isRequired: true,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Phone number is required";
                                }
                                // BUG #2410 — must be exactly 10 digits
                                if (!RegExp(
                                  r'^\d{10}$',
                                ).hasMatch(value.trim())) {
                                  return "Enter a valid 10-digit phone number";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // BUG #2412 — Status section shown in edit mode
                      if (widget.isEdit)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: const Color(0xff1A1D29),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              RichText(
                                text: TextSpan(
                                  text: "Current Status",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              DropdownButtonFormField<String>(
                                value: status,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xffF0F2F5),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Active',
                                    child: Text("Active"),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Inactive',
                                    child: Text("Inactive"),
                                  ),
                                ],
                                // BUG #2412 — status change is properly captured
                                onChanged: (value) {
                                  setState(() {
                                    status = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),

              if (controller.isLoading)
                Container(
                  color: Colors.white70,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  // BUG #2413 — Required fields show asterisk via isRequired flag
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children:
                isRequired
                    ? [
                      TextSpan(
                        text: " *",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]
                    : [],
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xffF0F2F5),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
