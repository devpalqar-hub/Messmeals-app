import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class ExpenseCard extends StatelessWidget {
  final String title;
  final double amount;
  final double balanceDue;
  final String date;
  final String categoryName;
  final bool hasReceipt;
  final String status;
  final bool isFullyPaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRecordPayment;

  const ExpenseCard({
    super.key,
    required this.title,
    required this.amount,
    required this.balanceDue,
    required this.date,
    required this.categoryName,
    required this.hasReceipt,
    required this.status,
    required this.isFullyPaid,
    required this.onEdit,
    required this.onDelete,
    required this.onRecordPayment,
  });

  String get _formattedDate {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  Color get _statusColor {
    switch (status) {
      case "PAID":
        return AppColors.success;
      case "PARTIALLY_PAID":
        return const Color(0xFF2E86DE);
      case "PENDING":
        return AppColors.warning;
      default:
        return Colors.red.shade400;
    }
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Icon(icon, size: 17.sp, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- TITLE + AMOUNT ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "₹${amount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// ---------- BADGES ----------
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _badge(status, _statusColor),
              if (categoryName.isNotEmpty)
                _badge(categoryName, AppColors.primary),
              if (!isFullyPaid && balanceDue > 0)
                _badge(
                  "Due ₹${balanceDue.toStringAsFixed(0)}",
                  Colors.red.shade400,
                ),
            ],
          ),

          SizedBox(height: 10.h),
          Divider(height: 1, color: Colors.grey.shade100),
          SizedBox(height: 8.h),

          /// ---------- DATE + ACTIONS ----------
          Row(
            children: [
              Text(
                _formattedDate,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              ),
              if (hasReceipt) ...[
                SizedBox(width: 6.w),
                Icon(Icons.attach_file, size: 12.sp, color: Colors.grey[500]),
              ],
              const Spacer(),
              if (!isFullyPaid)
                _actionIcon(
                  icon: Icons.payments_outlined,
                  color: AppColors.success,
                  onTap: onRecordPayment,
                ),
              _actionIcon(
                icon: Icons.edit_outlined,
                color: Colors.grey.shade700,
                onTap: onEdit,
              ),
              _actionIcon(
                icon: Icons.delete_outline,
                color: Colors.red.shade400,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
