import 'package:flutter/material.dart';
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

    // ✅ Pre-fill data if editing
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
        title: Text(
          widget.isEdit ? "Edit Partner" : "Add Partner",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
            fontSize: 18,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- BASIC INFORMATION ----------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Basic Information",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: "Inter",
                              color: Color(0xff1A1D29),
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildTextField(
                            label: "Name *",
                            hint: "Enter full name",
                            controller: nameController,
                          ),
                          const SizedBox(height: 14),
                          buildTextField(
                            label: "Phone *",
                            hint: "+91 98765 43210",
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          buildTextField(
                            label: "Email",
                            hint: "email@example.com",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          buildTextField(
                            label: "Address",
                            hint: "Enter address",
                            controller: addressController,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------- STATUS SECTION ----------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Status",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                              fontFamily: "Inter",
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Current Status *",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Inter",
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffF0F2F5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonFormField<String>(
                              value: status,
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Active',
                                  child: Text("Active",
                                      style: TextStyle(
                                          fontFamily: "Inter", fontSize: 14)),
                                ),
                                DropdownMenuItem(
                                  value: 'Inactive',
                                  child: Text("Inactive",
                                      style: TextStyle(
                                          fontFamily: "Inter", fontSize: 14)),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  status = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------- BUTTONS ----------
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff1A1D29),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Inter",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (widget.isEdit && widget.partner != null) {
                                  // ✅ Edit Mode
                                  await controller.updatePartner(
                                    id: widget.partner!.id,
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                    address: addressController.text.trim(),
                                    isActive: status == "Active",
                                  );
                                } else {
                                  // ✅ Add Mode
                                  await controller.addPartner(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                    address: addressController.text.trim(),
                                  );
                                }
                                // ✅ Don't call Get.back() here again (already inside controller)
                              }
                            },
                            child: Text(
                              widget.isEdit
                                  ? "Update Partner"
                                  : "Add Partner",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Inter",
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

            // ✅ Loading overlay
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

  // ---------- REUSABLE TEXT FIELD ----------
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0XFFF0F2F5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(16),
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
