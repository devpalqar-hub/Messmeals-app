// lib/Screens/CustomerScreen/Views/AddCustomerScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customer; // ✅ null = add, not null = edit

  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final walletController = TextEditingController();
  final locationController = TextEditingController();
  final coordinatesController = TextEditingController();
  final discountController = TextEditingController();

  String? selectedMealPlan;
  String? selectedPartner;
  DateTime? startDate;
  DateTime? endDate;

  // GetX Controllers
  final PartnerController partnerController = Get.put(PartnerController());
  final PlanController planController = Get.put(PlanController());
  final CustomerController customerController = Get.put(CustomerController());

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    planController.fetchPlans();
    partnerController.fetchPartners();

    if (isEdit) {
      _loadCustomerData();
    }
  }

 void _loadCustomerData() {
  final c = widget.customer!;

  // Safely assign with default fallbacks
  nameController.text = c.name.isNotEmpty ? c.name : '';
  phoneController.text = c.phone.isNotEmpty ? c.phone : '';
  emailController.text = c.email.isNotEmpty ? c.email : '';
  addressController.text = c.address.isNotEmpty ? c.address : '';
  locationController.text = c.currentLocation.isNotEmpty ? c.currentLocation : '';
  coordinatesController.text = c.latitudeLongitude.isNotEmpty ? c.latitudeLongitude : '';
  walletController.text = c.walletBalance.toString();

  // Handle active subscriptions
  if (c.activeSubscriptions.isNotEmpty) {
    final subscription = c.activeSubscriptions.first;

    // ✅ Access discountedPrice from ActiveSubscription
    discountController.text = subscription.discountedPrice.toString();

    selectedMealPlan = subscription.plan.id.isNotEmpty
        ? subscription.plan.id
        : null;

    selectedPartner = subscription.deliveryPartnerProfileId.isNotEmpty
        ? subscription.deliveryPartnerProfileId
        : null;

    startDate = subscription.startDate;
    endDate = subscription.endDate;
  } else {
    selectedMealPlan = null;
    selectedPartner = null;
    startDate = null;
    endDate = null;
    discountController.text = ''; // no discount
  }

  setState(() {});
}



  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedMealPlan == null) {
      Get.snackbar("Error", "Please select a meal plan");
      return;
    }

    if (selectedPartner == null) {
      Get.snackbar("Error", "Please select a delivery partner");
      return;
    }

    if (!isEdit && (startDate == null || endDate == null)) {
      Get.snackbar("Error", "Please select start and end dates");
      return;
    }

    if (isEdit) {
      /// ✅ Edit existing customer
      await customerController.updateCustomer(
        id: widget.customer!.id,
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        latitudeLongitude: coordinatesController.text.trim(),
        currentLocation: locationController.text.trim(),
        walletAmount: int.tryParse(walletController.text.trim()) ?? 0,
        planId: selectedMealPlan!,
        deliveryPartnerId: selectedPartner!,
      );
    } else {
      /// ✅ Add new customer
      await customerController.addCustomer(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        address: addressController.text.trim(),
        latitudeLongitude: coordinatesController.text.trim(),
        currentLocation: locationController.text.trim(),
        isActive: true,
        walletAmount: walletController.text.trim().isEmpty
            ? "0"
            : walletController.text.trim(),
        discount: "0",
        planId: selectedMealPlan!,
        deliveryPartnerId: selectedPartner!,
        startDate: startDate!.toIso8601String().split('T').first,
        endDate: endDate!.toIso8601String().split('T').first,
      );
    }

    if (Get.isSnackbarOpen == false) {
      Get.back(); // ✅ Pop after success
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? "Edit Customer" : "Add Customer";
    final buttonText = isEdit ? "Update Customer" : "Add Customer";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
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
                    _buildBasicInfoCard(),
                    const SizedBox(height: 20),
                    _buildPlanAndSubscriptionCard(),
                    const SizedBox(height: 20),
                    _buildWalletCard(),
                     const SizedBox(height: 20),
                    _buildDiscountCard(),
                    const SizedBox(height: 20),
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
                            onPressed: () => Navigator.pop(context),
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
                            onPressed: customerController.isLoading.value
                                ? null
                                : _submitForm,
                            child: customerController.isLoading.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    buttonText,
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
          ],
        );
      }),
    );
  }

  // ---------- BASIC INFO ----------
  Widget _buildBasicInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Basic Information",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: Color(0xFF1A1D29))),
          const SizedBox(height: 16),
          buildTextField(
              label: "Name *",
              hint: "Enter full name",
              controller: nameController),
          const SizedBox(height: 14),
          if (!isEdit) ...[
            buildTextField(
                label: "Phone *",
                hint: "+91 98765 43210",
                controller: phoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            buildTextField(
                label: "Email",
                hint: "email@example.com",
                controller: emailController,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
          ],
          _buildAddressSection(),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Address",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontFamily: "Inter")),
        const SizedBox(height: 6),
        TextFormField(
          controller: addressController,
          maxLines: 2,
          decoration: _inputDecoration("Enter full address"),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: locationController,
          decoration: _inputDecoration("Current Location (optional)"),
        ),
        const SizedBox(height: 10),
        const Center(child: Text("or")),
        const SizedBox(height: 10),
        TextFormField(
          controller: coordinatesController,
          decoration: _inputDecoration("Enter latitude,longitude"),
        ),
      ],
    );
  }

  // ---------- PLAN & SUBSCRIPTION ----------
  Widget _buildPlanAndSubscriptionCard() {
    return Container(
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
            "Plan and Subscription",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: "Inter",
              color: Color(0xFF1A1D29),
            ),
          ),
          const SizedBox(height: 16),

          const Text("Meal Plan",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Obx(() {
            if (planController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final plans = planController.plans;
            if (plans.isEmpty) {
              return const Text("No meal plans found");
            }

            return DropdownButtonFormField<String>(
              value: selectedMealPlan,
              hint: const Text("Select Meal Plan"),
              items: plans
                  .map((plan) => DropdownMenuItem<String>(
                        value: plan.id,
                        child: Text(plan.planName),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedMealPlan = val),
              decoration: _inputDecoration("Select Meal Plan"),
            );
          }),

          const SizedBox(height: 14),
          if (!isEdit) _buildDatePickers(),
          const SizedBox(height: 14),

          const Text("Delivery Partner",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Obx(() {
            if (partnerController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final partners = partnerController.partners;
            if (partners.isEmpty) {
              return const Text("No delivery partners found");
            }

            return DropdownButtonFormField<String>(
  value: (partners.any((p) => p.deliveryPartnerProfile?.id == selectedPartner))
      ? selectedPartner
      : null, // ✅ ensures only valid value
  hint: const Text("Select Partner"),
  items: partners
      .where((p) => p.deliveryPartnerProfile?.id.isNotEmpty ?? false)
      .map((p) => DropdownMenuItem<String>(
            value: p.deliveryPartnerProfile!.id,
            child: Text(p.name),
          ))
      .toList(),
  onChanged: (val) => setState(() => selectedPartner = val),
  decoration: _inputDecoration("Select Partner"),
);

          }),
        ],
      ),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
            child: _buildDateField(
                "Start Date", startDate, () => _pickDate(context, true))),
        const SizedBox(width: 14),
        Expanded(
            child: _buildDateField(
                "End Date", endDate, () => _pickDate(context, false))),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0XFFF0F2F5),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              date != null
                  ? "${date.day}/${date.month}/${date.year}"
                  : "Select $label",
              style:
                  const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- WALLET ----------
  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Wallet",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: "Inter")),
          const SizedBox(height: 10),
          buildTextField(
              label: "Wallet Amount",
              hint: "0",
              controller: walletController,
              keyboardType: TextInputType.number),
        ],
      ),
    );
  }
Widget _buildDiscountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Discount",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: "Inter")),
          const SizedBox(height: 10),
          buildTextField(
              label: "Select discount amount",
              hint: "0",
              controller: discountController,
              keyboardType: TextInputType.number),
        ],
      ),
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
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontFamily: "Inter")),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
          validator: (value) {
            if (label.contains('*') &&
                (value == null || value.trim().isEmpty)) {
              return "Required field";
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0XFFF0F2F5),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }
}
