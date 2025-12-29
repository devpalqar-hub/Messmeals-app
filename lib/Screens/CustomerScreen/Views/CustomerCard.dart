import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
import 'package:mess/Screens/CustomerScreen/Views/CustomerDetailScreen.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const CustomerCard({
    super.key,
    required this.customer,
    
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerController>();

    final plan = customer.activeSubscriptions.isNotEmpty
        ? customer.activeSubscriptions.first.plan.name
        : "No Plan";

    final startDate = customer.activeSubscriptions.isNotEmpty
        ? customer.activeSubscriptions.first.startDate
        : null;

    final endDate = customer.activeSubscriptions.isNotEmpty
        ? customer.activeSubscriptions.first.endDate
        : null;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailScreen(customer: customer),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- NAME + ACTIONS ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  customer.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    /// ---- Edit Button ----
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCustomerScreen(
                              customer: customer, // Pass customer for edit
                              isEdit: true, // Flag to handle edit
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_note,
                          size: 22, color: Colors.black),
                      tooltip: "Edit",
                    ),

                    /// ---- Delete Button ----
                    IconButton(
                      onPressed: () {
                        _showDeleteDialog(context, controller);
                      },
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      tooltip: "Delete",
                    ),

                    /// ---- View Details ----
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CustomerDetailScreen(customer: customer),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chevron_right,
                          size: 22, color: Colors.black),
                      tooltip: "View Details",
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 6.h),

            /// ---------- CONTACT ----------
            Text(
              customer.phone,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            Text(
              customer.email,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),

            SizedBox(height: 10.h),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: 8.h),

            /// ---------- WALLET + PLAN ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(
                    title: "WALLET",
                    value: "₹${customer.walletBalance.toStringAsFixed(0)}"),
                _InfoItem(title: "PLAN", value: plan),
              ],
            ),

            SizedBox(height: 10.h),

            /// ---------- DATES ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(
                    title: "START DATE",
                    value: startDate != null
                        ? "${startDate.day}/${startDate.month}/${startDate.year}"
                        : "-"),
                _InfoItem(
                    title: "END DATE",
                    value: endDate != null
                        ? "${endDate.day}/${endDate.month}/${endDate.year}"
                        : "-"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Delete Confirmation Dialog
  void _showDeleteDialog(BuildContext context, CustomerController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Customer"),
        content: Text(
            "Are you sure you want to delete ${customer.name}? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteCustomer(customer.customerProfileId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
