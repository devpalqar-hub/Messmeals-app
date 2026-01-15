import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentDeliveriesSection extends StatelessWidget {
  final List<Map<String, String>> deliveries;

  const RecentDeliveriesSection({
    super.key,
    required this.deliveries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Text(
            "Recent Deliveries",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
          SizedBox(height: 12.h),

          ...deliveries.map((delivery) {
            bool isCompleted = delivery["status"]!.toLowerCase() == "completed";
            Color bgColor =
                isCompleted ? const Color(0xffE9F9EE) : const Color(0xffFDF7E7);
            Color textColor = isCompleted ? Colors.green : Colors.orange;

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      delivery["status"]!,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 50.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery["deliveryId"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter",
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          delivery["date"]!,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13.sp,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    delivery["amount"]!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
