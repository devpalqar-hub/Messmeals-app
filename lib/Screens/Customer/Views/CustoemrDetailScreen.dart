import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
  });

  String formatDate(DateTime date) {
    return DateFormat("MMM d, yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(
      builder: (controller) {
        final current = controller.customers.any(
          (e) => e.id == customer.id,
        )
            ? controller.customers.firstWhere(
                (e) => e.id == customer.id,
              )
            : customer;

        final activeSub =
            current.activeSubscriptions.isNotEmpty
                ? current.activeSubscriptions.first
                : null;

        final remainingDays = activeSub != null
            ? activeSub.endDate
                .difference(DateTime.now())
                .inDays
            : 0;

        return Scaffold(
          backgroundColor: const Color(0xffF5F7FB),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),

              child: Column(
                children: [

                  /// HEADER
                  Row(
                    children: [

                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24.sp,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "Customer Details",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _headerButton(
                        Icons.edit_outlined,
                        Colors.teal,
                      ),

                      SizedBox(width: 8.w),

                      _headerButton(
                        Icons.delete_outline,
                        Colors.red,
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  /// PROFILE CARD
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        /// LEFT SIDE
                        ClipRRect(
                          borderRadius:
                              BorderRadius.only(
                            topLeft:
                                Radius.circular(20.r),
                            bottomLeft:
                                Radius.circular(20.r),
                          ),

                          child: Container(
                            width: 120.w,
                            height: 255.h,

                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin:
                                    Alignment.topLeft,
                                end:
                                    Alignment.bottomRight,
                                colors: [
                                  Color(0xff16D4D4),
                                  Color(0xff0096DB),
                                ],
                              ),
                            ),

                            child: Stack(
                              alignment:
                                  Alignment.center,
                              children: [

                                Positioned(
                                  top: 45.h,
                                  child: Stack(
                                    children: [

                                      CircleAvatar(
                                        radius: 40.r,
                                        backgroundColor:
                                            Colors.white,
                                        child: Text(
                                          current.name
                                              .substring(0, 2)
                                              .toUpperCase(),

                                          style: TextStyle(
                                            fontSize: 26.sp,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        right: 2,
                                        bottom: 2,
                                        child: Container(
                                          height: 15,
                                          width: 15,

                                          decoration:
                                              BoxDecoration(
                                            color:
                                                Colors.green,
                                            shape:
                                                BoxShape.circle,
                                            border:
                                                Border.all(
                                              color:
                                                  Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Positioned(
                                  bottom: 25.h,
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.white24,
                                      borderRadius:
                                          BorderRadius.circular(
                                              20.r),
                                    ),

                                    child: Text(
                                      "Active",
                                      style: TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        /// RIGHT DETAILS
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.all(12.w),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  current.name,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 10.h),

                                _infoRow(
                                  Icons.phone,
                                  current.phone,
                                ),

                                Divider(),

                                _infoRow(
                                  Icons.email_outlined,
                                  current.email,
                                ),

                                Divider(),

                                _infoRow(
                                  Icons.location_on_outlined,
                                  current.address,
                                ),

                                Divider(),

                                Row(
                                  children: [

                                    Expanded(
                                      child: _smallInfo(
                                        Icons.wallet,
                                        Colors.green,
                                        "Wallet",
                                        "Active",
                                      ),
                                    ),

                                    Expanded(
                                      child: _smallInfo(
                                        Icons.calendar_today,
                                        Colors.blue,
                                        "Joined",
                                        "Jun 7",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// STATS
                  Row(
                    children: [

                      Expanded(
                        child: _statCard(
                          Icons.account_balance_wallet,
                          Colors.green,
                          "Wallet",
                          "₹${current.walletBalance}",
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Expanded(
                        child: _statCard(
                          Icons.shopping_bag,
                          Colors.blue,
                          "Orders",
                          "${current.totalOrders}",
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Expanded(
                        child: _statCard(
                          Icons.currency_rupee,
                          Colors.purple,
                          "Spent",
                          "₹${current.totalSpent ?? 0}",
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Expanded(
                        child: _statCard(
                          Icons.timer,
                          Colors.orange,
                          "Days",
                          "$remainingDays",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  /// SUBSCRIPTION
                  if (activeSub != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.w),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(26.r),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          /// HEADER
                          Row(
                            children: [

                              Text(
                                "Subscription Details",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const Spacer(),

                              Container(
                                padding:
                                    EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 5.h,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.green.shade50,
                                  borderRadius:
                                      BorderRadius.circular(
                                          30.r),
                                ),

                                child: Text(
                                  "ACTIVE",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 22.h),

                          /// TOP
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              /// ICON
                              Container(
                                width: 58.w,
                                height: 58.w,

                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xffEEF9F1),
                                  shape: BoxShape.circle,
                                ),

                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.green,
                                  size: 28.sp,
                                ),
                              ),

                              SizedBox(width: 14.w),

                              /// PLAN INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(
                                      "Current Plan",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.sp,
                                      ),
                                    ),

                                    SizedBox(height: 4.h),

                                    Text(
                                      activeSub.plan.name,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 8.h),

                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(0xffEEF9F1),
                                        borderRadius:
                                            BorderRadius.circular(
                                                30.r),
                                      ),

                                      child: Text(
                                        "Lunch",
                                        style: TextStyle(
                                          color:
                                              Colors.green,
                                          fontWeight:
                                              FontWeight.w600,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                           
                            ],
                          ),

                          SizedBox(height: 22.h),

                          Divider(
                            color: Colors.grey.shade200,
                          ),

                          SizedBox(height: 22.h),

                          /// DETAILS
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Expanded(
                                child: Column(
                                  children: [

                                    Row(
                                      children: [

                                        Expanded(
                                          child: _detailTile(
                                            Icons
                                                .calendar_month_outlined,
                                            "Start Date",
                                            formatDate(
                                                activeSub
                                                    .startDate),
                                          ),
                                        ),

                                        SizedBox(width: 15.w),

                                        Expanded(
                                          child: _detailTile(
                                            Icons
                                                .calendar_today_outlined,
                                            "End Date",
                                            formatDate(
                                                activeSub
                                                    .endDate),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 18.h),

                                    Row(
                                      children: [

                                        Expanded(
                                          child: _detailTile(
                                            Icons.map_outlined,
                                            "Plan Variations",
                                            "Lunch",
                                          ),
                                        ),

                                        SizedBox(width: 15.w),

                                        Expanded(
                                          child: _detailTile(
                                             Icons.person_outline,
                                            "Delivery Partner",
                                            "Partner A",
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 18.h),

                                    Row(
                                      children: [

                                        Expanded(
                                          child: _detailTile(
                                            Icons
                                                .calendar_view_week,
                                            "Delivery Days",
                                            "Mon, Tue, Wed, Thu, Fri",
                                          ),
                                        ),

                                        SizedBox(width: 15.w),

                                       
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 16.w),

                              /// CIRCLE
                              SizedBox(
                                width: 120.w,
                                height: 120.w,

                                child: Stack(
                                  alignment: Alignment.center,

                                  children: [

                                    SizedBox(
                                      width: 100.w,
                                      height: 100.w,

                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 10,
                                        value:
                                            (remainingDays / 60)
                                                .clamp(
                                                    0.0,
                                                    1.0),

                                        strokeCap:
                                            StrokeCap.round,

                                        backgroundColor:
                                            Colors.green
                                                .shade50,

                                        color: Colors.green,
                                      ),
                                    ),

                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,

                                      children: [

                                        Text(
                                          "$remainingDays",
                                          style: TextStyle(
                                            fontSize: 32.sp,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          "Days Left",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 28.h),

                          /// STATUS LINE
                          Row(
                            children: [

                              _statusItem(
                                true,
                                "Started",
                                formatDate(
                                    activeSub.startDate),
                              ),

                              Expanded(
                                child: Container(
                                  margin:
                                      EdgeInsets.only(
                                          bottom: 38.h),
                                  height: 3,
                                  color: Colors.green,
                                ),
                              ),

                              _statusItem(
                                true,
                                "Running",
                                "Active",
                              ),

                              Expanded(
                                child: Container(
                                  margin:
                                      EdgeInsets.only(
                                          bottom: 38.h),
                                  height: 3,
                                  color:
                                      Colors.grey.shade300,
                                ),
                              ),

                              _statusItem(
                                false,
                                "Renewal Due",
                                formatDate(
                                    activeSub.endDate),
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),

                       /// ACTIVE BOX
Container(
  width: double.infinity,
  padding: EdgeInsets.all(18.w),

  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xffEEF9F1),
        Color(0xffF8FFFA),
      ],
    ),

    borderRadius: BorderRadius.circular(18.r),
  ),

  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// LEFT ICON
      Container(
        width: 52.w,
        height: 52.w,

        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 6,
            ),
          ],
        ),

        child: Icon(
          Icons.sync,
          color: Colors.green,
          size: 24.sp,
        ),
      ),

      SizedBox(width: 14.w),

      /// TEXT SECTION
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(top: 2.h),

          child: Column(
           
            

            children: [

              Text(
                "Your subscription is active",

                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                 
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                "Renew before ${formatDate(activeSub.endDate)}",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 11.5.sp,
                 
                ),
              ),
            ],
          ),
        ),
      ),

      SizedBox(width: 12.w),

      /// BUTTON TOP RIGHT
      Align(
        alignment: Alignment.topRight,

        child: Container(
          margin: EdgeInsets.only(top: 2.h),

          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 12.h,
          ),

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff00B86B),
                Color(0xff00A862),
              ],
            ),

            borderRadius:
                BorderRadius.circular(14.r),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.green.withOpacity(.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [

              Text(
                "Renew",

                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  height: 1,
                ),
              ),

              SizedBox(width: 7.w),

              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

                          SizedBox(height: 22.h),

                          /// ACTIONS
                          Row(
                            children: [

                              Expanded(
                                child: _bottomActionCard(
                                  Icons.pause_circle_outline,
                                  "Pause Subscription",
                                  "Temporarily pause deliveries",
                                  Colors.orange,
                                  const Color(0xffFFF8F1),
                                ),
                              ),

                              SizedBox(width: 14.w),

                              Expanded(
                                child: _bottomActionCard(
                                  Icons.cancel_outlined,
                                  "Cancel Subscription",
                                  "Permanently cancel subscription",
                                  Colors.red,
                                  const Color(0xffFFF5F5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// HEADER BUTTON
  Widget _headerButton(
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),

      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius:
            BorderRadius.circular(12.r),
      ),

      child: Icon(
        icon,
        size: 18.sp,
        color: color,
      ),
    );
  }

  /// INFO ROW
  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 6.h,
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(7),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(8),
            ),

            child: Icon(
              icon,
              size: 16,
              color: Colors.grey[700],
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SMALL INFO
  Widget _smallInfo(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Row(
      children: [

        Container(
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: color.withOpacity(.1),
            borderRadius:
                BorderRadius.circular(10),
          ),

          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),

        SizedBox(width: 10.w),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.sp,
              ),
            ),

            SizedBox(height: 4),

            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// STATS
  Widget _statCard(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 6.w,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15.r),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.03),
            blurRadius: 5,
          )
        ],
      ),

      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(6),

            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: color,
              size: 16.sp,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// DETAIL TILE
  Widget _detailTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Icon(
          icon,
          size: 20.sp,
          color: Colors.grey.shade600,
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// STATUS ITEM
  Widget _statusItem(
    bool active,
    String title,
    String subtitle,
  ) {
    return Column(
      children: [

        Container(
          width: active ? 24.w : 20.w,
          height: active ? 24.w : 20.w,

          decoration: BoxDecoration(
            color:
                active
                    ? Colors.green
                    : Colors.grey.shade300,

            shape: BoxShape.circle,

            border:
                title == "Running"
                    ? Border.all(
                        color:
                            Colors.green.shade100,
                        width: 5,
                      )
                    : null,
          ),

          child:
              title == "Started"
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14.sp,
                    )
                  : null,
        ),

        SizedBox(height: 6.h),

        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  /// ACTION CARD
  Widget _bottomActionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(18.r),

        border: Border.all(
          color: color.withOpacity(.2),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 25.w,
            height: 25.w,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),

            child: Icon(
              icon,
              color: color,
              size: 12.sp,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 4.h),

                
              ],
            ),
          ),
        ],
      ),
    );
  }
}