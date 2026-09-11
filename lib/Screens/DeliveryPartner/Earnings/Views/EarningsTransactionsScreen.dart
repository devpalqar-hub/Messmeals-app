// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/DeliveryPartner/Earnings/Models/EarningsModel.dart';
import 'package:mess/Screens/DeliveryPartner/Earnings/Service/MockEarningsController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class EarningsTransactionsScreen extends StatefulWidget {
  const EarningsTransactionsScreen({super.key});

  @override
  State<EarningsTransactionsScreen> createState() => _EarningsTransactionsScreenState();
}

class _EarningsTransactionsScreenState extends State<EarningsTransactionsScreen> {
  String activeTab = 'All';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MockEarningsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Text(
          "Earnings Details",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<MockEarningsController>(
            builder: (ctrl) {
              final list =
                  activeTab == 'Paid'
                      ? ctrl.paidTransactions
                      : activeTab == 'Pending'
                      ? ctrl.pendingTransactions
                      : ctrl.transactions;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children:
                        ['All', 'Paid', 'Pending'].map((tab) {
                          final isSelected = activeTab == tab;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: GestureDetector(
                              onTap: () => setState(() => activeTab = tab),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
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
                  SizedBox(height: 16.h),
                  Expanded(
                    child:
                        list.isEmpty
                            ? Center(
                              child: Text(
                                "No transactions",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            )
                            : ListView.separated(
                              itemCount: list.length,
                              separatorBuilder: (_, __) => SizedBox(height: 8.h),
                              itemBuilder: (context, index) => _TransactionTile(tx: list[index]),
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final EarningsTransactionModel tx;

  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            height: 36.w,
            width: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              tx.customerName.isNotEmpty ? tx.customerName[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.date,
                  style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${tx.customerName} • ${tx.mealLabel}",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${tx.amount.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),
              Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: (tx.isPaid ? AppColors.success : AppColors.warning).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  tx.isPaid ? "Paid" : "Pending",
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: tx.isPaid ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

*/
