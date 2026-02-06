import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/DeliveriesScreen/Services/DeliveriesController.dart';

class GenerateDeliveriesDialog extends StatefulWidget {
  const GenerateDeliveriesDialog({super.key});

  @override
  State<GenerateDeliveriesDialog> createState() =>
      _GenerateDeliveriesDialogState();
}

class _GenerateDeliveriesDialogState extends State<GenerateDeliveriesDialog> {
  final DeliveriesController controller = Get.find();
  final TextEditingController dateController = TextEditingController();

  Future<void> _pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    if (dateController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(dateController.text);
      } catch (_) {}
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(30),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Row(
              children: [
                const Spacer(),
                const Text(
                  "Generate Deliveries",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// DESCRIPTION
            const Text(
              "Select a date to generate deliveries for all active customers",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            /// DATE LABEL
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Delivery Date",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 8),

            /// DATE INPUT
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: () => _pickDate(context),
              decoration: InputDecoration(
                hintText: "Select date",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),

            const SizedBox(height: 18),

            /// INFO BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "This will create delivery records for all active customers on the selected date.",
              ),
            ),

            const SizedBox(height: 22),

            /// BUTTONS
            Column(
              children: [
                /// GENERATE BUTTON
                Obx(
                      () => SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff030213),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                        if (dateController.text.isEmpty) {
                          Get.snackbar(
                              "Error", "Please select a date");
                          return;
                        }

                        final selectedDate =
                        DateFormat('yyyy-MM-dd')
                            .parse(dateController.text);

                        await controller
                            .generateDeliveriesByDate(selectedDate);

                        if (mounted) Navigator.pop(context);
                      },
                      child: controller.isLoading.value
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text("Generate"),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// CANCEL BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
