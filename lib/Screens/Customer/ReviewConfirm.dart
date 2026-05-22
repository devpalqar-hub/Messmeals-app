import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Step4ReviewConfirm extends StatefulWidget {
  const Step4ReviewConfirm({super.key});

  @override
  State<Step4ReviewConfirm> createState() =>
      _Step4ReviewConfirmState();
}

class _Step4ReviewConfirmState
    extends State<Step4ReviewConfirm> {

  Widget buildStep({
    required int number,
    required String title,
    bool completed = false,
    bool active = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor:
                    completed || active
                        ? const Color(0xff00856F)
                        : Colors.white,
                child: completed
                    ? Icon(
                        Icons.check,
                        size: 18.sp,
                        color: Colors.white,
                      )
                    : Text(
                        "$number",
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : Colors.black54,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
              ),

              if (number != 4)
                Expanded(
                  child: Container(
                    height: 2.h,
                    color: completed
                        ? const Color(
                            0xff00856F)
                        : Colors.grey.shade300,
                  ),
                )
            ],
          ),

          SizedBox(height: 8.h),

          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: active
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: active
                  ? const Color(
                      0xff00856F)
                  : Colors.black54,
            ),
          )
        ],
      ),
    );
  }

  Widget detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: 10.h),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              title,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin:
          EdgeInsets.only(bottom: 16.h),

      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                16.r),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [

          Row(
            children: [

              Container(
                padding:
                    EdgeInsets.all(
                        8.w),
                decoration:
                    BoxDecoration(
                  color:
                      iconColor.withOpacity(
                          .08),
                  borderRadius:
                      BorderRadius
                          .circular(
                              8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Text(
                title,
                style: TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),

              const Spacer(),

              Icon(
                Icons.edit_outlined,
                color:
                    const Color(
                        0xff00856F),
                size: 18.sp,
              ),

              SizedBox(width: 5.w),

              Text(
                "Edit",
                style: TextStyle(
                  color:
                      const Color(
                          0xff00856F),
                  fontSize: 13.sp,
                  fontWeight:
                      FontWeight.w600,
                ),
              )
            ],
          ),

          SizedBox(height: 20.h),

          ...children
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(
                    horizontal:
                        18.w),

            child: Column(
              children: [

                SizedBox(
                    height: 10.h),

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
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .w700,
                            fontSize:
                                20.sp,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                        width:
                            24.w)
                  ],
                ),

                SizedBox(
                    height:
                        30.h),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    buildStep(
                      number: 1,
                      title:
                          "Basic Info",
                      completed:
                          true,
                    ),

                    buildStep(
                      number: 2,
                      title:
                          "Plan & Wallet",
                      completed:
                          true,
                    ),

                    buildStep(
                      number: 3,
                      title:
                          "Schedule",
                      completed:
                          true,
                    ),

                    buildStep(
                      number: 4,
                      title:
                          "Review",
                      active:
                          true,
                    ),
                  ],
                ),

                SizedBox(
                    height:
                        35.h),

                Row(
                  children: [

                    Container(
                      padding:
                          EdgeInsets.all(
                              12.w),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                                0xffEEF8F6),
                        borderRadius:
                            BorderRadius.circular(
                                12.r),
                      ),
                      child: Icon(
                        Icons
                            .assignment_outlined,
                        color:
                            const Color(
                                0xff00856F),
                      ),
                    ),

                    SizedBox(
                        width:
                            14.w),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        Text(
                          "Review Details",
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
                                4.h),

                        Text(
                          "Please review all details before adding customer",
                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                            fontSize:
                                13.sp,
                          ),
                        )
                      ],
                    )
                  ],
                ),

                SizedBox(
                    height:
                        25.h),

                infoCard(
                  icon:
                      Icons.person_outline,
                  iconColor:
                      const Color(
                          0xff00856F),
                  title:
                      "Basic Information",
                  children: [

                    detailRow(
                        "Name",
                        "test"),
                    detailRow(
                        "Phone",
                        "+91 98765 43210"),
                    detailRow(
                        "Email",
                        "tes.com"),
                    detailRow(
                        "Address",
                        "123, ABC Street, City, State - 000001"),
                    detailRow(
                        "Location",
                        "Using current location"),
                  ],
                ),

                infoCard(
                  icon:
                      Icons.calendar_month,
                  iconColor:
                      const Color(
                          0xff00856F),
                  title:
                      "Plan & Subscription",
                  children: [

                    detailRow(
                        "Meal Plan",
                        "Premium Plan"),
                    detailRow(
                        "Start Date",
                        "01 May 2024"),
                    detailRow(
                        "End Date",
                        "01 Aug 2024"),
                    detailRow(
                        "Delivery Partner",
                        "Rishaan Delivery"),
                  ],
                ),

                infoCard(
                  icon:
                      Icons.wallet_outlined,
                  iconColor:
                      Colors.orange,
                  title:
                      "Wallet & Discount",
                  children: [

                    detailRow(
                        "Wallet Amount",
                        "₹ 1,000"),
                    detailRow(
                        "Discount Amount",
                        "₹ 100"),
                  ],
                ),

                infoCard(
                  icon:
                      Icons.calendar_today,
                  iconColor:
                      const Color(
                          0xff00856F),
                  title:
                      "Schedule Delivery",
                  children: [

                    detailRow(
                        "Delivery Type",
                        "Custom"),
                    detailRow(
                        "Delivery Days",
                        "Mon, Tue, Wed, Fri, Sat"),
                    detailRow(
                        "Preferred Time",
                        "08:00 AM - 10:00 AM"),
                  ],
                ),

                SizedBox(
                    height:
                        15.h),

                SizedBox(
                  width:
                      double.infinity,
                  height:
                      58.h,
                  child:
                      ElevatedButton(
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                              0xff00856F),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12.r),
                      ),
                    ),
                    onPressed:
                        () {},

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [

                        Text(
                          "Add Customer",
                          style:
                              TextStyle(
                            color:
                                Colors
                                    .white,
                            fontSize:
                                16.sp,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        SizedBox(
                            width:
                                8.w),

                        Icon(
                          Icons
                              .check_circle_outline,
                          color: Colors
                              .white,
                          size: 20.sp,
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(
                    height:
                        30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}