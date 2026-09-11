// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mess/Screens/DeliveryPartner/Customers/Models/PartnerCustomerModel.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Models/PartnerDeliveryModel.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Service/PartnerDeliveryController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class CustomerDetailScreen extends StatefulWidget {
  final PartnerCustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool showHistory = true;

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

  @override
  Widget build(BuildContext context) {
    final deliveryController = Get.find<PartnerDeliveryController>();
    final customer = widget.customer;

    final history =
        deliveryController.deliveries.where((d) => d.customerId == customer.id).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Text(
          "Customer Details",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- CUSTOMER CARD ----------
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 52.w,
                          width: 52.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                              if (customer.phone.isNotEmpty)
                                Text(
                                  customer.phone,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (customer.phone.isNotEmpty)
                          GestureDetector(
                            onTap: () => _call(customer.phone),
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.call, color: Colors.white, size: 16.sp),
                            ),
                          ),
                      ],
                    ),
                    if (customer.address.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              customer.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openMap(customer.address),
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
                    ],
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              if (customer.planName.isNotEmpty) ...[
                Text(
                  "Subscription Plan",
                  style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 10.w),
                      Text(
                        customer.planName,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],

              /// ---------- TABS ----------
              Row(
                children: [
                  Expanded(child: _tabButton("Delivery History", showHistory, () => setState(() => showHistory = true))),
                  SizedBox(width: 8.w),
                  Expanded(child: _tabButton("Details", !showHistory, () => setState(() => showHistory = false))),
                ],
              ),

              SizedBox(height: 14.h),

              if (showHistory)
                if (history.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      "No delivery history yet",
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade500),
                    ),
                  )
                else
                  ...history.map((d) => _HistoryTile(delivery: d))
              else
                _detailsSection(customer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailsSection(PartnerCustomerModel customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailRow(Icons.person_outline, "Name", customer.name),
        _detailRow(Icons.phone_outlined, "Phone", customer.phone),
        _detailRow(Icons.location_on_outlined, "Address", customer.address),
        if (customer.landmark != null && customer.landmark!.isNotEmpty)
          _detailRow(Icons.flag_outlined, "Landmark", customer.landmark!),
        _detailRow(Icons.card_membership_outlined, "Plan", customer.planName),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade500),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey.shade500),
                ),
                Text(value, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PartnerDeliveryModel delivery;

  const _HistoryTile({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final isCompleted = delivery.status == 'COMPLETED';
    final isCancelled = delivery.status == 'CANCELLED';
    final color =
        isCompleted ? AppColors.success : (isCancelled ? Colors.red.shade400 : AppColors.warning);
    final parsed = DateTime.tryParse(delivery.date);
    final dateStr = parsed != null ? DateFormat('dd MMM yyyy').format(parsed) : delivery.date;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle
                : (isCancelled ? Icons.cancel : Icons.access_time_filled),
            size: 18.sp,
            color: color,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              dateStr,
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            delivery.mealSummary.isNotEmpty ? delivery.mealSummary : delivery.status,
            style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade600),
          ),
          if (delivery.time != null) ...[
            SizedBox(width: 8.w),
            Text(
              delivery.time!,
              style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}

*/
