import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerDetailedModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart';

// ─────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────
class _C {
  static const surface = Colors.white;
  static const border = Color(0xFFEEEEF0);

  static const primary = Color(0xff07A4A5);
  static const primaryLight = Color.fromARGB(255, 228, 249, 249);
  static const primaryMid = Color.fromARGB(79, 7, 165, 165);

  static const amber = Color(0xFF854F0B);
  static const amberLight = Color(0xFFFAEEDA);
  static const amberBorder = Color(0xFFEF9F27);

  static const green = Color(0xFF3B6D11);
  static const greenLight = Color(0xFFEAF3DE);
  static const greenMid = Color(0xFF639922);

  static const red = Color(0xFFA32D2D);
  static const redLight = Color(0xFFFCEBEB);
  static const redBorder = Color(0xFFF09595);

  static const pink = Color(0xFF993556);
  static const pinkLight = Color(0xFFFBEAF0);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _isFetched = false;
  late CustomerDetailModel customer;
  late int _walletBalance;

  final List<String> _daysOfWeek = [
    "MONDAY",
    "TUESDAY",
    "WEDNESDAY",
    "THURSDAY",
    "FRIDAY",
    "SATURDAY",
    "SUNDAY",
  ];

  @override
  void initState() {
    super.initState();
    _fetchCustomer();
  }

  Future<void> _fetchCustomer() async {
    final res = await get(
      Uri.parse('$baseUrl/customer/${widget.customerId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );
    if (res.statusCode == 200) {
      customer = CustomerDetailModel.fromJson(json.decode(res.body));
      setState(() {
        _walletBalance = customer.walletBalance ?? 0;
        _isFetched = true;
      });
    }
  }

  bool isWalletLoading = false;
  Future<void> updateWalletBalance(int amount) async {
    final response = await patch(
      Uri.parse(
        '$baseUrl/customer/update-wallet/${customer.customerProfileId}',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
      body: json.encode({"amount": amount.toString()}),
    );
    if (response.statusCode == 200) {
      customer.walletBalance = customer.walletBalance! + amount;
      setState(() {
        _fetchCustomer();
      });
    }
  }

  bool isPauseLoading = false;

  Future<void> _pauseSubscriptionApi(
    String subId,
    String startDate,
    String endDate,
  ) async {
    final url = Uri.parse('$baseUrl/customer/pause-subscription/$subId');

    try {
      final response = await patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: json.encode({
          "pause_start_date": startDate,
          "pause_end_date": endDate,
          "subscriptionId": subId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchCustomer();
        _showSnack('Paused', 'Subscription paused successfully', _C.green);
      } else {
        _showSnack('Error', 'Failed to pause subscription', _C.red);
      }
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
    }
  }

  Future<void> _cancelSubscriptionApi({
    required String subId,
    required String startDate,
    String? endDate,
  }) async {
    final url = Uri.parse('$baseUrl/customer/cancel-subscription/$subId');

    try {
      final Map<String, dynamic> payload = {
        "date": startDate,
        "subscriptionId": subId,
      };

      if (endDate != null) {
        payload["cancellation_end_date"] = endDate;
      }

      final response = await patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchCustomer();
        _showSnack('', 'Cancellation applied successfully', _C.green);
      } else {
        _showSnack(
          "",
          json.decode(response.body)["message"] ??
              'Failed to apply cancellation',
          _C.red,
        );
      }
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
    }
  }

  // ─────────────────────────────────────────────
  // CREATE/ADD SUBSCRIPTION PLAN API
  // ─────────────────────────────────────────────
  Future<void> _addPlanSubscriptionApi({
    required String planId,
    required String partnerId,
    required String startDate,
    required String endDate,
    required String scheduleType,
    required List<String> selectedDays,
    required int discount,
    required String address,
  }) async {
    final url = Uri.parse('$baseUrl/customer/subscription/create');

    try {
      final Map<String, dynamic> payload = {
        "customerProfileId": customer.customerProfileId,
        "planId": planId,
        "deliveryPartnerId": partnerId,
        "start_date": startDate,
        "end_date": endDate,
        "scheduleType": scheduleType,
        "selectedDays": selectedDays,
        "discount": discount,
        "address": address,
      };

      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchCustomer();
        _showSnack('Success', 'Plan added successfully', _C.green);
      } else {
        _showSnack(
          "Error",
          json.decode(response.body)["message"] ??
              'Failed to add subscription plan',
          _C.red,
        );
      }
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
    }
  }

  // ─────────────────────────────────────────────
  // RENEW SUBSCRIPTION API
  // ─────────────────────────────────────────────
  Future<void> _renewSubscriptionApi({
    required String subId,
    required String planId,
    required String startDate,
    required String endDate,
    required String partnerId,
    required String discount,
  }) async {
    final url = Uri.parse('$baseUrl/customer/renew-subscription');

    try {
      final Map<String, dynamic> payload = {
        "subscriptionId": subId,
        "planId": planId,
        "start_date": startDate,
        "deliveryPartnerId": partnerId,
        "customerProfileId": customer.customerProfileId,
        "discount": discount,
        "end_date": endDate,
      };

      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: json.encode(payload),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchCustomer();
        _showSnack('Success', 'Subscription renewed successfully', _C.green);
      } else {
        _showSnack(
          "Error",
          json.decode(response.body)["message"] ??
              'Failed to renew subscription',
          _C.red,
        );
      }
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
    }
  }

  String _fmtDate(String iso) =>
      DateFormat('dd MMM yyyy').format(DateTime.parse(iso));

  String _fmtCurrency(int v) => '₹${NumberFormat('#,##,###').format(v)}';

  Future<void> _cancelFullSubcription({required String subId}) async {
    final url = Uri.parse('$baseUrl/customer/cancel-full-subscription/$subId');

    try {
      final response = await patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchCustomer();
        _showSnack('', 'Subscription has been cancelled', _C.green);
      } else {
        _showSnack(
          "",
          json.decode(response.body)["message"] ??
              'Failed to apply cancellation',
          _C.red,
        );
      }
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
    }
  }

  // ─── build ───────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child:
            !_isFetched
                ? const Center(
                  child: CircularProgressIndicator(color: _C.primary),
                )
                : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      SizedBox(height: 12.h),
                      _buildWalletCard(),
                      SizedBox(height: 12.h),
                      _buildStatsGrid(),
                      SizedBox(height: 24.h),
                      _buildSubscriptionsSection(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: _C.surface,
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(0.5),
      child: Container(height: 0.5, color: _C.border),
    ),
    leading: GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: EdgeInsets.only(left: 12.w),
        alignment: Alignment.center,
        child: _iconBox(Icons.arrow_back_ios_new_rounded, size: 16),
      ),
    ),
    title: Text(
      'Customer details',
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: _C.textPrimary,
      ),
    ),
    actions: [
      _iconBox(Icons.edit_outlined, size: 18, color: _C.primary),
      SizedBox(width: 12.w),
    ],
  );

  Widget _iconBox(
    IconData icon, {
    double size = 18,
    Color color = _C.textSecondary,
  }) => Container(
    width: 34.w,
    height: 34.w,
    decoration: BoxDecoration(
      color: _C.surface,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: _C.border),
    ),
    child: Icon(icon, size: size.sp, color: color),
  );

  // ─── Profile Card ─────────────────────────
  Widget _buildProfileCard() => _card(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name ?? 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary,
                ),
              ),
              SizedBox(height: 7.h),
              _infoRow(Icons.phone_outlined, customer.phone ?? 'N/A'),
              if (customer.email?.isNotEmpty ?? false) ...[
                SizedBox(height: 5.h),
                _infoRow(Icons.email_outlined, customer.email!),
              ],
              SizedBox(height: 5.h),
              _infoRow(
                Icons.location_on_outlined,
                (customer.address?.isNotEmpty ?? false)
                    ? customer.address!
                    : 'No address provided',
              ),
              SizedBox(height: 10.h),
              _statusBadge(),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _avatar() {
    final initials =
        (customer.name?.isNotEmpty ?? false)
            ? customer.name!.substring(0, 2).toUpperCase()
            : 'NA';
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: const BoxDecoration(
        color: _C.primaryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: _C.primary,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  Widget _statusBadge() => Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: _C.greenLight,
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: const BoxDecoration(
            color: _C.greenMid,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          'Active customer',
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: _C.green,
          ),
        ),
      ],
    ),
  );

  // ─── Wallet Card ─────────────────────────
  Widget _buildWalletCard() => _card(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 14,
                    color: _C.primaryMid,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Wallet balance',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      color: _C.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                _fmtCurrency(_walletBalance),
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      _walletBalance < 0 ? Colors.red.shade600 : _C.textPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                _walletBalance < 0 ? "Pending to Pay" : 'Excess Amount',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: _C.textTertiary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: _showTopUpSheet,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _C.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.add, size: 14, color: _C.primary),
                SizedBox(width: 5.w),
                Text(
                  'Add Balance',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: _C.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // ─── Stats Grid ──────────────────────────
  Widget _buildStatsGrid() => GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 10.w,
    mainAxisSpacing: 10.h,
    childAspectRatio: 1.6,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      _statCard(
        'Days left',
        '${customer.noOfDaysToEnd ?? 0}',
        Icons.timer_outlined,
        _C.amberLight,
        _C.amber,
      ),
      _statCard(
        'Total orders',
        '${customer.totalOrders ?? 0}',
        Icons.shopping_bag_outlined,
        _C.greenLight,
        _C.green,
      ),
      _statCard(
        'Total spent',
        _fmtCurrency(customer.totalSpent ?? 0),
        Icons.account_balance_wallet_outlined,
        _C.primaryLight,
        _C.primary,
      ),
      _statCard(
        'Member since',
        '6 mo',
        Icons.calendar_month_outlined,
        _C.pinkLight,
        _C.pink,
      ),
    ],
  );

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) => _card(
    padding: EdgeInsets.all(12.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(icon, size: 15.sp, color: iconColor),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: _C.textSecondary,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ─── Subscriptions ────────────────────────
  Widget _buildSubscriptionsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Active subscriptions',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: _showAddPlanSheet,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 13, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'Add plan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 12.h),
      if (customer.activeSubscriptions?.isEmpty ?? true)
        Center(
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: Text(
              'No active subscriptions found.',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: _C.textTertiary,
              ),
            ),
          ),
        )
      else
        ...(customer.activeSubscriptions!.map(
          (s) => _buildSubscriptionCard(s),
        )),
    ],
  );

  Widget _buildSubscriptionCard(ActiveSubscriptions sub) {
    final isEveryday = (sub.scheduletype ?? '').toUpperCase() == 'EVERYDAY';
    final days =
        sub.seletedDays?.map((d) => d.substring(0, 3)).join(', ') ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.plan?.name ?? 'N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_outlined,
                            size: 12,
                            color: _C.textTertiary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '₹${sub.totalPrice} / month',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: _C.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: sub.status == "ACTIVE" ? _C.greenLight : _C.redLight,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          color: sub.status == "ACTIVE" ? _C.green : _C.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        sub.status == "ACTIVE" ? 'Active' : "Cancelled",
                        style: GoogleFonts.poppins(
                          color: sub.status == "ACTIVE" ? _C.green : _C.red,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 0.5, color: _C.border),

          // Details
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                _subRow(
                  Icons.calendar_today_outlined,
                  '${_fmtDate(sub.startDate!)}  —  ${_fmtDate(sub.endDate!)}',
                ),
                SizedBox(height: 7.h),
                _subRow(
                  Icons.repeat_rounded,
                  isEveryday ? 'Everyday delivery' : 'Custom: $days',
                ),
                SizedBox(height: 7.h),
                _subRow(
                  Icons.payments_outlined,
                  'Total price: ₹${sub.totalPrice}',
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 0.5, color: _C.border),

          // Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    'Pause',
                    Icons.pause_circle_outline_rounded,
                    _C.amber,
                    _C.amberLight,
                    _C.amberBorder,
                    () => _handlePause(sub.id!),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _actionButton(
                    'Renew',
                    Icons.autorenew_rounded,
                    _C.primary,
                    _C.primaryLight,
                    _C.primaryMid,
                    () => _handleRenew(sub),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _actionButton(
                    'Cancel',
                    Icons.cancel_outlined,
                    _C.red,
                    _C.redLight,
                    _C.redBorder,
                    () => _handleCancel(sub.id!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reusable Widgets ─────────────────────
  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
    padding: padding ?? EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: _C.surface,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: _C.border),
    ),
    child: child,
  );

  Widget _infoRow(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 13.sp, color: _C.textTertiary),
      SizedBox(width: 6.w),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: _C.textSecondary),
        ),
      ),
    ],
  );

  Widget _subRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 13.sp, color: _C.textTertiary),
      SizedBox(width: 8.w),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: _C.textSecondary),
        ),
      ),
    ],
  );

  Widget _actionButton(
    String label,
    IconData icon,
    Color textColor,
    Color bgColor,
    Color borderColor,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );

  // ─── Dialogs / Sheets ─────────────────────
  void _showTopUpSheet() {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Add Wallet Balance',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Enter the amount to add to the wallet",
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        color: _C.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: _C.textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixText: '₹  ',
                        prefixStyle: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: _C.textSecondary,
                        ),
                        hintText: '1,000',
                        hintStyle: GoogleFonts.poppins(
                          color: _C.textTertiary,
                          fontSize: 15.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: _C.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: _C.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(
                            color: _C.primary,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9F9FB),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children:
                          [500, 1000, 2000].map((amt) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: amt == 2000 ? 0 : 8.w,
                                ),
                                child: GestureDetector(
                                  onTap: () => ctrl.text = amt.toString(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 9.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F6FA),
                                      border: Border.all(color: _C.border),
                                      borderRadius: BorderRadius.circular(7.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '+₹$amt',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5.sp,
                                        color: _C.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: const BorderSide(color: _C.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: _C.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final v = int.tryParse(ctrl.text) ?? 0;
                              if (v > 0) {
                                setState(() => _walletBalance += v);
                                updateWalletBalance(v);
                                Get.back();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.primary,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Add funds',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _handlePause(String subId) {
    _showPauseSheet(subId);
  }

  void _handleRenew(ActiveSubscriptions sub) {
    _showRenewSheet(sub);
  }

  void _handleCancel(String subId) {
    _showCancelSheet(subId);
  }

  // ─────────────────────────────────────────────
  // ADD NEW PLAN BOTTOM SHEET IMPLEMENTATION
  // ─────────────────────────────────────────────
  void _showAddPlanSheet() {
    final PlanController planController = Get.put(PlanController());
    planController.ensureLoaded();

    final PartnerController partnerController = Get.put(PartnerController());
    partnerController.ensureLoaded();

    String? selectedPlanId;
    String? selectedPartnerId;
    DateTime? startDate;
    DateTime? endDate;
    int selectedMonths = 1;
    String selectedScheduleType =
        "Everyday"; // Matching the dropdown static mapping ("Custom", "Everyday")
    List<String> selectedDays = [];

    final TextEditingController discountCtrl = TextEditingController(text: "0");
    final TextEditingController addressCtrl = TextEditingController(
      text: customer.address ?? "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setSheetState) {
              final isMonthly = planController.plans.any(
                (p) => p.id == selectedPlanId && p.isMonthlyPlan,
              );

              void updateMonthlyEndDate() {
                if (startDate != null && isMonthly) {
                  setSheetState(() {
                    endDate = DateTime(
                      startDate!.year,
                      startDate!.month + selectedMonths,
                      startDate!.day,
                    ).subtract(Duration(days: 1));
                    ;
                  });
                }
              }

              Future<void> pickDate(bool isStart) async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      isStart
                          ? (startDate ?? DateTime.now())
                          : (endDate ?? startDate ?? DateTime.now()),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: _C.primary,
                          onPrimary: Colors.white,
                          onSurface: _C.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setSheetState(() {
                    if (isStart) {
                      startDate = picked;
                      if (isMonthly) {
                        updateMonthlyEndDate();
                      } else if (endDate != null &&
                          endDate!.isBefore(startDate!)) {
                        endDate = null;
                      }
                    } else {
                      endDate = picked;
                    }
                  });
                }
              }

              Widget dateField(
                String hint,
                DateTime? date,
                VoidCallback onTap,
              ) {
                return GestureDetector(
                  onTap: onTap,
                  child: Container(
                    height: 46.h,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: _C.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date != null
                              ? DateFormat('dd MMM yyyy').format(date)
                              : hint,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5.sp,
                            color:
                                date != null ? _C.textPrimary : _C.textTertiary,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 15.sp,
                          color: _C.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              Widget label(String text) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _C.textPrimary,
                    ),
                  ),
                );
              }

              return GetBuilder<PlanController>(
                builder: (_) {
                  return GetBuilder<PartnerController>(
                    builder: (_) {
                      return SafeArea(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.85,
                          ),
                          decoration: BoxDecoration(
                            color: _C.surface,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                          ),
                          padding: EdgeInsets.only(
                            left: 20.w,
                            right: 20.w,
                            top: 16.h,
                            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    width: 36.w,
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      color: _C.border,
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Container(
                                      width: 34.w,
                                      height: 34.w,
                                      decoration: const BoxDecoration(
                                        color: _C.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_shopping_cart_rounded,
                                        color: _C.primary,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'Add New Plan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _C.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),

                                label("Meal Plan *"),
                                Container(
                                  height: 46.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9FB),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: _C.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value:
                                          planController.plans.any(
                                                (p) => p.id == selectedPlanId,
                                              )
                                              ? selectedPlanId
                                              : null,
                                      hint: Text(
                                        "Select Meal Plan",
                                        style: GoogleFonts.poppins(
                                          color: _C.textTertiary,
                                          fontSize: 13.5.sp,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: _C.textSecondary,
                                      ),
                                      items:
                                          planController.plans.map((p) {
                                            return DropdownMenuItem<String>(
                                              value: p.id,
                                              child: Text(
                                                p.planName ?? "N/A",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13.5.sp,
                                                  color: _C.textPrimary,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (val) {
                                        setSheetState(() {
                                          selectedPlanId = val;
                                          final newlySelectedMonthly =
                                              planController.plans.any(
                                                (p) =>
                                                    p.id == val &&
                                                    p.isMonthlyPlan,
                                              );
                                          if (newlySelectedMonthly) {
                                            selectedScheduleType = "Everyday";
                                            selectedDays = List.from(
                                              _daysOfWeek,
                                            );
                                            updateMonthlyEndDate();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 14.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          label("Start Date *"),
                                          dateField(
                                            "Select Date",
                                            startDate,
                                            () async {
                                              await pickDate(true);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          isMonthly
                                              ? label("Duration *")
                                              : label("End Date *"),
                                          isMonthly
                                              ? Container(
                                                height: 46.h,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 14.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF9F9FB,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                  border: Border.all(
                                                    color: _C.border,
                                                  ),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<int>(
                                                    isExpanded: true,
                                                    value: selectedMonths,
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: _C.textSecondary,
                                                    ),
                                                    items:
                                                        List.generate(
                                                          12,
                                                          (index) => index + 1,
                                                        ).map((m) {
                                                          return DropdownMenuItem<
                                                            int
                                                          >(
                                                            value: m,
                                                            child: Text(
                                                              "$m Month${m > 1 ? 's' : ''}",
                                                              style: GoogleFonts.poppins(
                                                                fontSize:
                                                                    13.5.sp,
                                                                color:
                                                                    _C.textPrimary,
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                    onChanged: (val) {
                                                      if (val != null) {
                                                        setSheetState(
                                                          () =>
                                                              selectedMonths =
                                                                  val,
                                                        );
                                                        updateMonthlyEndDate();
                                                      }
                                                    },
                                                  ),
                                                ),
                                              )
                                              : dateField(
                                                "Select Date",
                                                endDate,
                                                () async {
                                                  await pickDate(false);
                                                },
                                              ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14.h),

                                label("Delivery Partner *"),
                                Container(
                                  height: 46.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9FB),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: _C.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedPartnerId,
                                      hint: Text(
                                        "Select Delivery Partner",
                                        style: GoogleFonts.poppins(
                                          color: _C.textTertiary,
                                          fontSize: 13.5.sp,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: _C.textSecondary,
                                      ),
                                      items:
                                          partnerController.partners.map((e) {
                                            return DropdownMenuItem<String>(
                                              value:
                                                  e
                                                      .deliveryPartnerProfile
                                                      ?.id ??
                                                  "",
                                              child: Text(
                                                e.name ?? "Unknown",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13.5.sp,
                                                  color: _C.textPrimary,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged:
                                          (val) => setSheetState(
                                            () => selectedPartnerId = val,
                                          ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 14.h),

                                if (!isMonthly) ...[
                                  label("Scheduled Delivery Type"),
                                  Container(
                                    height: 46.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9FB),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: _C.border),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedScheduleType,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: _C.textSecondary,
                                        ),
                                        items:
                                            ["Everyday", "Custom"].map((type) {
                                              return DropdownMenuItem<String>(
                                                value: type,
                                                child: Text(
                                                  type,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13.5.sp,
                                                    color: _C.textPrimary,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setSheetState(() {
                                            selectedScheduleType =
                                                value ?? "Everyday";
                                            if (selectedScheduleType ==
                                                "Everyday") {
                                              selectedDays = List.from(
                                                _daysOfWeek,
                                              );
                                            } else {
                                              selectedDays = [];
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 14.h),
                                  if (selectedScheduleType == "Custom") ...[
                                    label("Select Delivery Days *"),
                                    Wrap(
                                      spacing: 8.w,
                                      runSpacing: 8.h,
                                      children:
                                          _daysOfWeek.map((day) {
                                            final isSelected = selectedDays
                                                .contains(day);
                                            return GestureDetector(
                                              onTap: () {
                                                setSheetState(() {
                                                  if (isSelected) {
                                                    selectedDays.remove(day);
                                                  } else {
                                                    selectedDays.add(day);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 66.w,
                                                height: 34.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      isSelected
                                                          ? _C.primaryLight
                                                          : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                  border: Border.all(
                                                    color:
                                                        isSelected
                                                            ? _C.primary
                                                            : Colors
                                                                .grey
                                                                .shade300,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    day.substring(0, 3),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11.5.sp,
                                                      fontWeight:
                                                          isSelected
                                                              ? FontWeight.w600
                                                              : FontWeight.w400,
                                                      color:
                                                          isSelected
                                                              ? _C.primary
                                                              : _C.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                    SizedBox(height: 14.h),
                                  ],
                                ],

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          label("Discount Amount (₹)"),
                                          TextField(
                                            controller: discountCtrl,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.5.sp,
                                              color: _C.textPrimary,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 14.w,
                                                    vertical: 10.h,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                borderSide: const BorderSide(
                                                  color: _C.border,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                borderSide: const BorderSide(
                                                  color: _C.border,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                borderSide: const BorderSide(
                                                  color: _C.primary,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: const Color(
                                                0xFFF9F9FB,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14.h),

                                label("Delivery Address"),
                                TextField(
                                  controller: addressCtrl,
                                  maxLines: 2,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5.sp,
                                    color: _C.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Enter specific address instructions',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 10.h,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: const BorderSide(
                                        color: _C.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: const BorderSide(
                                        color: _C.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: const BorderSide(
                                        color: _C.primary,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9F9FB),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Get.back(),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12.h,
                                          ),
                                          side: const BorderSide(
                                            color: _C.border,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            color: _C.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          print(selectedPartnerId);
                                          print(selectedPlanId);
                                          if (selectedPlanId == null ||
                                              selectedPartnerId == null ||
                                              startDate == null ||
                                              endDate == null) {
                                            _showSnack(
                                              'Notice',
                                              'Please complete all required fields.',
                                              _C.amber,
                                            );
                                            return;
                                          }
                                          if (selectedScheduleType ==
                                                  "Custom" &&
                                              selectedDays.isEmpty) {
                                            _showSnack(
                                              'Notice',
                                              'Please select at least one delivery day.',
                                              _C.amber,
                                            );
                                            return;
                                          }

                                          final startFmt = DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(startDate!);
                                          final endFmt = DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(endDate!);
                                          final discountVal =
                                              int.tryParse(discountCtrl.text) ??
                                              0;

                                          _addPlanSubscriptionApi(
                                            planId: selectedPlanId!,
                                            partnerId: selectedPartnerId!,
                                            startDate: startFmt,
                                            endDate: endFmt,
                                            scheduleType:
                                                selectedScheduleType
                                                    .toUpperCase(),
                                            selectedDays:
                                                selectedScheduleType ==
                                                        "Everyday"
                                                    ? List.from(_daysOfWeek)
                                                    : selectedDays,
                                            discount: discountVal,
                                            address: addressCtrl.text.trim(),
                                          );
                                          Get.back();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _C.primary,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Add Plan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
    );
  }

  // ─────────────────────────────────────────────
  // RENEW SUBSCRIPTION BOTTOM SHEET
  // ─────────────────────────────────────────────
  void _showRenewSheet(ActiveSubscriptions sub) {
    final PartnerController partnerController = Get.put(PartnerController());
    partnerController.ensureLoaded();

    final PlanController planController = Get.put(PlanController());
    planController.ensureLoaded();

    bool isMonthly = false;
    try {
      isMonthly = planController.plans.any(
        (p) => p.id == sub.plan?.id && p.isMonthlyPlan,
      );
    } catch (e) {
      isMonthly = false;
    }

    // Explicit constraint fulfillment: Start date must fall *after* expiration date
    final DateTime subEndDate = DateTime.parse(sub.endDate!);
    final DateTime minRenewalStartDate = subEndDate.add(
      const Duration(days: 1),
    );

    DateTime? startDate = minRenewalStartDate;
    int selectedMonths = 1;
    DateTime? endDate;

    void updateMonthlyEndDate(StateSetter setSheetState) {
      if (startDate != null && isMonthly) {
        setSheetState(() {
          endDate = DateTime(
            startDate!.year,
            startDate!.month + selectedMonths,
            startDate!.day,
          ).subtract(Duration(days: 1));
        });
      }
    }

    if (isMonthly) {
      endDate = DateTime(
        startDate.year,
        startDate.month + selectedMonths,
        startDate.day,
      );
    }

    String? selectedPartnerId;
    TextEditingController discountCtrl = TextEditingController(text: "0");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setSheetState) {
              Future<void> pickDate(bool isStart) async {
                final initialDate =
                    isStart
                        ? (startDate ?? minRenewalStartDate)
                        : (endDate ?? startDate ?? minRenewalStartDate);
                final firstDate =
                    isStart
                        ? minRenewalStartDate
                        : (startDate ?? minRenewalStartDate);

                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      initialDate.isBefore(firstDate) ? firstDate : initialDate,
                  firstDate: firstDate,
                  lastDate: DateTime(2035),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: _C.primary,
                          onPrimary: Colors.white,
                          onSurface: _C.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setSheetState(() {
                    if (isStart) {
                      startDate = picked;
                      if (isMonthly) {
                        updateMonthlyEndDate(setSheetState);
                      } else if (endDate != null &&
                          endDate!.isBefore(startDate!)) {
                        endDate = null;
                      }
                    } else {
                      endDate = picked;
                    }
                  });
                }
              }

              Widget datePickerBox(
                String hint,
                DateTime? date,
                VoidCallback onTap,
              ) {
                return GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      border: Border.all(color: _C.border),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date != null
                              ? DateFormat('yyyy-MM-dd').format(date)
                              : hint,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color:
                                date != null ? _C.textPrimary : _C.textTertiary,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: _C.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 36.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: _C.border,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: const BoxDecoration(
                                color: _C.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.autorenew_rounded,
                                color: _C.primary,
                                size: 18,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Renew Plan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _C.textPrimary,
                                  ),
                                ),
                                Text(
                                  sub.plan?.name ?? 'Existing Plan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: _C.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date (After Expiry)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: _C.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  datePickerBox(
                                    'Select',
                                    startDate,
                                    () => pickDate(true),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            if (isMonthly)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Duration *',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        color: _C.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Container(
                                      height: 48.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9F9FB),
                                        border: Border.all(color: _C.border),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          value: selectedMonths,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: _C.textSecondary,
                                          ),
                                          items:
                                              List.generate(
                                                    12,
                                                    (index) => index + 1,
                                                  )
                                                  .map(
                                                    (month) => DropdownMenuItem(
                                                      value: month,
                                                      child: Text(
                                                        "$month Month${month > 1 ? 's' : ''}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 14.sp,
                                                              color:
                                                                  _C.textPrimary,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setSheetState(
                                                () => selectedMonths = val,
                                              );
                                              updateMonthlyEndDate(
                                                setSheetState,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Date',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        color: _C.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    datePickerBox(
                                      'Select',
                                      endDate,
                                      () => pickDate(false),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Delivery Partner *',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: _C.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          height: 48.h,
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9FB),
                            border: Border.all(color: _C.border),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: GetBuilder<PartnerController>(
                            builder: (controller) {
                              return DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedPartnerId,
                                  hint: Text(
                                    'Select Delivery Partner',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: _C.textTertiary,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: _C.textSecondary,
                                  ),
                                  items:
                                      controller.partners.map((e) {
                                        return DropdownMenuItem<String>(
                                          value:
                                              e.deliveryPartnerProfile?.id ??
                                              "",
                                          child: Text(
                                            e.name ?? "Unknown",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              color: _C.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (val) {
                                    setSheetState(
                                      () => selectedPartnerId = val,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Discount applied (%)",
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: _C.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        TextField(
                          controller: discountCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: _C.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. 10',
                            hintStyle: GoogleFonts.poppins(
                              color: _C.textTertiary,
                              fontSize: 14.sp,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: _C.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: _C.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: _C.primary,
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9F9FB),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  side: const BorderSide(color: _C.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: _C.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (selectedPartnerId == null ||
                                      startDate == null ||
                                      endDate == null) {
                                    _showSnack(
                                      'Missing Info',
                                      'Please select dates and a delivery partner.',
                                      _C.amber,
                                    );
                                    return;
                                  }

                                  if (sub.plan?.id == null) {
                                    _showSnack(
                                      'Error',
                                      'Unable to find Plan ID from current subscription.',
                                      _C.red,
                                    );
                                    return;
                                  }

                                  final startFmt = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(startDate!);
                                  final endFmt = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(endDate!);
                                  final discountVal =
                                      discountCtrl.text.isEmpty
                                          ? "0"
                                          : discountCtrl.text;

                                  _renewSubscriptionApi(
                                    subId: sub.id!,
                                    planId: sub.plan!.id!,
                                    startDate: startFmt,
                                    endDate: endFmt,
                                    partnerId: selectedPartnerId!,
                                    discount: discountVal,
                                  );
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.primary,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Confirm Renew',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showPauseSheet(String subId) {
    DateTime? startDate;
    DateTime? endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setSheetState) {
              Future<void> pickDate(bool isStart) async {
                final initialDate =
                    isStart
                        ? (startDate ?? DateTime.now())
                        : (endDate ?? startDate ?? DateTime.now());
                final firstDate =
                    isStart ? DateTime.now() : (startDate ?? DateTime.now());

                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: _C.primary,
                          onPrimary: Colors.white,
                          onSurface: _C.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setSheetState(() {
                    if (isStart) {
                      startDate = picked;
                      if (endDate != null && endDate!.isBefore(startDate!)) {
                        endDate = null;
                      }
                    } else {
                      endDate = picked;
                    }
                  });
                }
              }

              Widget datePickerBox(
                String hint,
                DateTime? date,
                VoidCallback onTap,
              ) {
                return GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      border: Border.all(color: _C.border),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date != null
                              ? DateFormat('yyyy-MM-dd').format(date)
                              : hint,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color:
                                date != null ? _C.textPrimary : _C.textTertiary,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: _C.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 36.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: _C.border,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Pause Subscription',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Select the duration to temporarily pause deliveries.",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5.sp,
                            color: _C.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: _C.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  datePickerBox(
                                    'Select',
                                    startDate,
                                    () => pickDate(true),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Date',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: _C.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  datePickerBox(
                                    'Select',
                                    endDate,
                                    () => pickDate(false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  side: const BorderSide(color: _C.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: _C.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (startDate == null || endDate == null) {
                                    _showSnack(
                                      'Notice',
                                      'Please select both start and end dates',
                                      _C.amber,
                                    );
                                    return;
                                  }

                                  final startFormatted = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(startDate!);
                                  final endFormatted = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(endDate!);

                                  _pauseSubscriptionApi(
                                    subId,
                                    startFormatted,
                                    endFormatted,
                                  );
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.amber,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Confirm Pause',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showCancelSheet(String subId) {
    DateTime? startDate;
    DateTime? endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setSheetState) {
              Future<void> pickDate(bool isStart) async {
                final initialDate =
                    isStart
                        ? (startDate ?? DateTime.now())
                        : (endDate ?? startDate ?? DateTime.now());
                final firstDate =
                    isStart ? DateTime.now() : (startDate ?? DateTime.now());

                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: _C.red,
                          onPrimary: Colors.white,
                          onSurface: _C.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setSheetState(() {
                    if (isStart) {
                      startDate = picked;
                      if (endDate != null && endDate!.isBefore(startDate!)) {
                        endDate = null;
                      }
                    } else {
                      endDate = picked;
                    }
                  });
                }
              }

              Widget datePickerBox(
                String hint,
                DateTime? date,
                VoidCallback onTap,
              ) {
                return GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      border: Border.all(color: _C.border),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date != null
                              ? DateFormat('yyyy-MM-dd').format(date)
                              : hint,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color:
                                date != null ? _C.textPrimary : _C.textTertiary,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: _C.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 36.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: _C.border,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: const BoxDecoration(
                                color: _C.redLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: _C.red,
                                size: 18,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Cancel Subscription',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Select dates to cancel deliveries for a specific period, or cancel the entire subscription below.",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5.sp,
                            color: _C.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: _C.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  datePickerBox(
                                    'Select',
                                    startDate,
                                    () => pickDate(true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  side: const BorderSide(color: _C.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Close',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: _C.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (startDate == null) {
                                    _showSnack(
                                      'Notice',
                                      'Please select date for a partial cancellation.',
                                      _C.red,
                                    );
                                    return;
                                  }
                                  final startFmt = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(startDate!);

                                  _cancelSubscriptionApi(
                                    subId: subId,
                                    startDate: startFmt,
                                  );
                                  Get.back();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  side: const BorderSide(color: _C.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel Selected Date',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _C.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        const Divider(color: _C.border),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _cancelFullSubcription(subId: subId);
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.red,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Cancel Full Subscription',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showSnack(String title, String msg, Color _color) {
    AppToast.show(title: title, message: msg);
  }
}
