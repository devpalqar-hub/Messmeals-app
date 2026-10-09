import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerDetailedModel.dart';
import 'package:mess/Screens/DeliveriesScreen/Model/DeliveryModel.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart';
import 'package:table_calendar/table_calendar.dart';

class _C {
  static const surface = Colors.white;
  static const border = Color(0xFFEEEEF0);
  static const primary = Color(0xFF7ED321);
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

  // Subscriptions / Deliveries / Payments tabs on the redesigned screen.
  int _selectedTab = 0;

  bool _deliveriesLoading = false;
  List<Delivery> _deliveries = [];

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
      // Search by phone rather than name — unique per customer, so this
      // only ever pulls back this customer's own deliveries, across all
      // of their subscriptions.
      if ((customer.phone ?? '').trim().isNotEmpty) {
        _fetchDeliveries();
      }
    }
  }

  Future<void> _fetchDeliveries() async {
    setState(() => _deliveriesLoading = true);
    try {
      final messId = Get.find<HomeScreenController>().selectedMessId;
      if (messId == null) return;
      final uri = Uri.parse('$baseUrl/deliveries').replace(
        queryParameters: {
          'messId': messId,
          'search': customer.phone,
          'limit': '100',
        },
      );
      final res = await get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );
      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];
        _deliveries = dataList.map((e) => Delivery.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('FETCH CUSTOMER DELIVERIES ERROR: $e');
    } finally {
      if (mounted) setState(() => _deliveriesLoading = false);
    }
  }

  bool isProfileSaving = false;
  Future<void> _updateCustomerProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    setState(() => isProfileSaving = true);
    try {
      final response = await patch(
        Uri.parse('$baseUrl/customer/${customer.customerProfileId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: json.encode({"name": name, "phone": phone, "address": address}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchCustomer();
        _showSnack('Saved', 'Customer details updated successfully', _C.green);
      } else {
        _showSnack(
          "Error",
          json.decode(response.body)["message"] ?? 'Failed to update details',
          _C.red,
        );
      }
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
    } finally {
      if (mounted) setState(() => isProfileSaving = false);
    }
  }

  /// One combined sheet for name, phone and address — replaces the previous
  /// per-field edit icons so updating a customer's details is a single
  /// action instead of three separate ones.
  void _showEditProfileSheet() {
    final nameCtrl = TextEditingController(text: customer.name ?? '');
    final phoneCtrl = TextEditingController(text: customer.phone ?? '');
    final addressCtrl = TextEditingController(text: customer.address ?? '');

    Widget fieldLabel(String text) => Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w600,
        color: _C.textSecondary,
      ),
    );

    InputDecoration fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: _C.textTertiary),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: _C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: _C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: _C.primary, width: 1.5),
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SafeArea(
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
                        width: 40.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    Text(
                      'Edit Customer Details',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    fieldLabel('Name'),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      decoration: fieldDecoration('Enter full name'),
                    ),
                    SizedBox(height: 14.h),
                    fieldLabel('Phone Number'),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: fieldDecoration(
                        'Enter 10-digit phone number',
                      ),
                    ),
                    SizedBox(height: 14.h),
                    fieldLabel('Address'),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: addressCtrl,
                      maxLines: 3,
                      decoration: fieldDecoration('Enter address'),
                    ),
                    SizedBox(height: 22.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                side: BorderSide(color: _C.border),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: _C.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.primary,
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              final newName = nameCtrl.text.trim();
                              final newPhone = phoneCtrl.text.trim();
                              final newAddress = addressCtrl.text.trim();

                              if (newName.isEmpty) {
                                _showSnack(
                                  'Invalid',
                                  'Please enter a name',
                                  _C.red,
                                );
                                return;
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(newPhone)) {
                                _showSnack(
                                  'Invalid',
                                  'Please enter a valid 10-digit phone number',
                                  _C.red,
                                );
                                return;
                              }
                              if (newAddress.isEmpty) {
                                _showSnack(
                                  'Invalid',
                                  'Please enter an address',
                                  _C.red,
                                );
                                return;
                              }

                              Navigator.pop(ctx);
                              _updateCustomerProfile(
                                name: newName,
                                phone: newPhone,
                                address: newAddress,
                              );
                            },
                            child: Text(
                              'Save',
                              style: GoogleFonts.poppins(
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

  bool isWalletLoading = false;

  /// Returns whether the payment was actually saved — BUG #? the caller's
  /// optimistic `_walletBalance` update previously had nothing to roll
  /// back to on failure (the PATCH's response wasn't even checked beyond
  /// a silent no-op), so a rejected payment still looked successful.
  Future<bool> updateWalletBalance(int amount) async {
    try {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchCustomer();
        return true;
      }
      _showSnack(
        'Error',
        json.decode(response.body)["message"] ?? 'Failed to update wallet',
        _C.red,
      );
      return false;
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
      return false;
    }
  }

  bool isPauseLoading = false;

  // BUG #3205/#3207 — API error bodies can return `message` as either a
  // plain String or a List<String> (e.g. class-validator style field
  // errors). The other API methods below cast that straight into
  // _showSnack's String parameter via `?? 'fallback'`, which only guards
  // against null — a List<String> still passes through and crashes with
  // "type 'List<String>' is not a subtype of type 'String'" for whichever
  // requests happen to trigger a multi-field validation error. This safely
  // coerces either shape (or a missing/unparseable body) down to a String.
  // `response` is left untyped (dynamic) because this file imports both
  // `package:get/get.dart` and `package:http/http.dart` unprefixed, and
  // both packages export a `Response` class — an explicit annotation here
  // is an ambiguous_import analyzer error.
  String _extractErrorMessage(dynamic response, String fallback) {
    try {
      final decoded = json.decode(response.body);
      final dynamic msg = decoded is Map ? decoded['message'] : null;
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join(', ');
      if (msg is Map && msg.isNotEmpty) return msg.values.join(', ');
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

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
        // BUG #3207 — this used to always show a generic "Failed to pause
        // subscription" message regardless of why the backend rejected the
        // request, unlike every other mutation API in this file which
        // surfaces the backend's actual `message`. Surfacing the real
        // reason here is needed to tell a genuine backend/validation
        // rejection apart from a client-side request problem.
        _showSnack(
          'Error',
          _extractErrorMessage(response, 'Failed to pause subscription'),
          _C.red,
        );
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
      if (endDate != null) payload["cancellation_end_date"] = endDate;
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
        // BUG #3205 — `json.decode(response.body)["message"]` is `dynamic`;
        // when the backend's validation error for certain date ranges
        // returns `message` as a List<String> instead of a String, the
        // `?? fallback` null-check doesn't catch it and the implicit
        // downcast into _showSnack's String parameter crashed with
        // "type 'List<String>' is not a subtype of type 'String'".
        _showSnack(
          "",
          _extractErrorMessage(response, 'Failed to apply cancellation'),
          _C.red,
        );
      }
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
    }
  }

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
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: json.encode({
          "customerProfileId": customer.customerProfileId,
          "planId": planId,
          "deliveryPartnerId": partnerId,
          "start_date": startDate,
          "end_date": endDate,
          "scheduleType": scheduleType,
          "selectedDays": selectedDays,
          "discount": discount,
          "address": address,
        }),
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
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: json.encode({
          "subscriptionId": subId,
          "planId": planId,
          "start_date": startDate,
          "deliveryPartnerId": partnerId,
          "customerProfileId": customer.customerProfileId,
          "discount": discount,
          "end_date": endDate,
        }),
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

  // ✅ FIX: NEW helper — computes real "Member since" from createdAt
  String _fmtMemberSinceDate() {
    if (customer.createdAt == null || customer.createdAt!.isEmpty) {
      return 'N/A';
    }
    try {
      return _fmtDate(customer.createdAt!);
    } catch (_) {
      return 'N/A';
    }
  }

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
        // Same class of bug as #3205 — `message` can come back as a
        // nested object instead of a plain string, and `?? fallback`
        // alone doesn't guard against that, only against null.
        _showSnack(
          "",
          _extractErrorMessage(response, 'Failed to apply cancellation'),
          _C.red,
        );
      }
    } catch (e) {
      _showSnack('Error', 'An error occurred: $e', _C.red);
    }
  }

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
                      _buildStatsRow(),
                      SizedBox(height: 16.h),
                      _buildTabBar(),
                      SizedBox(height: 16.h),
                      switch (_selectedTab) {
                        0 => _buildSubscriptionsSection(),
                        1 => _buildDeliveriesTab(),
                        _ => _buildPaymentsTab(),
                      },
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
      ),
    );
  }

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
    actions: [],
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
              SizedBox(height: 5.h),
              _infoRow(
                Icons.calendar_today_outlined,
                'Member since ${_fmtMemberSinceDate()}',
              ),
              SizedBox(height: 10.h),
              _statusBadge(),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _editProfileButton(),
      ],
    ),
  );

  /// Single entry point for editing the whole customer profile (name,
  /// phone, address) — replaces the old per-field edit icons.
  Widget _editProfileButton() => GestureDetector(
    onTap: isProfileSaving ? null : _showEditProfileSheet,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _C.primaryLight,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _C.primaryMid),
      ),
      child:
          isProfileSaving
              ? SizedBox(
                height: 14.sp,
                width: 14.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _C.primary,
                ),
              )
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 14.sp, color: _C.greenMid),
                  SizedBox(width: 4.w),
                  Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _C.greenMid,
                    ),
                  ),
                ],
              ),
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
                    'Pending Amount',
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
                  'Pay Amount',
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

  Widget _buildStatsRow() {
    final activePlanCount =
        customer.activeSubscriptions
            ?.where((s) => s.status == 'ACTIVE')
            .length ??
        0;
    return Row(
      children: [
        Expanded(
          child: _statChip(
            'Active Plan',
            '$activePlanCount',
            Icons.assignment_outlined,
            _C.greenLight,
            _C.green,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _statChip(
            'Days Left',
            '${customer.noOfDaysToEnd ?? 0}',
            Icons.timer_outlined,
            _C.amberLight,
            _C.amber,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _statChip(
            'Total Spent',
            _fmtCurrency(customer.totalSpent ?? 0),
            Icons.account_balance_wallet_outlined,
            _C.redLight,
            _C.red,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _statChip(
            'Total Deliveries',
            '${customer.totalOrders ?? 0}',
            Icons.local_shipping_outlined,
            _C.primaryLight,
            _C.primaryMid,
          ),
        ),
      ],
    );
  }

  Widget _statChip(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: iconColor),
        SizedBox(height: 6.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 9.5.sp, color: _C.textSecondary),
        ),
      ],
    ),
  );

  Widget _buildTabBar() {
    const tabs = ['Subscriptions', 'Deliveries', 'Payments'];
    const icons = [
      Icons.assignment_outlined,
      Icons.local_shipping_outlined,
      Icons.account_balance_wallet_outlined,
    ];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: isActive ? _C.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow:
                      isActive
                          ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[i],
                      size: 13.sp,
                      color: isActive ? _C.primary : _C.textTertiary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      tabs[i],
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: isActive ? _C.textPrimary : _C.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Deliveries tab — Today / Upcoming / Recent, derived from the single
  // _deliveries fetch (all of this customer's deliveries, across every
  // subscription they've ever had).
  // ---------------------------------------------------------------------
  Widget _buildDeliveriesTab() {
    if (_deliveriesLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const Center(
          child: CircularProgressIndicator(color: _C.primary),
        ),
      );
    }
    if (_deliveries.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            'No deliveries found for this customer.',
            style: GoogleFonts.poppins(fontSize: 13.sp, color: _C.textTertiary),
          ),
        ),
      );
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    DateTime? dateOf(Delivery d) {
      try {
        return DateTime.parse(d.date);
      } catch (_) {
        return null;
      }
    }

    final sorted = [..._deliveries]..sort((a, b) {
      final da = dateOf(a) ?? todayOnly;
      final db = dateOf(b) ?? todayOnly;
      return da.compareTo(db);
    });

    Delivery? todayDelivery;
    for (final d in sorted) {
      final dd = dateOf(d);
      if (dd != null && dd.isAtSameMomentAs(todayOnly)) {
        todayDelivery = d;
        break;
      }
    }
    final upcoming =
        sorted
            .where((d) {
              final dd = dateOf(d);
              return dd != null && dd.isAfter(todayOnly);
            })
            .take(5)
            .toList();
    final recent =
        sorted
            .where((d) {
              final dd = dateOf(d);
              return dd != null && !dd.isAfter(todayOnly);
            })
            .toList()
            .reversed
            .take(5)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todayDelivery != null) ...[
          Text(
            "Today's Delivery",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          _deliveryListRow(todayDelivery, icon: Icons.local_shipping_outlined),
          SizedBox(height: 20.h),
        ],
        if (upcoming.isNotEmpty) ...[
          Text(
            'Upcoming Deliveries',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 70.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: upcoming.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) => _upcomingDayChip(upcoming[i]),
            ),
          ),
          SizedBox(height: 20.h),
        ],
        if (recent.isNotEmpty) ...[
          Text(
            'Recent Deliveries',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          ...recent.map(
            (d) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _deliveryListRow(d, icon: Icons.calendar_today_outlined),
            ),
          ),
        ],
      ],
    );
  }

  Widget _deliveryListRow(Delivery d, {required IconData icon}) {
    final meta = _deliveryStatusMeta(d.status);
    String dateLabel = d.date;
    try {
      dateLabel = DateFormat('dd MMM yyyy').format(DateTime.parse(d.date));
    } catch (_) {}
    final mealTitle =
        d.deliveryVariations.isNotEmpty
            ? d.deliveryVariations
                .map((v) => v.variation?.title)
                .whereType<String>()
                .join(', ')
            : '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: _C.textTertiary),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                if (mealTitle.isNotEmpty)
                  Text(
                    mealTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: _C.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: meta.light,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              meta.label,
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w600,
                color: meta.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _upcomingDayChip(Delivery d) {
    DateTime? dd;
    try {
      dd = DateTime.parse(d.date);
    } catch (_) {}
    final meta = _deliveryStatusMeta(d.status);
    return Container(
      width: 68.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dd != null ? DateFormat('dd').format(dd) : '-',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          Text(
            dd != null ? DateFormat('EEE').format(dd) : '',
            style: GoogleFonts.poppins(fontSize: 9.sp, color: _C.textSecondary),
          ),
          SizedBox(height: 4.h),
          Container(
            width: 5.w,
            height: 5.w,
            decoration: BoxDecoration(
              color: meta.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  _DeliveryStatusMeta _deliveryStatusMeta(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
      case 'COMPLETED':
        return _DeliveryStatusMeta('Delivered', _C.green, _C.greenLight);
      case 'CANCELLED':
      case 'UNDELIVERED':
        return _DeliveryStatusMeta('Cancelled', _C.red, _C.redLight);
      case 'PENDING':
      default:
        return _DeliveryStatusMeta('Scheduled', _C.amber, _C.amberLight);
    }
  }

  // ---------------------------------------------------------------------
  // Payments tab — outstanding amount + Pay Amount action (the one real
  // wallet endpoint we have). An itemized Payment History list needs its
  // own backend endpoint, which doesn't exist yet — not faked here.
  // ---------------------------------------------------------------------
  Widget _buildPaymentsTab() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [_buildWalletCard()],
  );

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
                GestureDetector(
                  onTap: () => _showDeliveryCalendarSheet(sub),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      size: 16.sp,
                      color: _C.primary,
                    ),
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
          Container(height: 0.5, color: _C.border),
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
          Container(height: 0.5, color: _C.border),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        'Pause Delivery',
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
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        'Cancel All Meals',
                        Icons.event_busy_outlined,
                        _C.red,
                        _C.redLight,
                        _C.redBorder,
                        () => _handleCancel(sub.id!),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _actionButton(
                        'Cancel Plan',
                        Icons.cancel_outlined,
                        _C.red,
                        _C.redLight,
                        _C.redBorder,
                        () => _confirmCancelPlan(sub.id!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// This subscription's deliveries laid out on a calendar — each day
  /// colored by that delivery's status (green = delivered, red =
  /// cancelled, amber = pending), using the backend's `subscriptionId`
  /// filter so this only shows deliveries tied to this exact plan, not
  /// every delivery this customer has ever had.
  void _showDeliveryCalendarSheet(ActiveSubscriptions sub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => _SubscriptionCalendarSheet(
                  subscriptionId: sub.id!,
                  planName: sub.plan?.name ?? 'Plan',
                  subscriptionCancelled: sub.status != 'ACTIVE',
                  startDate: sub.startDate,
                  endDate: sub.endDate,
                  scrollController: scrollController,
                ),
          ),
    );
  }

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

  void _showTopUpSheet() {
    final ctrl = TextEditingController();
    // Only the amount actually owed can be collected here — never more,
    // and if nothing is owed there's nothing to pay against.
    final pendingAmount = _walletBalance < 0 ? -_walletBalance : 0;
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
                      'Pay Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      pendingAmount > 0
                          ? "Pending amount: ₹$pendingAmount — cannot collect more than this"
                          : "No pending amount — nothing to collect",
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        color: _C.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: ctrl,
                      enabled: pendingAmount > 0,
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
                    if (pendingAmount > 0)
                      Row(
                        children:
                            // Only amounts that fit within what's actually
                            // owed, plus the exact full pending amount.
                            {
                              ...[
                                500,
                                1000,
                                2000,
                              ].where((amt) => amt < pendingAmount),
                              pendingAmount,
                            }.toList().map((amt) {
                              final isLast = amt == pendingAmount;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: isLast ? 0 : 8.w,
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
                                        borderRadius: BorderRadius.circular(
                                          7.r,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        amt == pendingAmount
                                            ? 'Full ₹$amt'
                                            : '₹$amt',
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
                            onPressed:
                                pendingAmount <= 0
                                    ? null
                                    : () async {
                                      final v = int.tryParse(ctrl.text) ?? 0;
                                      if (v <= 0) return;
                                      // Never collect more than what's
                                      // actually owed.
                                      if (v > pendingAmount) {
                                        AppToast.error(
                                          'Cannot collect more than the pending amount of ₹$pendingAmount',
                                        );
                                        return;
                                      }
                                      setState(() => _walletBalance += v);
                                      Get.back();
                                      final success = await updateWalletBalance(
                                        v,
                                      );
                                      if (!success && mounted) {
                                        setState(() => _walletBalance -= v);
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.primary,
                              disabledBackgroundColor: _C.border,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Pay',
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

  void _handlePause(String subId) => _showPauseSheet(subId);
  void _handleRenew(ActiveSubscriptions sub) => _showRenewSheet(sub);
  void _handleCancel(String subId) => _showCancelSheet(subId);

  /// "Cancel Plan" — stops the whole subscription outright, as opposed to
  /// "Cancel All Meals" which only cancels a chosen date range. Confirmed
  /// up front since there's no undo once the backend applies it.
  Future<void> _confirmCancelPlan(String subId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: const Text('Cancel this plan?'),
            content: const Text(
              'This stops the entire subscription immediately. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Yes, Cancel Plan',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await _cancelFullSubcription(subId: subId);
    }
  }

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
    String selectedScheduleType = "Everyday";
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
                    ).subtract(const Duration(days: 1));
                  });
                }
              }

              Future<void> pickDate(bool isStart) async {
                final now = DateTime.now();
                // Start date can be backdated (e.g. a plan that actually
                // started before it was entered into the system); end date
                // still can't be before the chosen start date.
                final firstSelectableDate =
                    isStart
                        ? DateTime(now.year - 2)
                        : (startDate ?? DateTime(now.year, now.month, now.day));
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      isStart
                          ? (startDate ?? now)
                          : (endDate ?? startDate ?? firstSelectableDate),
                  firstDate: firstSelectableDate,
                  lastDate: DateTime(2035),
                  builder:
                      (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: _C.primary,
                            onPrimary: Colors.white,
                            onSurface: _C.textPrimary,
                          ),
                        ),
                        child: child!,
                      ),
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
              ) => GestureDetector(
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

              Widget label(String text) => Padding(
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

              return GetBuilder<PlanController>(
                builder:
                    (_) => GetBuilder<PartnerController>(
                      builder:
                          (_) => SafeArea(
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
                                bottom:
                                    MediaQuery.of(ctx).viewInsets.bottom + 24.h,
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
                                          borderRadius: BorderRadius.circular(
                                            2.r,
                                          ),
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
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(color: _C.border),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value:
                                              planController.plans.any(
                                                    (p) =>
                                                        p.id == selectedPlanId,
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
                                              planController.plans
                                                  .map(
                                                    (p) => DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: p.id,
                                                      child: Text(
                                                        p.planName ?? "N/A",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 13.5.sp,
                                                              color:
                                                                  _C.textPrimary,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
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
                                                selectedScheduleType =
                                                    "Everyday";
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
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                                      child: DropdownButton<
                                                        int
                                                      >(
                                                        isExpanded: true,
                                                        value: selectedMonths,
                                                        icon: const Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color:
                                                              _C.textSecondary,
                                                        ),
                                                        items:
                                                            List.generate(
                                                                  12,
                                                                  (index) =>
                                                                      index + 1,
                                                                )
                                                                .map(
                                                                  (
                                                                    m,
                                                                  ) => DropdownMenuItem<
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
                                                                  ),
                                                                )
                                                                .toList(),
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
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
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
                                              partnerController.partners
                                                  .map(
                                                    (e) => DropdownMenuItem<
                                                      String
                                                    >(
                                                      value:
                                                          e
                                                              .deliveryPartnerProfile
                                                              ?.id ??
                                                          "",
                                                      child: Text(
                                                        e.name ?? "Unknown",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 13.5.sp,
                                                              color:
                                                                  _C.textPrimary,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
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
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
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
                                                ["Everyday", "Custom"]
                                                    .map(
                                                      (
                                                        type,
                                                      ) => DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: type,
                                                        child: Text(
                                                          type,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 13.5.sp,
                                                            color:
                                                                _C.textPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
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
                                                        selectedDays.remove(
                                                          day,
                                                        );
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
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .w400,
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
                                                keyboardType:
                                                    TextInputType.number,
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
                                                        BorderRadius.circular(
                                                          8.r,
                                                        ),
                                                    borderSide:
                                                        const BorderSide(
                                                          color: _C.border,
                                                        ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.r,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: _C.border,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.r,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
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
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: const BorderSide(
                                            color: _C.border,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: const BorderSide(
                                            color: _C.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
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
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
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
                                              _addPlanSubscriptionApi(
                                                planId: selectedPlanId!,
                                                partnerId: selectedPartnerId!,
                                                startDate: DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(startDate!),
                                                endDate: DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(endDate!),
                                                scheduleType:
                                                    selectedScheduleType
                                                        .toUpperCase(),
                                                selectedDays:
                                                    selectedScheduleType ==
                                                            "Everyday"
                                                        ? List.from(_daysOfWeek)
                                                        : selectedDays,
                                                discount:
                                                    int.tryParse(
                                                      discountCtrl.text,
                                                    ) ??
                                                    0,
                                                address:
                                                    addressCtrl.text.trim(),
                                              );
                                              Get.back();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _C.primary,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12.h,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
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
                          ),
                    ),
              );
            },
          ),
    );
  }

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
          ).subtract(const Duration(days: 1));
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
                  builder:
                      (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: _C.primary,
                            onPrimary: Colors.white,
                            onSurface: _C.textPrimary,
                          ),
                        ),
                        child: child!,
                      ),
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
              ) => GestureDetector(
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
                            builder:
                                (controller) => DropdownButtonHideUnderline(
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
                                        controller.partners
                                            .map(
                                              (e) => DropdownMenuItem<String>(
                                                value:
                                                    e
                                                        .deliveryPartnerProfile
                                                        ?.id ??
                                                    "",
                                                child: Text(
                                                  e.name ?? "Unknown",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14.sp,
                                                    color: _C.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      setSheetState(
                                        () => selectedPartnerId = val,
                                      );
                                    },
                                  ),
                                ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Discount Amount (₹)",
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
                                  _renewSubscriptionApi(
                                    subId: sub.id!,
                                    planId: sub.plan!.id!,
                                    startDate: DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(startDate!),
                                    endDate: DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(endDate!),
                                    partnerId: selectedPartnerId!,
                                    discount:
                                        discountCtrl.text.isEmpty
                                            ? "0"
                                            : discountCtrl.text,
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
                  builder:
                      (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: _C.primary,
                            onPrimary: Colors.white,
                            onSurface: _C.textPrimary,
                          ),
                        ),
                        child: child!,
                      ),
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
              ) => GestureDetector(
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
                                  _pauseSubscriptionApi(
                                    subId,
                                    DateFormat('yyyy-MM-dd').format(startDate!),
                                    DateFormat('yyyy-MM-dd').format(endDate!),
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
                  builder:
                      (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: _C.red,
                            onPrimary: Colors.white,
                            onSurface: _C.textPrimary,
                          ),
                        ),
                        child: child!,
                      ),
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
              ) => GestureDetector(
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
                                  _cancelSubscriptionApi(
                                    subId: subId,
                                    startDate: DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(startDate!),
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

/// Calendar view of one subscription's deliveries (`GET /deliveries?
/// subscriptionId=`) — each day colored by that day's delivery status, so
/// pausing/cancelling and the resulting gaps are visible at a glance.
class _SubscriptionCalendarSheet extends StatefulWidget {
  final String subscriptionId;
  final String planName;
  final String? startDate;
  final String? endDate;
  // Whether the subscription itself has been cancelled — when true, every
  // day shows cancelled-red regardless of that day's own delivery status,
  // since the backend doesn't retroactively update individual delivery
  // rows when a subscription is cancelled (they'd otherwise still show
  // their old PENDING/DELIVERED status).
  final bool subscriptionCancelled;
  final ScrollController scrollController;

  const _SubscriptionCalendarSheet({
    required this.subscriptionId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.subscriptionCancelled,
    required this.scrollController,
  });

  @override
  State<_SubscriptionCalendarSheet> createState() =>
      _SubscriptionCalendarSheetState();
}

class _SubscriptionCalendarSheetState
    extends State<_SubscriptionCalendarSheet> {
  bool _isLoading = true;
  // Keyed by day-only DateTime (time stripped) so lookups don't miss on
  // time-of-day differences in the API's date strings.
  final Map<DateTime, Delivery> _byDate = {};
  DateTime? _focusedDay;
  DateTime? _selectedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    _firstDay =
        _tryParseDate(widget.startDate) ??
        DateTime.now().subtract(const Duration(days: 30));
    _lastDay =
        _tryParseDate(widget.endDate) ??
        DateTime.now().add(const Duration(days: 30));
    _focusedDay =
        DateTime.now().isBefore(_firstDay)
            ? _firstDay
            : (DateTime.now().isAfter(_lastDay) ? _lastDay : DateTime.now());
    _fetch();
  }

  DateTime? _tryParseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _fetch() async {
    try {
      final messId = Get.find<HomeScreenController>().selectedMessId;
      if (messId == null) return;

      final uri = Uri.parse('$baseUrl/deliveries').replace(
        queryParameters: {
          'messId': messId,
          'subscriptionId': widget.subscriptionId,
          'limit': '100',
        },
      );
      final response = await get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];
        for (final item in dataList) {
          final delivery = Delivery.fromJson(item);
          try {
            _byDate[_dayOnly(DateTime.parse(delivery.date))] = delivery;
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('SUBSCRIPTION CALENDAR FETCH ERROR: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // A brighter, more attention-grabbing red than the app's usual muted
  // _C.red — cancelled days should stand out on the calendar at a glance.
  static const _cancelledRed = Color(0xFFFF3B5C);

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
      case 'COMPLETED':
        return _C.green;
      case 'CANCELLED':
        return _cancelledRed;
      case 'UNDELIVERED':
        return _C.red;
      case 'PENDING':
      default:
        return _C.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Text(
            '${widget.planName} — Delivery Calendar',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              _legendDot(_C.green, 'Delivered'),
              SizedBox(width: 12.w),
              _legendDot(_C.amber, 'Pending'),
              SizedBox(width: 12.w),
              _legendDot(_cancelledRed, 'Cancelled'),
            ],
          ),
          SizedBox(height: 12.h),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: const Center(
                child: CircularProgressIndicator(color: _C.primary),
              ),
            )
          else ...[
            TableCalendar<Delivery>(
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay!,
              selectedDayPredicate:
                  (day) => _selectedDay != null && isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focused) => _focusedDay = focused,
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) => _dayCell(day),
                todayBuilder: (context, day, _) => _dayCell(day, isToday: true),
                selectedBuilder:
                    (context, day, _) => _dayCell(day, isSelected: true),
              ),
            ),
            if (_selectedDay != null) _selectedDayDetails(),
          ],
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5.sp,
            color: _C.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _dayCell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final delivery = _byDate[_dayOnly(day)];
    final withinRange =
        !day.isBefore(_dayOnly(_firstDay)) && !day.isAfter(_dayOnly(_lastDay));
    final color =
        widget.subscriptionCancelled && withinRange
            ? _cancelledRed
            : (delivery != null ? _statusColor(delivery.status) : null);

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color:
            isSelected
                ? _C.primary.withValues(alpha: 0.15)
                : color?.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border:
            isToday
                ? Border.all(color: _C.primary, width: 1.2)
                : (color != null ? Border.all(color: color, width: 1) : null),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: _C.textPrimary,
        ),
      ),
    );
  }

  Widget _selectedDayDetails() {
    final delivery = _byDate[_dayOnly(_selectedDay!)];
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd MMM yyyy').format(_selectedDay!),
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
              ),
              if (widget.subscriptionCancelled)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _cancelledRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'CANCELLED',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: _cancelledRed,
                    ),
                  ),
                )
              else if (delivery == null)
                Text(
                  'No delivery',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: _C.textTertiary,
                  ),
                ),
            ],
          ),
          // Breakfast / Lunch / Dinner for this day — each with its own
          // status and its own Cancel action, independent of the other
          // meals that day.
          if (!widget.subscriptionCancelled &&
              delivery != null &&
              delivery.deliveryVariations.isNotEmpty) ...[
            SizedBox(height: 10.h),
            ...delivery.deliveryVariations.map(
              (v) => _variationRow(delivery, v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _variationRow(Delivery delivery, DeliveryVariation v) {
    final title = v.variation?.title ?? 'Meal';
    final status = v.status.toUpperCase();
    final color = _statusColor(status);

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: _C.textPrimary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          // Per-meal cancel is disabled: the backend's status endpoint
          // doesn't scope by delivery, so cancelling one customer's meal
          // here was cancelling it for every customer sharing that meal
          // type. Re-enable once that's fixed server-side.
        ],
      ),
    );
  }

  // Per-meal cancel from the calendar is disabled — see the note in
  // _variationRow. The backend's PATCH /deliveries/:id/variations/:id/
  // status endpoint doesn't scope its update by the delivery id, so it
  // was cancelling the same meal type for every customer, not just the
  // one selected here. Restore this once that's fixed server-side.
}

class _DeliveryStatusMeta {
  final String label;
  final Color color;
  final Color light;
  const _DeliveryStatusMeta(this.label, this.color, this.light);
}
