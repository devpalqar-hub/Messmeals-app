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

  // Standard variables instead of .obs
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
    update(); // Notify UI to show loading state

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
      update(); // Refresh UI with new data
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
      } else {}
    } catch (e) {
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

      final response = await http.post(
        Uri.parse('$baseUrl/delivery-agent'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: json.encode({
          "name": name,
          "phone": phone,
          //   "email": email,
          "address": address,
          "messId": messId,
        }),
      );

      if (response.statusCode == 201) {
        await refreshPartners();
        await dashboardController.fetchDashboardStats();
        _showToast("Partner added successfully");
        return true; // ✅ IMPORTANT
      } else {
        final err = json.decode(response.body);
        _showToast(err['message'] ?? "Failed to add partner");
        return false;
      }
    } catch (e) {
      _showToast(e.toString());
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

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

      final response = await http.patch(
        Uri.parse('$baseUrl/delivery-agent/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: json.encode({
          if (name != null) "name": name,
          if (phone != null) "phone": phone,
          if (status != null) "status": status,
          "messId": messId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchPartners();
        _showToast("Partner updated");
        return true; // ✅ IMPORTANT
      } else {
        final err = json.decode(response.body);
        _showToast(err['message'] ?? "Failed to update");
        return false;
      }
    } catch (e) {
      _showToast(e.toString());
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
      }
    } catch (e) {
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
