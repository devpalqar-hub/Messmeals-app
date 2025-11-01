import 'package:flutter/material.dart';

class RecentDeliveriesSection extends StatelessWidget {
  final List<Map<String, String>> deliveries;

  const RecentDeliveriesSection({
    super.key,
    required this.deliveries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            "Recent Deliveries",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
          const SizedBox(height: 12),

          // List of deliveries
          ...deliveries.map((delivery) {
            bool isCompleted = delivery["status"]!.toLowerCase() == "completed";
            Color bgColor =
                isCompleted ? const Color(0xffE9F9EE) : const Color(0xffFDF7E7);
            Color textColor = isCompleted ? Colors.green : Colors.orange;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
             // padding: const EdgeInsets.all(14),
             // decoration: BoxDecoration(
               // borderRadius: BorderRadius.circular(12),
                //border: Border.all(color: Colors.grey.shade300),
             // ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      delivery["status"]!,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery["deliveryId"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter",
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          delivery["date"]!,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontFamily: "Inter",
                             fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    delivery["amount"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
