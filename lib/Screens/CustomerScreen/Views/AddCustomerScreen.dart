// lib/Screens/CustomerScreen/Views/AddCustomerScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;
  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

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
  String? selectedDeliveryType; // "everyday" or "custom"
final List<String> selectedDays = [];
final List<String> weekDays = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];


  late final PartnerController partnerController;
  late final PlanController planController;
  late final CustomerController customerController;

  bool get isEdit => widget.customer != null;
  bool _bootLoading = true;

  @override
  void initState() {
    super.initState();
    partnerController = Get.put(PartnerController());
    planController = Get.find<PlanController>();
    customerController = Get.find<CustomerController>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      planController.ensureLoaded(),
      partnerController.ensureLoaded(),
    ]);
    if (isEdit) _loadCustomerData();
    setState(() => _bootLoading = false);
  }

  void _loadCustomerData() {
    final c = widget.customer!;
    nameController.text = c.name;
    phoneController.text = c.phone;
    emailController.text = c.email;
    addressController.text = c.address;
    locationController.text = c.currentLocation;
    coordinatesController.text = c.latitudeLongitude;
    walletController.text = c.walletBalance.toString();

    if (c.activeSubscriptions.isNotEmpty) {
      final s = c.activeSubscriptions.first;
      discountController.text = s.discountedPrice.toString();

      final hasPlan = planController.plans.any((p) => p.id == s.plan.id);
      selectedMealPlan = hasPlan ? s.plan.id : null;

      final hasPartner = partnerController.partners.any(
        (p) => (p.deliveryPartnerProfile?.id ?? '') == s.deliveryPartnerProfileId,
      );
      selectedPartner = hasPartner ? s.deliveryPartnerProfileId : null;

      startDate = s.startDate;
      endDate = s.endDate;
    } else {
      selectedMealPlan = null;
      selectedPartner = null;
      startDate = null;
      endDate = null;
      discountController.text = '';
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked; else endDate = picked;
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
  discount: discountController.text.trim().isEmpty
      ? "0"
      : discountController.text.trim(),
  planId: selectedMealPlan!,
  deliveryPartnerId: selectedPartner!,
  startDate: startDate!.toIso8601String().split('T').first,
  endDate: endDate!.toIso8601String().split('T').first,
  scheduleType: selectedDeliveryType == "custom" ? "CUSTOM" : "EVERYDAY",
  selectedDays: selectedDays,
);

    }

    if (!Get.isSnackbarOpen) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? "Edit Customer" : "Add Customer";
    final buttonText = isEdit ? "Update Customer" : "Add Customer";

    if (_bootLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
        final plansReady = planController.isReady.value && !planController.isLoading.value;
        final partnersReady = partnerController.isReady.value && !partnerController.isLoading.value;
        final formReady = plansReady && partnersReady;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: AbsorbPointer(
                  absorbing: !formReady,
                  child: Opacity(
                    opacity: formReady ? 1.0 : 0.5,
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
                        const SizedBox(height: 20),
                        _buildScheduleDeliveryTypeCard(),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: (!formReady || customerController.isLoading.value)
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
              ),
            ),
          ],
        );
      }),
    );
  }

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
            if (!planController.isReady.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final plans = planController.plans;
            final valid = plans.any((p) => p.id == selectedMealPlan);
            final value = valid ? selectedMealPlan : null;
            return DropdownButtonFormField<String>(
              value: value,
              hint: const Text("Select Meal Plan"),
              items: plans
                  .map((plan) => DropdownMenuItem<String>(
                        value: plan.id,
                        child: Text(plan.planName),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedMealPlan = val),
              decoration: _inputDecoration("Select Meal Plan"),
              validator: (v) => v == null || v.isEmpty ? "Required field" : null,
            );
          }),
          const SizedBox(height: 14),
          if (!isEdit) _buildDatePickers(),
          const SizedBox(height: 14),
          const Text("Delivery Partner",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Obx(() {
            if (!partnerController.isReady.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final partners = partnerController.partners
                .where((p) => (p.deliveryPartnerProfile?.id ?? '').isNotEmpty)
                .toList();
            final valid = partners.any((p) => p.deliveryPartnerProfile!.id == selectedPartner);
            final value = valid ? selectedPartner : null;
            return DropdownButtonFormField<String>(
              value: value,
              hint: const Text("Select Partner"),
              items: partners
                  .map((p) => DropdownMenuItem<String>(
                        value: p.deliveryPartnerProfile!.id,
                        child: Text(p.name),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedPartner = val),
              decoration: _inputDecoration("Select Partner"),
              validator: (v) => v == null || v.isEmpty ? "Required field" : null,
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
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0XFFF0F2F5),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              date != null ? "${date.day}/${date.month}/${date.year}" : "Select $label",
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

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
            if (label.contains('*') && (value == null || value.trim().isEmpty)) {
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }
Widget _buildScheduleDeliveryTypeCard() {
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
          "Scheduled Delivery Type",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedDeliveryType,
          hint: const Text("Select Delivery Type"),
          items: const [
            DropdownMenuItem(value: "everyday", child: Text("Every Day")),
            DropdownMenuItem(value: "custom", child: Text("Custom")),
          ],
          onChanged: (value) {
            setState(() {
              selectedDeliveryType = value;
              if (value == "everyday") selectedDays.clear();
            });
          },
          decoration: _inputDecoration("Select Delivery Type"),
          validator: (value) =>
              value == null ? "Required field" : null,
        ),
        const SizedBox(height: 12),
        if (selectedDeliveryType == "custom") ...[
          const Text(
            "Select Delivery Days",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: "Inter",
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: weekDays.map((day) {
              final isSelected = selectedDays.contains(day);
              return FilterChip(
                label: Text(day),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedDays.add(day);
                    } else {
                      selectedDays.remove(day);
                    }
                  });
                },
                selectedColor: const Color(0xFF0D47A1).withOpacity(0.15),
                checkmarkColor: const Color(0xFF0D47A1),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF0D47A1) : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ]
      ],
    ),
  );
}


}
