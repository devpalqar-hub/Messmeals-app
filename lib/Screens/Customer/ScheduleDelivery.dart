import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Customer/ReviewConfirm.dart';

class Step3ScheduleDelivery extends StatefulWidget {
  const Step3ScheduleDelivery({super.key});

  @override
  State<Step3ScheduleDelivery> createState() =>
      _Step3ScheduleDeliveryState();
}

class _Step3ScheduleDeliveryState
    extends State<Step3ScheduleDelivery> {

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

  String deliveryType = "Custom";
  String preferredTime = "";

  Widget buildStep({
    required int number,
    required String title,
    bool active = false,
    bool completed = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: completed || active
                    ? const Color(0xff0B8B7E)
                    : Colors.white,
                child: completed
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18.sp,
                      )
                    : Text(
                        "$number",
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              if (number != 4)
                Expanded(
                  child: Container(
                    height: 2,
                    color: completed
                        ? const Color(0xff0B8B7E)
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: active
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: active
                  ? const Color(0xff0B8B7E)
                  : Colors.black54,
            ),
          )
        ],
      ),
    );
  }

  Widget dayChip(String day) {
    bool selected = selectedDays.contains(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
          }
        });
      },
      child: Container(
        width: 74.w,
        height: 48.h,
        margin: EdgeInsets.only(
          right: 10.w,
          bottom: 14.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xffF2FAF8)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(16.r),
          border: Border.all(
            color: selected
                ? const Color(0xff0B8B7E)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            if (selected)
              Container(
                width: 20.w,
                height: 20.w,
                decoration: const BoxDecoration(
                  color: Color(0xff0B8B7E),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 14.sp,
                  color: Colors.white,
                ),
              ),
            if (selected)
              SizedBox(width: 8.w),
            Text(
              day,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget dropdownBox({
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 58.h,
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xff0B8B7E),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 20.w),

          child: Column(
            children: [

              SizedBox(height: 10.h),

              Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 24.sp,
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        "Add Customer",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 25.w)
                ],
              ),

              SizedBox(height: 35.h),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  buildStep(
                    number: 1,
                    title: "Basic Info",
                    completed: true,
                  ),

                  buildStep(
                    number: 2,
                    title: "Plan & Wallet",
                    completed: true,
                  ),

                  buildStep(
                    number: 3,
                    title: "Schedule",
                    active: true,
                  ),

                  buildStep(
                    number: 4,
                    title: "Review",
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18.w),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              18.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Row(
                          children: [
                            Container(
                              padding:
                                  EdgeInsets.all(
                                      12.w),
                              decoration:
                                  BoxDecoration(
                                color: const Color(
                                        0xffEEF8F6)
                                    ,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            14.r),
                              ),
                              child: Icon(
                                Icons
                                    .calendar_month_outlined,
                                color:
                                    const Color(
                                        0xff0B8B7E),
                              ),
                            ),

                            SizedBox(
                                width: 14.w),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  "Schedule Delivery",
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    fontSize:
                                        22.sp,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        5.h),
                                Text(
                                  "Set delivery schedule and preferences",
                                  style:
                                      TextStyle(
                                    fontSize:
                                        13.sp,
                                    color: Colors
                                        .grey,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),

                        SizedBox(height: 30.h),

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
                          text: "Custom",
                        ),

                        SizedBox(height: 25.h),

                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w600),
                            children: [
                              const TextSpan(
                                  text:
                                      "Select Delivery Days"),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.sp,
                                ),
                              )
                            ],
                          ),
                        ),

                        SizedBox(height: 18.h),

                        Wrap(
                          children: days
                              .map((e) =>
                                  dayChip(e))
                              .toList(),
                        ),

                        SizedBox(height: 20.h),

                        Text(
                          "Preferred Time (Optional)",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        dropdownBox(
                          icon:
                              Icons.access_time,
                          text:
                              "Select preferred time slot",
                        ),

                        SizedBox(height: 25.h),

                        Container(
                          padding:
                              EdgeInsets.all(
                                  16.w),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                                0xffF7FAF9),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        14.r),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Icon(
                                Icons.info_outline,
                                color:
                                    const Color(
                                        0xff0B8B7E),
                              ),

                              SizedBox(
                                  width: 12.w),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
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
                                      "Orders will be scheduled on the selected days at the preferred time.",
                                      style:
                                          TextStyle(
                                        color: Colors
                                            .black54,
                                        fontSize:
                                            13.sp,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              SizedBox(
                width: double.infinity,
                height: 58.h,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                            0xff00856F),
                    elevation: 4,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              14.r),
                    ),
                  ),
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder:   (context) => const Step4ReviewConfirm(),),);},
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}