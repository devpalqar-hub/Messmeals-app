// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
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
  int get completedToday =>
      todayDeliveries.where((d) => d.status == 'COMPLETED').length;
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

  /// [status] — PENDING / COMPLETED / CANCELLED, empty = all.
  /// [date] — a specific day, null = no date filter.
  Future<void> fetchDeliveries({String status = '', DateTime? date}) async {
    isLoading = true;
    update();

    try {
      final uri = Uri.parse('$baseUrl/delivery-agent/my/deliveries').replace(
        queryParameters: {
          'status': status,
          'date': date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
          'page': '1',
          'limit': '50',
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list =
            decoded is List ? decoded : (decoded['data'] ?? decoded['deliveries'] ?? []);
        deliveries =
            list.map((e) => PartnerDeliveryModel.fromJson(Map<String, dynamic>.from(e))).toList();
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
      final uri = Uri.parse('$baseUrl/delivery-agent/my/deliveries').replace(
        queryParameters: {
          'status': '',
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'page': '1',
          'limit': '50',
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list =
            decoded is List ? decoded : (decoded['data'] ?? decoded['deliveries'] ?? []);
        todayDeliveries =
            list.map((e) => PartnerDeliveryModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('FETCH TODAY SUMMARY ERROR: $e');
    } finally {
      isLoadingToday = false;
      update();
    }
  }

  Future<void> fetchDeliveryDetail(String id) async {
    isDetailLoading = true;
    selectedDelivery = null;
    update();

    try {
      final uri = Uri.parse('$baseUrl/delivery-agent/my/deliveries/$id');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map && decoded['data'] is Map ? decoded['data'] : decoded;
        selectedDelivery = PartnerDeliveryModel.fromJson(Map<String, dynamic>.from(data));
      } else {
        // Fall back to whatever we already have in the list, if any.
        selectedDelivery = deliveries.firstWhereOrNull((d) => d.id == id);
      }
    } catch (e) {
      debugPrint('FETCH PARTNER DELIVERY DETAIL ERROR: $e');
      selectedDelivery = deliveries.firstWhereOrNull((d) => d.id == id);
    } finally {
      isDetailLoading = false;
      update();
    }
  }

  Future<bool> markCompleted(String id) async {
    isUpdatingStatus = true;
    update();

    try {
      final uri = Uri.parse('$baseUrl/deliveries/$id/status');
      final response = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode({"status": "COMPLETED"}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = deliveries.indexWhere((d) => d.id == id);
        AppToast.success('Delivery marked as completed');
        await Future.wait([fetchDeliveries(), fetchTodaySummary()]);
        if (selectedDelivery?.id == id) {
          await fetchDeliveryDetail(id);
        }
        return index != -1 || true;
      }

      AppToast.error('Failed to update delivery');
      return false;
    } catch (e) {
      debugPrint('MARK COMPLETED ERROR: $e');
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
}

*/
