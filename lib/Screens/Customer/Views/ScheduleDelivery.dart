import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class ScheduleDeliveryWidget extends StatefulWidget {
  const ScheduleDeliveryWidget({super.key});

  @override
  State<ScheduleDeliveryWidget> createState() =>
      _ScheduleDeliveryWidgetState();
}

class _ScheduleDeliveryWidgetState
    extends State<ScheduleDeliveryWidget> {
  List<String> days = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
  ];

  List<String> selectedDays = [
    "Mon",
    "Tue",
    "Wed",
    "Fri",
    "Sat"
  ];

 List<String> deliveryTypes = [
  "Custom",
  "Everyday",
];

List<String> preferredTimes = [
  "08:00 AM - 10:00 AM",
  "10:00 AM - 12:00 PM",
  "12:00 PM - 02:00 PM",
  "02:00 PM - 04:00 PM",
  "04:00 PM - 06:00 PM",
];

String? deliveryType;
String? preferredTime;



  @override
  Widget build(BuildContext context) {
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
                  borderRadius:
                      BorderRadius.circular(
                    14.r,
                  ),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Schedule Delivery",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
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
            padding:
                EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                18.r,
              ),
              border: Border.all(
                color:
                    Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Text(
                  "Scheduled Delivery Type",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                SizedBox(height: 10.h),
               dropdownBox(
  icon: Icons.repeat,
  hint: "Select delivery type",
  value: deliveryType,
  items: deliveryTypes,
  onChanged: (value) {
    setState(() {
      deliveryType = value;

      if (deliveryType == "Everyday") {
        selectedDays = [...days];
      } else {
        selectedDays = [];
      }
    });
  },
),

                SizedBox(height: 15.h),

                Text(
                  "Select Delivery Days *",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                SizedBox(height: 10.h),

                Wrap(
                  children: days
                      .map(
                        (e) =>
                            dayChip(e),
                      )
                      .toList(),
                ),

                SizedBox(height: 15.h),

                Text(
                  "Preferred Time (Optional)",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                SizedBox(height: 10.h),

               dropdownBox(
  icon: Icons.access_time,
  hint: "Select preferred time",
  value: preferredTime,
  items: preferredTimes,
  onChanged: (value) {
    setState(() {
      preferredTime = value;
    });
  },
),

                SizedBox(height: 15.h),

                Container(
                  padding:
                      EdgeInsets.all(
                    16.w,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffF7FAF9,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      10.r,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Icon(
                        Icons
                            .info_outline,
                        color:
                            AppColors
                                .primary,
                      ),

                      SizedBox(
                          width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              "Note",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            SizedBox(
                                height:
                                    8.h),

                            Text(
                              "Orders will be scheduled on selected days at the preferred time.",
                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .black54,
                                fontSize:
                                    13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget dayChip(String day) {
    bool selected =
        selectedDays.contains(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          selected
              ? selectedDays
                  .remove(day)
              : selectedDays
                  .add(day);
        });
      },
      child: Container(
        width: 65.w,
        height: 40.h,
        margin: EdgeInsets.only(
          right: 10.w,
          bottom: 14.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(
                  0xffF2FAF8)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
                  10.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey
                    .shade300,
          ),
        ),
        child: Center(
          child: Text(day),
        ),
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
    padding: EdgeInsets.symmetric(
      horizontal: 15.w,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(10.r),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
            ),

            SizedBox(width: 12.w),

            Text(
              hint,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
        ),
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    ),
  );
}}