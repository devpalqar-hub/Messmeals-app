import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Models/PartnerDeliveryModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart';

class PartnerDeliveryController extends GetxController {
  bool isLoading = false;
  bool isDetailLoading = false;
  bool isUpdatingStatus = false;
  String errorMessage = '';

  List<PartnerDeliveryModel> deliveries = [];
  PartnerDeliveryModel? selectedDelivery;

  bool isLoadingToday = false;
  List<PartnerDeliveryModel> todayDeliveries = [];

  int get assignedToday => todayDeliveries.length;
  int get deliveredToday =>
      todayDeliveries.where((d) => d.status == 'DELIVERED').length;
  int get pendingToday =>
      todayDeliveries.where((d) => d.status == 'PENDING').length;
  List<PartnerDeliveryModel> get recentDeliveries =>
      todayDeliveries.take(5).toList();

  String searchQuery = '';

  List<PartnerDeliveryModel> get filteredDeliveries {
    if (searchQuery.trim().isEmpty) return deliveries;
    final q = searchQuery.toLowerCase();
    return deliveries
        .where(
          (d) =>
              d.customerName.toLowerCase().contains(q) ||
              d.address.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDeliveries();
  }

  /// Groups flattened `/deliveries/variations` rows (one row per meal) back
  /// into one model per `deliveryId`, preserving the order deliveries first
  /// appeared in.
  List<PartnerDeliveryModel> _groupVariationRows(List rows) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    final order = <String>[];
    for (final e in rows) {
      final row = Map<String, dynamic>.from(e);
      final deliveryId = (row['deliveryId'] ?? '').toString();
      if (deliveryId.isEmpty) continue;
      if (!grouped.containsKey(deliveryId)) order.add(deliveryId);
      (grouped[deliveryId] ??= []).add(row);
    }
    return order
        .map((id) => PartnerDeliveryModel.fromVariationGroup(grouped[id]!))
        .toList();
  }

  /// [status] — PENDING / DELIVERED / UNDELIVERED / CANCELLED, empty = all.
  /// [date] — a specific day, null = no date filter.
  Future<void> fetchDeliveries({String status = '', DateTime? date}) async {
    isLoading = true;
    update();

    try {
      final uri = Uri.parse('$baseUrl/deliveries/variations').replace(
        queryParameters: {
          if (status.isNotEmpty) 'status': status,
          if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
          'page': '1',
          'limit': '200',
        },
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List rows = decoded['data'] ?? [];
        if (rows.isNotEmpty) {
          debugPrint(
            'DELIVERIES/VARIATIONS — sample customer object: '
            '${jsonEncode(rows.first['customer'])}',
          );
        }
        deliveries = _groupVariationRows(rows);
        errorMessage = '';
      } else {
        errorMessage = 'Failed to load deliveries';
      }
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('FETCH PARTNER DELIVERIES ERROR: $e');
      debugPrint(st.toString().split('\n').take(20).join('\n'));
    } finally {
      isLoading = false;
      update();
    }
  }

  /// For the Home screen's summary card + recent list.
  Future<void> fetchTodaySummary() async {
    isLoadingToday = true;
    update();

    try {
      final uri = Uri.parse('$baseUrl/deliveries/variations').replace(
        queryParameters: {
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'page': '1',
          'limit': '200',
        },
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List rows = decoded['data'] ?? [];
        todayDeliveries = _groupVariationRows(rows);
      }
    } catch (e) {
      debugPrint('FETCH TODAY SUMMARY ERROR: $e');
    } finally {
      isLoadingToday = false;
      update();
    }
  }

  Future<void> fetchDeliveryDetail(String id) async {
    // Prefer the copy already loaded from GET /deliveries/variations (the
    // reliable endpoint the list screen uses) over re-fetching from GET
    // /delivery-agent/my/deliveries/:id — that single-item endpoint shares
    // the gaps of its list counterpart this app moved away from earlier,
    // and was missing a usable `id`, which is why the Delivered/Undelivered
    // buttons were sending an empty deliveryId and failing.
    final existing = deliveries.firstWhereOrNull((d) => d.id == id);
    if (existing != null) {
      selectedDelivery = existing;
      update();
      return;
    }

    isDetailLoading = true;
    selectedDelivery = null;
    update();

    try {
      final uri = Uri.parse('$baseUrl/delivery-agent/my/deliveries/$id');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data =
            decoded is Map && decoded['data'] is Map
                ? decoded['data']
                : decoded;
        selectedDelivery = PartnerDeliveryModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
    } catch (e) {
      debugPrint('FETCH PARTNER DELIVERY DETAIL ERROR: $e');
    } finally {
      isDetailLoading = false;
      update();
    }
  }

  /// [status] — 'DELIVERED' or 'UNDELIVERED'.
  ///
  /// Uses the delivery-agent-scoped status endpoint (the general admin one,
  /// `PATCH /deliveries/:id/status`, was rejecting a delivery-agent token).
  /// Swagger doesn't document this endpoint's request body (empty schema),
  /// so the field names below (`deliveryId`/`status`) are a best guess —
  /// confirm against a real request/response before relying on this.
  Future<bool> updateDeliveryStatus(String id, String status) async {
    isUpdatingStatus = true;
    update();

    try {
      final uri = Uri.parse('$baseUrl/delivery-agent/update/status');
      final response = await http
          .put(
            uri,
            headers: _headers,
            body: jsonEncode({"deliveryId": id, "status": status}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = deliveries.indexWhere((d) => d.id == id);
        AppToast.success(
          status == 'DELIVERED'
              ? 'Delivery marked as delivered'
              : 'Delivery marked as undelivered',
        );
        await Future.wait([fetchDeliveries(), fetchTodaySummary()]);
        if (selectedDelivery?.id == id) {
          await fetchDeliveryDetail(id);
        }
        return index != -1 || true;
      }

      debugPrint('UPDATE DELIVERY STATUS: ${response.statusCode} ${response.body}');
      AppToast.error('Failed to update delivery: ${_extractErrorMessage(response.body)}');
      return false;
    } catch (e) {
      debugPrint('UPDATE DELIVERY STATUS ERROR: $e');
      AppToast.error('Something went wrong');
      return false;
    } finally {
      isUpdatingStatus = false;
      update();
    }
  }

  void updateSearch(String query) {
    searchQuery = query;
    update();
  }

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": bearerToken,
  };

  String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      final msg = decoded is Map ? decoded['message'] : null;
      if (msg is List) return msg.join(', ');
      if (msg is String && msg.isNotEmpty) return msg;
    } catch (_) {}
    return "please try again";
  }
}
