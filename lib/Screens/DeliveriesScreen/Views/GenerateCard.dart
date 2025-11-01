import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/DeliveriesScreen/Services/DeliveriesController.dart';

class GenerateDeliveriesDialog extends StatefulWidget {
  const GenerateDeliveriesDialog({super.key});

  @override
  State<GenerateDeliveriesDialog> createState() => _GenerateDeliveriesDialogState();
}

class _GenerateDeliveriesDialogState extends State<GenerateDeliveriesDialog> {
  final DeliveriesController controller = Get.find();
  final TextEditingController dateController = TextEditingController();

  Future<void> _pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    // if a valid date was already chosen
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
            // HEADER
            Row(
              children: [
                const Spacer(),
                const Text(
                  "Generate Deliveries",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const Text(
              "Select a date to generate deliveries for all active customers",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
                color: Color(0xff717182),
              ),
            ),
            const SizedBox(height: 20),

            // DATE INPUT
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Delivery Date",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w500,
                  color: Color(0xff0A0A0A),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dateController,
              readOnly: true,
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
              onTap: () => _pickDate(context),
            ),
            const SizedBox(height: 14),

            // INFO BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "This will create 3 delivery records for all active customers on the selected date.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // BUTTONS
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff030213),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      if (dateController.text.isEmpty) {
                        Get.snackbar("Error", "Please select a date");
                        return;
                      }

                      // ✅ Convert String → DateTime before passing
                      final selectedDate = DateFormat('yyyy-MM-dd').parse(dateController.text);

                      await controller.generateDeliveriesByDate(selectedDate);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Generate",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Inter",
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xff0A0A0A),
                        fontFamily: "Inter",
                        fontSize: 14,
                      ),
                    ),
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
