import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/PlanScreen/Models/PlanModel.dart';
import 'package:mess/main.dart';

class PlanController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final DashboardController dashboardController = Get.find<DashboardController>();


  RxBool isLoading = false.obs;
  RxBool isReady = false.obs;
  RxList<PlanModel> plans = <PlanModel>[].obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt limit = 10.obs;
  RxString errorMessage = ''.obs;
  var searchQuery = ''.obs;

  List<PlanModel> get filteredPlans {
    if (searchQuery.isEmpty) return plans;
    final query = searchQuery.value.toLowerCase();
    return plans.where((plan) =>
      plan.planName.toLowerCase().contains(query) ||
      plan.description.toLowerCase().contains(query)
    ).toList();
  }

  Future<void> ensureLoaded() async {
    if (isReady.value) return;
    if (plans.isEmpty) {
      await fetchPlans(page: currentPage.value, perPage: limit.value);
    }
    isReady.value = true;
  }

  Future<void> fetchPlans({int? page, int? perPage}) async {
    isLoading.value = true;
    errorMessage.value = '';
    final int pageNumber = page ?? currentPage.value;
    final int itemsPerPage = perPage ?? limit.value;
    final messId = authController.selectedMessId.value;

    try {
      final url = Uri.parse(
        "$baseUrl/plans?messId=$messId&page=$pageNumber&limit=$itemsPerPage",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> planList = data['data'];
        final meta = data['meta'];
        plans.value = planList.map((e) => PlanModel.fromJson(e)).toList();
        currentPage.value = meta['page'] ?? 1;
        totalPages.value = meta['totalPages'] ?? 1;
        limit.value = meta['limit'] ?? itemsPerPage;
      } else {
        errorMessage.value = "Failed to fetch plans (Status: ${response.statusCode})";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isReady.value = true;
    }
  }

  Future<void> addPlan({
    required String planName,
    required String price,
    required String minPrice,
    required String description,
    required List<String> variationIds,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;
      final messId = authController.selectedMessId.value;
      final uri = Uri.parse("$baseUrl/plans");
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        "Authorization": bearerToken,
      });

      request.fields['planName'] = planName;
      request.fields['price'] = price;
      request.fields['minPrice'] = minPrice;
      request.fields['description'] = description;
      request.fields['variationIds'] = jsonEncode(variationIds);
      request.fields['messId'] = messId;

      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('planImages', imageFile.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        Get.back();
        await refreshPlans();
         await dashboardController.fetchDashboardStats(); 
        _showSnackBar(
          title: "Success",
          message: "Plan added successfully",
          color: Colors.green,
        );
      } else {
        _showSnackBar(
          title: "Error",
          message: "Failed to add plan: $responseBody",
          color: Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        title: "Error",
        message: e.toString(),
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editPlan({
    required String id,
    required String planName,
    required String price,
    required String minPrice,
    required String description,
    required List<String> variationIds,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;

      final messId = authController.selectedMessId.value;
      final uri = Uri.parse("$baseUrl/plans/$id");
      var request = http.MultipartRequest('PATCH', uri);
      request.headers.addAll({"Authorization": bearerToken});

      request.fields['planName'] = planName;
      request.fields['price'] = price;
      request.fields['minPrice'] = minPrice;
      request.fields['description'] = description;
      request.fields['variationIds'] = jsonEncode(variationIds);
      request.fields['messId'] = messId;

      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('planImages', imageFile.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        await refreshPlans();
        _showSnackBar(
          title: "Updated",
          message: "Plan updated successfully",
          color: Colors.green,
        );
      } else {
        _showSnackBar(
          title: "Error ${response.statusCode}",
          message: "Failed to update plan: $responseBody",
          color: Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(title: "Error",message:  e.toString(),color:  Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      final messId = authController.selectedMessId.value;
      final url = Uri.parse("$baseUrl/plans/$id");

      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: jsonEncode({"messId": messId}),
      );

      if (response.statusCode == 200) {
        plans.removeWhere((p) => p.id == id);
         await dashboardController.fetchDashboardStats(); 
        _showSnackBar(title: "Deleted", message: "Plan deleted successfully",color:  Colors.green);
      } else {
        _showSnackBar(
         title:  "Error ${response.statusCode}",
          message: "Failed to delete plan",
         color:  Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(title: "Error",message:  e.toString(),color:  Colors.red);
    }
  }

  Future<void> refreshPlans() async {
    currentPage.value = 1;
    await fetchPlans(page: 1);
  }

  void _showSnackBar({
    required String title,
    required String message,
    required Color color,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withOpacity(0.1),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }
}
