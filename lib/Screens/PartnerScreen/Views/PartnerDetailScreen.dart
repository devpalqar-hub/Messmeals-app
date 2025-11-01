import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PartnerScreen/Model/PartnerModel.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PartnerScreen/Views/RecentlyDeliveryCard.dart';
import 'package:mess/Screens/PartnerScreen/Views/StatusCard.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart'; // ✅ make sure this exists

class PartnerDetailsScreen extends StatefulWidget {
  final String partnerId;

  const PartnerDetailsScreen({super.key, required this.partnerId});

  @override
  State<PartnerDetailsScreen> createState() => _PartnerDetailsScreenState();
}

class _PartnerDetailsScreenState extends State<PartnerDetailsScreen> {
  final PartnerController controller = Get.put(PartnerController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPartnerById(widget.partnerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final partner = controller.selectedPartner.value;
          if (partner == null) {
            return const Center(child: Text("Partner details not found"));
          }

          final profile = partner.deliveryPartnerProfile;
          final stats = partner.stats;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- HEADER ----------
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Partner Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Inter",
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                  GestureDetector(
  onTap: () async {
    // ✅ Navigate to AddPartnerScreen for editing this partner
    await Get.to(() => AddPartnerScreen(
          partner: partner, // pass the full partner object here
        ));
    // ✅ Refresh details after returning
    controller.fetchPartnerById(widget.partnerId);
  },
  child: _actionButton(Icons.edit_outlined, "Edit"),
),


                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmDelete(context, partner.id),
                      child: _actionButton(Icons.delete_outline, "Delete"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ---------- PROFILE CARD ----------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          partner.name.isNotEmpty
                              ? partner.name.substring(0, 2).toUpperCase()
                              : "NA",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter",
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 35),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partner.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                fontFamily: "Inter",
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _infoRow(Icons.phone, partner.phone),
                            const SizedBox(height: 4),
                            _infoRow(Icons.email_outlined, partner.email),
                            const SizedBox(height: 4),
                            _infoRow(
                              Icons.location_on_outlined,
                              profile?.address ?? "No address available",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ---------- STATS GRID ----------
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.59,
                  children: [
                    StatsCard(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      label: "COMPLETED",
                      value: "${stats?.completedDeliveries ?? 0}",
                    ),
                    StatsCard(
                      icon: Icons.inventory_2_outlined,
                      iconColor: Colors.blue,
                      label: "TOTAL DELIVERIES",
                      value: "${stats?.totalDeliveries ?? 0}",
                    ),
                    StatsCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.purple,
                      label: "EARNINGS",
                      value: "₹${stats?.totalEarnings ?? 0}",
                    ),
                    StatsCard(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.orange,
                      label: "PENDING",
                      value: "${stats?.pendingDeliveries ?? 0}",
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ---------- PERFORMANCE METRICS ----------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Performance Metrics",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: "Inter",
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Completion Rate",
                            style: TextStyle(
                              color: Color(0xff717182),
                              fontFamily: "Inter",
                            ),
                          ),
                          Text(
                            "${_calculateCompletionRate(stats).toStringAsFixed(1)}%",
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: "Inter",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _calculateCompletionRate(stats) / 100.0,
                          backgroundColor: const Color(0xFFE5E5E5),
                          color: Colors.black,
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ---------- RECENT DELIVERIES ----------
                RecentDeliveriesSection(
                  deliveries: [
                    {
                      "status": "Completed",
                      "deliveryId": "DLV-1024",
                      "date": "Oct 22, 2025",
                      "amount": "₹540.00",
                    },
                    {
                      "status": "Pending",
                      "deliveryId": "DLV-1023",
                      "date": "Oct 20, 2025",
                      "amount": "₹230.50",
                    },
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------- Helper Widgets ----------

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xff717182),
              fontSize: 14,
              fontFamily: "Inter",
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCompletionRate(PartnerStats? stats) {
    if (stats == null || stats.totalDeliveries == 0) return 0.0;
    return (stats.completedDeliveries / stats.totalDeliveries) * 100;
  }

  // ---------- Delete Confirmation ----------
  void _confirmDelete(BuildContext context, String partnerId) {
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
              Get.back(); // go back to previous list screen
              Get.snackbar("Success", "Partner deleted successfully",
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
