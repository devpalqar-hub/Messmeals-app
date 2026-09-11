// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Models/PartnerDeliveryModel.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Service/PartnerDeliveryController.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Views/DeliveryDetailScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class DeliveriesListScreen extends StatefulWidget {
  const DeliveriesListScreen({super.key});

  @override
  State<DeliveriesListScreen> createState() => _DeliveriesListScreenState();
}

class _DeliveriesListScreenState extends State<DeliveriesListScreen> {
  final PartnerDeliveryController controller = Get.put(PartnerDeliveryController());

  /// Upcoming/Today/Completed/All — mixes date and status presets, matching
  /// the design; "Upcoming" = future PENDING deliveries.
  String activeTab = 'Today';
  String statusFilter = '';
  DateTime? dateFilter;

  @override
  void initState() {
    super.initState();
    _applyTab('Today');
  }

  void _applyTab(String tab) {
    setState(() => activeTab = tab);
    final today = DateTime.now();
    switch (tab) {
      case 'Upcoming':
        statusFilter = 'PENDING';
        dateFilter = null;
        break;
      case 'Today':
        statusFilter = '';
        dateFilter = today;
        break;
      case 'Completed':
        statusFilter = 'COMPLETED';
        dateFilter = null;
        break;
      default:
        statusFilter = '';
        dateFilter = null;
    }
    controller.fetchDeliveries(status: statusFilter, date: dateFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Deliveries",
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 14.h),

              /// ---------- TABS ----------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ['Upcoming', 'Today', 'Completed', 'All'].map((tab) {
                        final isSelected = activeTab == tab;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: GestureDetector(
                            onTap: () => _applyTab(tab),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 9.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                tab,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              SizedBox(height: 14.h),

              /// ---------- SEARCH ----------
              TextField(
                onChanged: controller.updateSearch,
                decoration: InputDecoration(
                  hintText: "Search by customer name or address...",
                  hintStyle: TextStyle(fontSize: 13.sp),
                  prefixIcon: Icon(Icons.search, size: 20.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              Expanded(
                child: GetBuilder<PartnerDeliveryController>(
                  builder: (ctrl) {
                    if (ctrl.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final list = ctrl.filteredDeliveries;
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          "No deliveries found",
                          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade500),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh:
                          () => controller.fetchDeliveries(status: statusFilter, date: dateFilter),
                      child: ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final d = list[index];
                          return _DeliveryListTile(
                            delivery: d,
                            onTap: () async {
                              await Get.to(() => DeliveryDetailScreen(deliveryId: d.id));
                              controller.fetchDeliveries(status: statusFilter, date: dateFilter);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryListTile extends StatelessWidget {
  final PartnerDeliveryModel delivery;
  final VoidCallback onTap;

  const _DeliveryListTile({required this.delivery, required this.onTap});

  Future<void> _openMap() async {
    if (delivery.address.isEmpty) return;
    final encoded = Uri.encodeComponent(delivery.address);
    await launchUrl(
      Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded"),
      mode: LaunchMode.externalApplication,
    );
  }

  Color get _statusColor {
    switch (delivery.status) {
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
        return Colors.red.shade400;
      default:
        return AppColors.warning;
    }
  }

  String get _formattedDate {
    final parsed = DateTime.tryParse(delivery.date);
    if (parsed == null) return delivery.date;
    return DateFormat('h:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              height: 38.w,
              width: 38.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                delivery.customerName.isNotEmpty ? delivery.customerName[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.customerName,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          delivery.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      if (delivery.address.isNotEmpty)
                        GestureDetector(
                          onTap: _openMap,
                          child: Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Icon(
                              Icons.map_outlined,
                              size: 15.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    delivery.mealSummary.isNotEmpty
                        ? "${delivery.mealSummary} • ${delivery.planName}"
                        : delivery.planName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  delivery.time ?? _formattedDate,
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    delivery.status[0] + delivery.status.substring(1).toLowerCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
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

*/
