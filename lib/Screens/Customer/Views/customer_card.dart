import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mess/Screens/Customer/Views/CustoemrDetailScreen.dart';
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
    return Dismissible(
      // BUG #2426 — swipe left to delete
      key: Key(customer.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _confirmDelete(context);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontSize: 11.sp),
            ),
          ],
        ),
      ),
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
            /// Avatar
            Container(
              height: 40.h,
              width: 40.w,
              decoration: const BoxDecoration(
                color: Color(0xffe8f5ef),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),

            SizedBox(width: 16),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Color(0xff6b7280),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xff4b5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // BUG #2439
                  Text(
                    "Member: ${_memberSince()}",
                    style: TextStyle(
                      fontSize: 11.sp,
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
                  (_) => const [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 8),
                          Text("View Details"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),

            /// Arrow — original behaviour
            InkWell(
              onTap: () {
                Get.to(() => CustomerDetailScreen(customerId: customer.id));
              },
              child: const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xff111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
