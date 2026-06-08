import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/PartnerScreen/Model/PartnerModel.dart';
import 'package:mess/main.dart';

class PartnerController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeScreenController dashboardController =
      Get.find<HomeScreenController>();

  List<Partner> partners = [];
  Partner? selectedPartner;
  bool isLoading = false;
  bool isReady = false;

  int currentPage = 1;
  int totalPages = 1;
  int totalRecords = 0;
  int limit = 10;

  String errorMessage = '';

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> ensureLoaded() async {
    if (isReady) return;
    if (partners.isEmpty) {
      await fetchPartners();
    }
    isReady = true;
    update();
  }

  Future<void> fetchPartners() async {
    isLoading = true;
    errorMessage = '';
    update();

    final messId = dashboardController.selectedMessId;
    if (messId == null) {
      _showToast("Please select a mess first", isError: true);
      isLoading = false;
      update();
      return;
    }

    try {
      final url = Uri.parse(
        '$baseUrl/delivery-agent/?messId=$messId&page=$currentPage&limit=$limit',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        currentPage = data['currentPage'] ?? 1;
        totalPages = data['totalPages'] ?? 1;
        totalRecords = data['totalRecords'] ?? 0;

        final List<dynamic> list = data['data'] ?? [];
        partners = list.map((e) => Partner.fromJson(e)).toList();
      } else {
        errorMessage =
            "Failed to fetch partners (Status: ${response.statusCode})";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      isReady = true;
      update();
    }
  }

  Future<void> fetchPartnerById(String id) async {
    try {
      isLoading = true;
      update();

      final url = Uri.parse('$baseUrl/delivery-agent/$id');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final partnerData = jsonData['data'] ?? jsonData;
        selectedPartner = Partner.fromJson(partnerData);
      }
    } catch (e) {
      debugPrint("❌ fetchPartnerById error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<bool> addPartner({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      isLoading = true;
      update();

      final messId = dashboardController.selectedMessId;
      if (messId == null) {
        _showToast("Please select a mess first");
        return false;
      }

      // BUG #2409 — prevent duplicate phone numbers (checked against existing partners)
      final isDuplicate = partners.any((p) => p.phone.trim() == phone.trim());
      if (isDuplicate) {
        _showToast(
          "A partner with this phone number already exists",
          isError: true,
        );
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/delivery-agent'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: json.encode({
          "name": name,
          "phone": phone,
          "address": address,
          "messId": messId,
        }),
      );

      if (response.statusCode == 201) {
        await refreshPartners();
        await dashboardController.fetchDashboardStats();
        _showToast("Partner added successfully");
        return true;
      } else {
        final err = json.decode(response.body);
        _showToast(err['message'] ?? "Failed to add partner", isError: true);
        return false;
      }
    } catch (e) {
      _showToast(e.toString(), isError: true);
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // BUG #2412 — Fix: send is_active correctly so partner status is actually saved
  Future<bool> updatePartner({
    required String id,
    String? name,
    String? phone,
    bool? status,
  }) async {
    try {
      isLoading = true;
      update();

      final messId = dashboardController.selectedMessId;

      final Map<String, dynamic> body = {"messId": messId};

      if (name != null && name.isNotEmpty) body["name"] = name;
      if (phone != null && phone.isNotEmpty) body["phone"] = phone;

      // BUG #2412 — send is_active (not "status") to match backend field
      if (status != null) body["is_active"] = status;

      debugPrint("📡 UPDATE PARTNER BODY: ${json.encode(body)}");

      final response = await http.patch(
        Uri.parse('$baseUrl/delivery-agent/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: json.encode(body),
      );

      debugPrint("📡 UPDATE PARTNER STATUS: ${response.statusCode}");
      debugPrint("📡 UPDATE PARTNER BODY RESP: ${response.body}");

      if (response.statusCode == 200) {
        await fetchPartners();
        _showToast("Partner updated successfully");
        return true;
      } else {
        final err = json.decode(response.body);
        _showToast(err['message'] ?? "Failed to update partner", isError: true);
        return false;
      }
    } catch (e) {
      _showToast(e.toString(), isError: true);
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deletePartner(String id) async {
    try {
      isLoading = true;
      update();

      final messId = dashboardController.selectedMessId;
      if (messId == null) {
        _showToast("Please select a mess first", isError: true);
        return;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/delivery-agent/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: json.encode({"messId": messId}),
      );

      if (response.statusCode == 200) {
        await refreshPartners();
        _showToast("Partner deleted successfully");
        await dashboardController.fetchDashboardStats();
        await Future.delayed(const Duration(milliseconds: 600));
        if (Get.previousRoute.isNotEmpty) {
          Get.back();
        }
      } else {
        final err = json.decode(response.body);
        _showToast(err['message'] ?? "Failed to delete partner", isError: true);
      }
    } catch (e) {
      _showToast(e.toString(), isError: true);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshPartners() async {
    currentPage = 1;
    await fetchPartners();
  }

  void changePage(int newPage) {
    if (newPage > 0 && newPage <= totalPages) {
      currentPage = newPage;
      fetchPartners();
    }
  }

  void changeLimit(int newLimit) {
    limit = newLimit;
    currentPage = 1;
    fetchPartners();
  }
}
