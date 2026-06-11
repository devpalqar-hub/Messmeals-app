import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Assuming your global configurations exist here
import 'package:mess/main.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/Screens/Utils/TitleText.dart';
import 'package:mess/Screens/DeliveriesScreen/Views/GenerateCard.dart';
import 'package:mess/Screens/DeliveriesScreen/Model/DeliveryModel.dart';

/// =========================================================================
/// 🎨 COLOR PALETTE DESIGN SYSTEM
/// =========================================================================
class _C {
  static const background = Color(0xffF7F9FB);
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

/// =========================================================================
/// 📦 VARIATION MODEL
/// =========================================================================
class VariationModel {
  final String id;
  final String title;
  final bool isActive;

  VariationModel({
    required this.id,
    required this.title,
    required this.isActive,
  });

  factory VariationModel.fromJson(Map<String, dynamic> json) {
    return VariationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}

/// =========================================================================
/// 🎮 DELIVERIES STATE CONTROLLER
/// =========================================================================
class DeliveriesController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeScreenController dashboardController =
      Get.find<HomeScreenController>();

  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasMoreData = true;

  List<Delivery> deliveries = [];
  List<VariationModel> variations = [];

  int page = 1;
  int limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchVariations();
  }

  /// 🍱 Fetch Variation Options for Filter Header
  Future<void> fetchVariations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/variation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        variations = jsonData.map((e) => VariationModel.fromJson(e)).toList();
        update();
      }
    } catch (e) {
      debugPrint("Error fetching variations: $e");
    }
  }

  /// 🚚 Fetch Filtered Deliveries list (with Pagination)
  Future<void> fetchDeliveries({
    DateTime? date,
    String? status,
    String? variationId,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore) {
      if (!hasMoreData || isFetchingMore) return;
      isFetchingMore = true;
      page++;
      update();
    } else {
      isLoading = true;
      page = 1;
      hasMoreData = true;
      deliveries.clear();
      update();
    }

    try {
      final messId = dashboardController.selectedMessId;
      if (messId == null) {
        AppToast.error("Please select a mess first");
        return;
      }

      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'messId': messId,
      };

      if (date != null) {
        queryParams['date'] = date.toIso8601String().split('T')[0];
      }

      if (status != null && status.trim().isNotEmpty) {
        queryParams['status'] = status.toUpperCase();
      }

      if (variationId != null && variationId.trim().isNotEmpty) {
        queryParams['variationId'] = variationId;
      }

      final uri = Uri.parse(
        '$baseUrl/deliveries',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];
        final List<Delivery> newDeliveries =
            dataList.map((e) => Delivery.fromJson(e)).toList();

        if (newDeliveries.length < limit) {
          hasMoreData = false;
        }

        if (isLoadMore) {
          deliveries.addAll(newDeliveries);
        } else {
          deliveries = newDeliveries;
        }
      } else {
        AppToast.error('Failed to fetch deliveries (${response.statusCode})');
      }
    } catch (e) {
      AppToast.error('Failed to load deliveries');
    } finally {
      isLoading = false;
      isFetchingMore = false;
      update();
    }
  }

  /// ⚡ PATCH: Update specific variant status inside a Delivery
  Future<bool> patchVariationStatus({
    required String deliveryId,
    required String variationUuid,
    required String newStatus,
  }) async {
    try {
      // Don't set full page isLoading to true here, or it resets the list scroll visually
      final url = Uri.parse(
        '$baseUrl/deliveries/$deliveryId/variations/$variationUuid/status',
      );
      final body = json.encode({"status": newStatus.toUpperCase()});

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppToast.success('Variation updated to $newStatus successfully');
        await dashboardController.fetchDashboardStats();
        return true;
      } else {
        final msg = json.decode(response.body)['message'] ?? 'Unknown error';
        AppToast.error('Failed to update status: $msg');
        return false;
      }
    } catch (e) {
      AppToast.error('Error updating variation status');
      return false;
    }
  }

  Future<void> generateDeliveriesByDate(DateTime date) async {
    try {
      isLoading = true;
      update();

      final response = await http.post(
        Uri.parse('$baseUrl/deliveries/create-by-date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
        body: json.encode({"date": date.toIso8601String().split('T')[0]}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success('Deliveries generated successfully');
        await dashboardController.fetchDashboardStats();
        await fetchDeliveries(date: date);
      } else {
        final msg = json.decode(response.body)['message'] ?? 'Unknown error';
        AppToast.error('Failed to generate: $msg');
      }
    } catch (e) {
      AppToast.error('Error generating deliveries: $e');
    } finally {
      isLoading = false;
      update();
    }
  }
}

/// =========================================================================
/// 🖥️ MAIN SCREEN VIEW
/// =========================================================================
class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  final DeliveriesController controller = Get.put(DeliveriesController());
  final ScrollController _scrollController = ScrollController();

  String selectedStatus = "All Status";
  String selectedVariationId = "All Meals";
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    controller.fetchDeliveries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _triggerLoadMore();
    }
  }

  void _triggerFilterSearch() {
    controller.fetchDeliveries(
      date: selectedDate,
      status:
          selectedStatus == "All Status" ? null : selectedStatus.toUpperCase(),
      variationId:
          selectedVariationId == "All Meals" ? null : selectedVariationId,
      isLoadMore: false,
    );
  }

  void _triggerLoadMore() {
    controller.fetchDeliveries(
      date: selectedDate,
      status:
          selectedStatus == "All Status" ? null : selectedStatus.toUpperCase(),
      variationId:
          selectedVariationId == "All Meals" ? null : selectedVariationId,
      isLoadMore: true,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      _triggerFilterSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<DeliveriesController>(
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TittleText(text: "Deliveries"),
                      
                    ],
                  ),
                  SizedBox(height: 14.h),

                  _buildFilterSystem(context),
                  SizedBox(height: 14.h),

                  Expanded(
                    child:
                        controller.isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: _C.primary,
                              ),
                            )
                            : controller.deliveries.isEmpty
                            ? Center(
                              child: Text(
                                "No deliveries found matching filters",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _C.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                            : ListView.builder(
                              controller: _scrollController,
                              itemCount:
                                  controller.deliveries.length +
                                  (controller.isFetchingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == controller.deliveries.length) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: _C.primary,
                                      ),
                                    ),
                                  );
                                }
                                return OrderCard(
                                  delivery: controller.deliveries[index],
                                  onRefreshNeeded: _triggerFilterSearch,
                                );
                              },
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSystem(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _dropdown(
                value: selectedStatus,
                items: ["All Status", "Pending", "Progress", "Delivered"],
                onChanged: (v) {
                  setState(() => selectedStatus = v!);
                  _triggerFilterSearch();
                },
              ),
            ),
            SizedBox(width: 8.w),
           Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: _C.border),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? "Select Date"
                            : DateFormat('dd MMM yyyy').format(selectedDate!),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _C.textPrimary,
                        ),
                      ),
                      // ✅ FIX: show X to clear date, calendar icon when no date
                      selectedDate != null
                          ? GestureDetector(
                            onTap: () {
                              setState(() => selectedDate = null);
                              _triggerFilterSearch();
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 16.sp,
                              color: _C.red,
                            ),
                          )
                          : Icon(
                            Icons.calendar_today_rounded,
                            size: 16.sp,
                            color: _C.textSecondary,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _dropdown(
          value: selectedVariationId,
          items: ["All Meals", ...controller.variations.map((v) => v.id)],
          itemLabels: {
            "All Meals": "All Meals",
            ...{for (var v in controller.variations) v.id: v.title},
          },
          onChanged: (v) {
            setState(() => selectedVariationId = v!);
            _triggerFilterSearch();
          },
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: _C.surface,
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _C.textSecondary,
          ),
          isExpanded: true,
          onChanged: onChanged,
          items:
              items.map((v) {
                return DropdownMenuItem<String>(
                  value: v,
                  child: Text(
                    itemLabels != null ? (itemLabels[v] ?? v) : v,
                    style: TextStyle(fontSize: 13.sp, color: _C.textPrimary),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

/// =========================================================================
/// 📇 COMPACT ORDER CARD (STATUS & ACTIONS IN EXPANDED VIEW)
/// =========================================================================
class OrderCard extends StatefulWidget {
  final Delivery delivery;
  final VoidCallback onRefreshNeeded;

  const OrderCard({
    super.key,
    required this.delivery,
    required this.onRefreshNeeded,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _expanded = false;
  final DeliveriesController _controller = Get.find();

  bool _has(String? v) => v != null && v.trim().isNotEmpty;

  String get formattedDate {
    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(DateTime.parse(widget.delivery.date));
    } catch (_) {
      return widget.delivery.date;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return _C.green;
      case 'PROGRESS':
        return _C.amber;
      default:
        return _C.red;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return _C.greenLight;
      case 'PROGRESS':
        return _C.amberLight;
      default:
        return _C.redLight;
    }
  }

  void _showStatusUpdateSheet(BuildContext context, dynamic deliveryVar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Change Status: ${deliveryVar.variation?.title ?? 'Meal'}",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: _C.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                ...["PENDING", "PROGRESS", "DELIVERED"].map((status) {
                  final isCurrent =
                      deliveryVar.status.toString().toUpperCase() == status;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      status,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: _getStatusColor(status),
                      ),
                    ),
                    trailing:
                        isCurrent
                            ? const Icon(
                              Icons.check_circle,
                              color: _C.primary,
                              size: 20,
                            )
                            : null,
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await _controller.patchVariationStatus(
                        deliveryId: widget.delivery.id,
                        variationUuid: deliveryVar.variationId,
                        newStatus: status,
                      );
                      if (success) {
                        // Refresh to reflect specific changes.
                        widget.onRefreshNeeded();
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.delivery.customer;
    final user = customer?.user;
    final plan = widget.delivery.plan;
    final variations = widget.delivery.deliveryVariations ?? [];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🟢 TOP COMPACT VIEW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBg(widget.delivery.status),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            widget.delivery.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(widget.delivery.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: _C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _has(user?.name) ? user!.name : "Unknown Customer",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${plan?.price ?? 0}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _C.textPrimary,
                    ),
                  ),
                  Text(
                    plan?.planName ?? '',
                    style: TextStyle(fontSize: 11.sp, color: _C.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          /// 🔻 EXPAND TOGGLE & HIDDEN DATA
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_has(user?.phone))
                  Expanded(child: _rowInfo(Icons.call_outlined, user!.phone)),
                if (!_has(user?.phone)) const Spacer(),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: _C.textTertiary,
                  size: 20.sp,
                ),
              ],
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child:
                !_expanded
                    ? const SizedBox.shrink()
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_has(customer?.address)) ...[
                          SizedBox(height: 4.h),
                          _rowInfo(
                            Icons.location_on_outlined,
                            customer!.address,
                          ),
                        ],
                        SizedBox(height: 10.h),
                        const Divider(color: _C.border, height: 1),
                        SizedBox(height: 10.h),

                        /// 🍱 Variations Status
                        Text(
                          "Assigned Variations Status:",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.textSecondary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children:
                              variations.map((v) {
                                final title = v.variation?.title ?? 'Meal';
                                final vStatus =
                                    v.status.toString().toUpperCase();
                                return InkWell(
                                  onTap:
                                      () => _showStatusUpdateSheet(context, v),
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusBg(vStatus),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: _getStatusColor(
                                          vStatus,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "$title: ",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: _C.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          vStatus,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: _getStatusColor(vStatus),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 10.sp,
                                          color: _getStatusColor(vStatus),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        SizedBox(height: 12.h),

                        /// 🗺️ Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _actionButton(
                                Icons.map_outlined,
                                "Map",
                                _C.primary,
                                _openInMap,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _actionButton(
                                Icons.phone_forwarded_outlined,
                                "Call",
                                _C.green,
                                _callNow,
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

  Widget _rowInfo(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: _C.textSecondary),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11.sp, color: _C.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        height: 32.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: color.withOpacity(0.4)),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMap() async {
    final address = widget.delivery.customer?.address;
    if (!_has(address)) return;
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address!)}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      AppToast.error("Could not open maps application");
    }
  }

  Future<void> _callNow() async {
    final phone = widget.delivery.customer?.user?.phone;
    if (!_has(phone)) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppToast.error("Could not start phone call channel");
    }
  }
}
