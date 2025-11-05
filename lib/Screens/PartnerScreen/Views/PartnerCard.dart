import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/PartnerScreen/Views/PartnerDetailScreen.dart';

class PartnerCard extends StatelessWidget {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String location;
  final int totalOrders;
  final bool isActive;

  const PartnerCard({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.location,
    required this.totalOrders,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Row: Name + Active badge + icons ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                        color: Color(0xff0A0A0A),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              "active",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Inter",
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ---------- Action buttons ----------
              Row(
                children: [
                  // ✅ Edit Button
                  IconButton(
                    onPressed: () async {
                      await controller.fetchPartnerById(id);

                      final partner = controller.selectedPartner.value;
                      if (partner == null) {
                        Get.snackbar("Error", "Failed to load partner details");
                        return;
                      }

                      // Navigate to AddPartnerScreen for edit
                      final result = await Get.to(() => AddPartnerScreen(
                            isEdit: true,
                            partner: partner,
                          ));

                      if (result == true) {
                        // Refresh and show snackbar when returned
                        await controller.fetchPartners();
                        Get.snackbar("Success", "Partner updated successfully",
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 22),
                  ),

                  // ✅ Delete Button
                  IconButton(
                    onPressed: () => _confirmDelete(context, id, controller),
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),

                  // ✅ View Details Button
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PartnerDetailsScreen(partnerId: id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chevron_right, size: 22),
                  ),
                ],
              ),
            ],
          ),

          // --- Contact Info ---
          Text(
            phone,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              color: Color(0xff717182),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              color: Color(0xff717182),
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey[300]),

          // --- Bottom Row: Orders + Location ---
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TOTAL ORDERS",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Color(0xff717182),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalOrders",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Inter",
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "LOCATION",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Color(0xff717182),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Delete Confirmation Dialog
  void _confirmDelete(BuildContext context, String partnerId, PartnerController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Partner"),
        content: const Text("Are you sure you want to delete this partner?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deletePartner(partnerId);
              await controller.fetchPartners();

              Get.snackbar("Success", "Partner deleted successfully",
                  snackPosition: SnackPosition.BOTTOM);

              // ✅ Go back to previous screen (list with bottom bar)
              if (Navigator.canPop(context)) {
                Navigator.pop(context, true); // return true to refresh
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
