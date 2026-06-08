import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class ReviewWidget extends StatelessWidget {
  // Basic info
  final String name;
  final String phone;
  final String email;
  final String address;
  final String location;

  // Plan & Schedule details
  final String mealPlan;
  final String startDate;
  final String endDate;
  final String deliveryPartner;
  final String deliveryType;
  final List<String> deliveryDays;
  final String preferredTime;

  // Wallet details
  final String walletAmount;
  final String discountAmount;
  final Function(int editvalue) ChangeStep;

  const ReviewWidget({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.location,
    required this.mealPlan,
    required this.startDate,
    required this.endDate,
    required this.deliveryPartner,
    required this.deliveryType,
    required this.deliveryDays,
    required this.preferredTime,
    required this.walletAmount,
    required this.discountAmount,
    required this.ChangeStep,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF8F6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Review Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Please review all details before adding customer",
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),

          /// BASIC INFO
          infoCard(
            icon: Icons.person_outline,
            iconColor: const Color(0xff00856F),
            title: "Basic Information",
            children: [
              detailRow("Name", name),
              detailRow("Phone", phone),
              detailRow("Email", email.isEmpty ? "-" : email),
              detailRow("Address", address),

              //  detailRow("Location", location.isEmpty ? "-" : location),
            ],
            onEditClick: () {
              ChangeStep(1);
            },
          ),

          /// PLAN & SCHEDULE
          infoCard(
            icon: Icons.calendar_month,
            iconColor: const Color(0xff00856F),
            title: "Plan & Schedule",
            children: [
              detailRow("Meal Plan", mealPlan.isEmpty ? "-" : mealPlan),
              detailRow(
                "Start Date",
                startDate.isEmpty
                    ? "-"
                    : DateFormat(
                      "dd-MMM-yyyy",
                    ).format(DateTime.parse(startDate)),
              ),
              detailRow(
                "End Date",
                endDate.isEmpty
                    ? "-"
                    : DateFormat("dd-MMM-yyyy").format(DateTime.parse(endDate)),
              ),
              detailRow(
                "Delivery Partner",
                deliveryPartner.isEmpty ? "-" : deliveryPartner,
              ),
              SizedBox(height: 8.h),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 8.h),
              detailRow(
                "Delivery Type",
                deliveryType.isEmpty ? "-" : deliveryType,
              ),
              detailRow(
                "Delivery Days",
                deliveryDays.isEmpty ? "-" : deliveryDays.join(", "),
              ),
            ],
            onEditClick: () {
              ChangeStep(2);
            },
          ),

          /// WALLET
          infoCard(
            icon: Icons.wallet_outlined,
            iconColor: Colors.orange,
            title: "Wallet & Discount",
            children: [
              detailRow("Wallet Amount", "₹$walletAmount"),
              detailRow("Discount Amount", "₹$discountAmount"),
            ],
            onEditClick: () {
              ChangeStep(2);
            },
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  static Widget detailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  static Widget infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,

    Function? onEditClick,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (onEditClick != null) {
                    onEditClick();
                  }
                },
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }
}
