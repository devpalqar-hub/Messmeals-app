import 'package:flutter/material.dart';
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
  final PartnerController controller = Get.find<PartnerController>();

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
      backgroundColor: const Color(0xffF7F9FB),
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
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
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

                          buildTextField(
                            label: "Name *",
                            hint: "Enter full name",
                            controller: nameController,
                          ),
                          SizedBox(height: 14.h),

                          if (!widget.isEdit) ...[
                            buildTextField(
                              label: "Phone *",
                              hint: "+91 98765 43210",
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 14.h),
                            buildTextField(
                              label: "Email",
                              hint: "email@example.com",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 14.h),
                          ],

                          buildTextField(
                            label: "Address *",
                            hint: "Enter address",
                            controller: addressController,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// ---------- STATUS (for Add only) ----------
                    if (!widget.isEdit)
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
                            Text(
                              "Current Status *",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<String>(
                              value: status,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0F2F5),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 12.h),
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

                    /// ---------- ACTION BUTTONS ----------
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xff1A1D29),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0474B9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (widget.isEdit && widget.partner != null) {
                                  await controller.updatePartner(
                                    id: widget.partner!.id,
                                    name: nameController.text.trim(),
                                    address: addressController.text.trim(),
                                  );
                                } else {
                                  await controller.addPartner(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                    address: addressController.text.trim(),
                                    // isActive: status == "Active",
                                  );
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
                  ],
                ),
              ),
            ),

            /// ---------- LOADING OVERLAY ----------
            if (controller.isLoading.value)
              Container(
                color: Colors.white70,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  /// ---------- REUSABLE TEXT FIELD ----------
  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xffF0F2F5),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return "Required field";
            }
            return null;
          },
        ),
      ],
    );
  }
}
