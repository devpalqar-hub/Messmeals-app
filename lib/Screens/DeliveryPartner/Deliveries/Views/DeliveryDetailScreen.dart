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
import 'package:mess/Screens/Utils/AppColors.dart';

class DeliveryDetailScreen extends StatelessWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  Future<void> _call(String phone) async {
    if (phone.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  Future<void> _openMap(String address) async {
    if (address.isEmpty) return;
    final encoded = Uri.encodeComponent(address);
    await launchUrl(
      Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded"),
      mode: LaunchMode.externalApplication,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
        return Colors.red.shade400;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PartnerDeliveryController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDeliveryDetail(deliveryId);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Text(
          "Delivery Details",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<PartnerDeliveryController>(
          builder: (ctrl) {
            if (ctrl.isDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final delivery = ctrl.selectedDelivery;
            if (delivery == null) {
              return Center(
                child: Text(
                  "Delivery not found",
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade500),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------- STATUS BANNER ----------
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: _statusColor(delivery.status).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          delivery.status == 'COMPLETED'
                              ? Icons.check_circle_outline
                              : Icons.access_time_rounded,
                          color: _statusColor(delivery.status),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${delivery.status[0]}${delivery.status.substring(1).toLowerCase()} Delivery",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                                color: _statusColor(delivery.status),
                              ),
                            ),
                            if (delivery.date.isNotEmpty)
                              Text(
                                _formattedDateTime(delivery),
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),
                  _sectionTitle("Customer"),
                  SizedBox(height: 8.h),
                  _card(
                    Row(
                      children: [
                        Container(
                          height: 40.w,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            delivery.customerName.isNotEmpty
                                ? delivery.customerName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                              if (delivery.customerPhone.isNotEmpty)
                                Text(
                                  delivery.customerPhone,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (delivery.customerPhone.isNotEmpty)
                          GestureDetector(
                            onTap: () => _call(delivery.customerPhone),
                            child: Container(
                              padding: EdgeInsets.all(9.w),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.call,
                                size: 16.sp,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  _sectionTitle("Plan & Meal"),
                  SizedBox(height: 8.h),
                  _card(
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                delivery.planName.isNotEmpty
                                    ? delivery.planName
                                    : "Plan",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                              if (delivery.mealSummary.isNotEmpty)
                                Text(
                                  delivery.mealSummary,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  _sectionTitle("Delivery Address"),
                  SizedBox(height: 8.h),
                  _card(
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                delivery.address.isNotEmpty
                                    ? delivery.address
                                    : "No address provided",
                                style: GoogleFonts.poppins(fontSize: 12.sp),
                              ),
                              if (delivery.landmark != null && delivery.landmark!.isNotEmpty)
                                Text(
                                  delivery.landmark!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openMap(delivery.address),
                          child: Text(
                            "View Map",
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (delivery.specialInstructions != null &&
                      delivery.specialInstructions!.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _sectionTitle("Special Instructions"),
                    SizedBox(height: 8.h),
                    _card(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              delivery.specialInstructions!,
                              style: GoogleFonts.poppins(fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (delivery.items.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _sectionTitle("Items to Deliver"),
                    SizedBox(height: 8.h),
                    _card(
                      Column(
                        children:
                            delivery.items.map((item) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.restaurant_outlined,
                                      size: 15.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: GoogleFonts.poppins(fontSize: 12.sp),
                                      ),
                                    ),
                                    Text(
                                      "${item.count}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  if (delivery.status != 'COMPLETED')
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton.icon(
                        onPressed:
                            ctrl.isUpdatingStatus
                                ? null
                                : () => controller.markCompleted(delivery.id),
                        icon:
                            ctrl.isUpdatingStatus
                                ? SizedBox(
                                  height: 18.h,
                                  width: 18.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(Icons.check, color: Colors.white, size: 18.sp),
                        label: Text(
                          "Mark as Completed",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formattedDateTime(PartnerDeliveryModel delivery) {
    final parsed = DateTime.tryParse(delivery.date);
    final dateStr = parsed != null ? DateFormat('dd MMM yyyy').format(parsed) : delivery.date;
    return delivery.time != null ? "$dateStr • ${delivery.time}" : dateStr;
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

*/
