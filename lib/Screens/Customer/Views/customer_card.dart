import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/Customer/Views/CustomerDetailScreen.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final String name;
  final String phone;
  final String initials;

  const CustomerCard({
    super.key,
    required this.name,
    required this.phone,
    required this.initials,
    required this.customer,
  });

  // BUG #2439 — real member-since using actual DateTime from model
  String _memberSince() {
    if (customer.activeSubscriptions.isEmpty) return "New member";
    final start = customer.activeSubscriptions.first.startDate;
    final now = DateTime.now();
    final months = (now.year - start.year) * 12 + (now.month - start.month);
    if (months <= 0) return "New member";
    if (months == 1) return "1 month";
    return "$months months";
  }

  /// Current plan name, if the customer has an active subscription.
  String? get _currentPlanName {
    if (customer.activeSubscriptions.isEmpty) return null;
    return customer.activeSubscriptions.first.plan.name;
  }

  // BUG #2426 — confirm delete dialog
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: const Text("Delete Customer"),
            content: Text("Are you sure you want to delete $name?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      // Use Get.find via the instance extension import
      final ctrl = Get.find<CustomerController>();
      await ctrl.deleteCustomer(customer.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () {
        Get.to(() => CustomerDetailScreen(customerId: customer.id));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xffececec)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Avatar — dimmed when the customer is inactive
            Container(
              height: 40.h,
              width: 40.w,
              decoration: BoxDecoration(
                color:
                    customer.isActive
                        ? const Color(0xffe8f5ef)
                        : const Color(0xfff3f4f6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  color:
                      customer.isActive
                          ? AppColors.primary
                          : const Color(0xff9ca3af),
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),

            SizedBox(width: 14.w),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff111827),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _StatusPill(isActive: customer.isActive),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Color(0xff6b7280),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        phone,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5.sp,
                          color: const Color(0xff4b5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu_rounded,
                        size: 13.sp,
                        color: const Color(0xff9ca3af),
                      ),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: Text(
                          _currentPlanName ?? "No active plan",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                _currentPlanName != null
                                    ? const Color(0xff374151)
                                    : const Color(0xff9ca3af),
                          ),
                        ),
                      ),
                      if (_currentPlanName != null && customer.daysLeft > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            "${customer.daysLeft}d left",
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // BUG #2439
                  Text(
                    "Member since ${_memberSince()} · ${customer.totalOrders} orders",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: const Color(0xff9ca3af),
                    ),
                  ),
                ],
              ),
            ),

            // BUG #2426 — popup menu with delete
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: Color(0xff6b7280),
              ),
              onSelected: (value) {
                if (value == 'view') {
                  Get.to(() => CustomerDetailScreen(customerId: customer.id));
                } else if (value == 'delete') {
                  _confirmDelete(context);
                }
              },
              itemBuilder:
                  (_) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 8.w),
                          Text("View Details", style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "Delete",
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),

            /// Arrow — the whole card is tappable now, kept as a visual hint
            const Icon(Icons.chevron_right, size: 20, color: Color(0xff111827)),
          ],
        ),
      ),
    );
  }
}

/// Small "Active" / "Inactive" status pill, matching PartnerCard's style.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color:
            isActive ? const Color(0xFFE4F3E8) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: GoogleFonts.poppins(
          color: isActive ? const Color(0xFF4CB051) : const Color(0xFF9CA3AF),
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
