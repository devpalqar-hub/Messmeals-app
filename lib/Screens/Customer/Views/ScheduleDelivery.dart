import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class ScheduleDeliveryWidget extends StatefulWidget {
  final List<String> selectedDays;
  final String? deliveryType;
  final String? preferredTime;

  final Function(List<String>) onDaysChanged;
  final Function(String?) onTypeChanged;
  final Function(String?) onTimeChanged;

  const ScheduleDeliveryWidget({
    super.key,
    required this.selectedDays,
    required this.deliveryType,
    required this.preferredTime,
    required this.onDaysChanged,
    required this.onTypeChanged,
    required this.onTimeChanged,
  });

  @override
  State<ScheduleDeliveryWidget> createState() =>
      _ScheduleDeliveryWidgetState();
}

class _ScheduleDeliveryWidgetState extends State<ScheduleDeliveryWidget> {
  
  final List<String> days = [
  "MONDAY",
  "TUESDAY",
  "WEDNESDAY",
  "THURSDAY",
  "FRIDAY",
  "SATURDAY",
  "SUNDAY",
];

  final List<String> deliveryTypes = [
    "Custom",
    "Everyday",
  ];

 

  @override
  Widget build(BuildContext context) {
    final isEveryday = widget.deliveryType == "Everyday";

    return SingleChildScrollView(
      child: Column(
        children: [

          /// HEADER
          Row(
            children: [
              Container(
                height: 45.h,
                width: 45.w,
                decoration: BoxDecoration(
                  color: const Color(0xffE7F4F2),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Schedule Delivery",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "Set delivery schedule and preferences",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 25.h),

          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// DELIVERY TYPE
                Text(
                  "Scheduled Delivery Type",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                SizedBox(height: 10.h),

                dropdownBox(
                  icon: Icons.repeat,
                  hint: "Select delivery type",
                  value: widget.deliveryType,
                  items: deliveryTypes,
                  onChanged: (value) {
                    widget.onTypeChanged(value);

                    if (value == "Everyday") {
                      widget.onDaysChanged(List.from(days));
                    } else {
                      widget.onDaysChanged([]);
                    }

                    setState(() {});
                  },
                ),

                SizedBox(height: 15.h),

                /// DAYS (ONLY FOR CUSTOM)
                if (!isEveryday) ...[
                  Text(
                    "Select Delivery Days *",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10.h),

                  Wrap(
                    children: days.map((e) => dayChip(e)).toList(),
                  ),
                  SizedBox(height: 15.h),
                ],

                // /// TIME
                // Text(
                //   "Preferred Time (Optional)",
                //   style: TextStyle(fontWeight: FontWeight.w600),
                // ),

                SizedBox(height: 10.h),

                // dropdownBox(
                //   icon: Icons.access_time,
                //   hint: "Select preferred time",
                //   value: widget.preferredTime,
                //   items: preferredTimes,
                //   onChanged: (value) {
                //     widget.onTimeChanged(value);
                //     setState(() {});
                //   },
                // ),

                SizedBox(height: 15.h),

                /// NOTE
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xffF7FAF9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Note",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Orders will be scheduled on selected days at the preferred time.",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget dayChip(String day) {
    final selected = widget.selectedDays.contains(day);

    return GestureDetector(
      onTap: () {
        final updated = List<String>.from(widget.selectedDays);

        if (selected) {
          updated.remove(day);
        } else {
          updated.add(day);
        }

        widget.onDaysChanged(updated);
        setState(() {});
      },
      child: Container(
        width: 65.w,
        height: 40.h,
        margin: EdgeInsets.only(right: 10.w, bottom: 14.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffF2FAF8) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(child:Text(day.substring(0, 3))),// MON → Mon),
      ),
    );
  }

  Widget dropdownBox({
    required IconData icon,
    required String hint,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,

          value: items.contains(value) ? value : null,

          hint: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              SizedBox(width: 12.w),
              Text(
                hint,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ],
          ),

          icon: const Icon(Icons.keyboard_arrow_down),

          onChanged: (val) {
            onChanged(val);
            setState(() {});
          },

          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}