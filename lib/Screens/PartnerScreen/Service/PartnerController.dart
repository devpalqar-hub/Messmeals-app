import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/PartnerScreen/Model/PartnerModel.dart';
import 'package:mess/main.dart';

class PartnerController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final DashboardController dashboardController = Get.find<DashboardController>();

  var partners = <Partner>[].obs;
  var selectedPartner = Rxn<Partner>();
  var isLoading = false.obs;
  var isReady = false.obs;

  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalRecords = 0.obs;
  var limit = 10.obs;

  RxString errorMessage = ''.obs;

  Future<void> ensureLoaded() async {
    if (isReady.value) return;
    if (partners.isEmpty) {
      await fetchPartners();
    }
    isReady.value = true;
  }

  Future<void> fetchPartners() async {
    isLoading.value = true;
    errorMessage.value = '';

    final messId = authController.selectedMessId.value;
    if (messId.isEmpty) {
      _showSnackBar("Error", "Please select a mess first", Colors.red);
      isLoading.value = false;
      return;
    }

    try {
      final url = Uri.parse(
        '$baseUrl/delivery-agent/?messId=$messId&page=${currentPage.value}&limit=${limit.value}',
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

        currentPage.value = data['currentPage'] ?? 1;
        totalPages.value = data['totalPages'] ?? 1;
        totalRecords.value = data['totalRecords'] ?? 0;

        final List<dynamic> list = data['data'] ?? [];
        partners.value = list.map((e) => Partner.fromJson(e)).toList();
      } else {
        errorMessage.value = "Failed to fetch partners (Status: ${response.statusCode})";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isReady.value = true;
    }
  }

  Future<void> fetchPartnerById(String id) async {
    try {
      isLoading(true);
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
        selectedPartner.value = Partner.fromJson(partnerData);
      } else {
        _showSnackBar("Error", "Failed to fetch partner details", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error", e.toString(), Colors.red);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addPartner({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      isLoading.value = true;
      final messId = authController.selectedMessId.value;

      if (messId.isEmpty) {
        _showSnackBar("Error", "Please select a mess first", Colors.red);
        return;
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
          "email": email,
          "address": address,
          "messId": messId,
        }),
      );

      if (response.statusCode == 201) {
        await refreshPartners();
        Get.back();
        _showSnackBar("Success", "Partner added successfully", Colors.green);
         await dashboardController.fetchDashboardStats(); 
      } else {
        final err = json.decode(response.body);
        _showSnackBar("Error", err['message'] ?? "Failed to add partner", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error", e.toString(), Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePartner({
    required String id,
    String? name,
    String? phone,
    String? email,
    String? address,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      final messId = authController.selectedMessId.value;

      if (messId.isEmpty) {
        _showSnackBar("Error", "Please select a mess first", Colors.red);
        return;
      }

      final payload = {
        if (name != null) "name": name,
        if (phone != null) "phone": phone,
        if (email != null) "email": email,
        if (address != null) "address": address,
        if (isActive != null) "isActive": isActive,
        "messId": messId,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/delivery-agent/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        await fetchPartnerById(id);
        await fetchPartners();
        Get.back();
        _showSnackBar("Updated", "Partner updated successfully", Colors.green);
      } else {
        final err = json.decode(response.body);
        _showSnackBar("Error", err['message'] ?? "Failed to update partner", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error", e.toString(), Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePartner(String id) async {
    try {
      isLoading.value = true;
      final messId = authController.selectedMessId.value;

      if (messId.isEmpty) {
        _showSnackBar("Error", "Please select a mess first", Colors.red);
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
        _showSnackBar("Deleted", "Partner deleted successfully", Colors.green);
         await dashboardController.fetchDashboardStats(); 
        await Future.delayed(const Duration(milliseconds: 600));
        if (Get.previousRoute.isNotEmpty) {
          Get.back();
        }
      } else {
        final err = json.decode(response.body);
        _showSnackBar("Error", err['message'] ?? "Failed to delete partner", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error", e.toString(), Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPartners() async {
    currentPage.value = 1;
    await fetchPartners();
  }

  void changePage(int newPage) {
    if (newPage > 0 && newPage <= totalPages.value) {
      currentPage.value = newPage;
      fetchPartners();
    }
  }

  void changeLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchPartners();
  }

  void _showSnackBar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withOpacity(0.1),
      colorText: color,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }
}
