import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/SubscriptionScreen/Controller/SubscriptionControllrer.dart';
import 'package:mess/Screens/Utils/Colors.dart';

Widget NextBillCard() {
  SubscriptionControllrer sctrl = Get.find();
  return _BaseCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60.w,
              width: 60.w,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Very light gray/blue
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Icon(
                Icons.calendar_today,
                color: PrimaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Bill',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  Text(
                    'Bill will be generated based on last month usage',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildBillStat(
                'Billing Date\n(Next Cycle)',
                DateFormat("dd MMM y").format(
                  DateTime.parse(
                    sctrl.billingModel!.currentPeriod!.dueDate!,
                  ).toLocal(),
                ),
              ),
            ),
            _buildDividerVertical(),
            Expanded(
              child: _buildBillStat(
                'Customers\n(Last Month)',
                (sctrl.billingModel!.customerCount ?? "0").toString(),
              ),
            ),
            _buildDividerVertical(),
            Expanded(
              child: _buildBillStat(
                'Amount\n(To Be Paid)',
                ((sctrl.billingModel!.amount ?? 0)).toStringAsFixed(2),
                isAmount: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        // Info Banner
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: PrimaryColor, size: 16.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Bill generated on ${DateFormat('dd MMM yyyy').format(DateTime.parse(sctrl.billingModel!.nextBillingDate!).toLocal())}. Please pay before ${DateFormat('dd MMM yyyy').format(DateTime.parse(sctrl.billingModel!.nextDueDate!).toLocal())} to avoid service interruption.',
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: textLight),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Pay Button
        if (sctrl.billingModel!.messStatus != "ACTIVE") ...[
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: PrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Pay Bill',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

// --- Reusable Card Container ---
class _BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _BaseCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

Widget _buildBillStat(String label, String value, {bool isAmount = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          color: textLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(height: 6.h),
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: isAmount ? 16.sp : 13.sp,
          fontWeight: FontWeight.w600,
          color: isAmount ? primaryTeal : textDark,
        ),
      ),
    ],
  );
}

Widget _buildDividerVertical() {
  return Container(height: 30.h, width: 1, color: const Color(0xFFE2E8F0));
}
