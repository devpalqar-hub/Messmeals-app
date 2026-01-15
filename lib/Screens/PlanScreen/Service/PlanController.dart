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
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  bool isLoading = false;
  bool isReady = false;
  List<PlanModel> plans = [];
  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;
  String errorMessage = '';
  String searchQuery = '';

  List<PlanModel> get filteredPlans {
    if (searchQuery.isEmpty) return plans;

    final query = searchQuery.toLowerCase();
    return plans.where((plan) {
      return plan.planName.toLowerCase().contains(query) ||
          plan.description.toLowerCase().contains(query);
    }).toList();
  }


  Future<void> ensureLoaded() async {
    if (isReady) return;
    if (plans.isEmpty) {
      await fetchPlans(page: currentPage, perPage: limit);
    }
    isReady = true;
    update();
  }

  Future<void> fetchPlans({int? page, int? perPage}) async {
    isLoading = true;
    errorMessage = '';
    update();

    final pageNumber = page ?? currentPage;
    final itemsPerPage = perPage ?? limit;
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
        final List list = data['data'];
        final meta = data['meta'];

        plans = list.map((e) => PlanModel.fromJson(e)).toList();
        currentPage = meta['page'] ?? 1;
        totalPages = meta['totalPages'] ?? 1;
        limit = meta['limit'] ?? itemsPerPage;
      } else {
        errorMessage =
            "Failed to fetch plans (Status: ${response.statusCode})";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      isReady = true;
      update();
    }
  }

Future<bool> addPlan({
  required String planName,
  required String price,
  required String minPrice,
  required String description,
  required List<String> variationIds,
  File? imageFile,
}) async {
  try {
    isLoading = true;
    update();

    final messId = authController.selectedMessId.value;
    final uri = Uri.parse("$baseUrl/plans");

    final request = http.MultipartRequest('POST', uri)
      ..headers["Authorization"] = bearerToken
      ..fields.addAll({
        'planName': planName,
        'price': price,
        'minPrice': minPrice,
        'description': description,
        'variationIds': jsonEncode(variationIds),
        'messId': messId,
      });

    
    request.fields.forEach((key, value) {
      debugPrint("   $key : $value");
    });

    if (imageFile != null && await imageFile.exists()) {
      final file = await http.MultipartFile.fromPath(
        'planImages',
        imageFile.path,
      );
      request.files.add(file);

     
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    
    if (response.statusCode == 201) {
      await refreshPlans();
      await dashboardController.fetchDashboardStats();

      _showSnackBar(
        title: "Success",
        message: "Plan added successfully",
        color: Colors.green,
      );

      return true;
    } else {
      _showSnackBar(
        title: "Error",
        message: "Failed to add plan: ${response.statusCode}",
        color: Colors.red,
      );
      return false;
    }
  } catch (e, stack) {
    
    _showSnackBar(
      title: "Error",
      message: e.toString(),
      color: Colors.red,
    );
    return false;
  } finally {
    isLoading = false;
    update();
  }
}


Future<bool> editPlan({
  required String id,
  required String planName,
  required String price,
  required String minPrice,
  required String description,
  required List<String> variationIds,
  File? imageFile,
}) async {
  try {
    isLoading = true;
    update();

    final messId = authController.selectedMessId.value;
    final uri = Uri.parse("$baseUrl/plans/$id");
    final request = http.MultipartRequest('PATCH', uri)
      ..headers["Authorization"] = bearerToken
      ..fields.addAll({
        'planName': planName,
        'price': price,
        'minPrice': minPrice,
        'description': description,
        'variationIds': jsonEncode(variationIds),
        'messId': messId,
      });

    if (imageFile != null && await imageFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('planImages', imageFile.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      await refreshPlans();

      _showSnackBar(
        title: "Updated",
        message: "Plan updated successfully",
        color: Colors.green,
      );

      return true; 
    } else {
      _showSnackBar(
        title: "Error",
        message: "Failed to update plan: ${response.statusCode}",
        color: Colors.red,
      );
      return false;
    }
  } catch (e) {
    _showSnackBar(
      title: "Error",
      message: e.toString(),
      color: Colors.red,
    );
    return false;
  } finally {
    isLoading = false;
    update();
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

        update(); 
        _showSnackBar(
          title: "Deleted",
          message: "Plan deleted successfully",
          color: Colors.green,
        );
      } else {
        _showSnackBar(
          title: "Error",
          message: "Failed to delete plan",
          color: Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        title: "Error",
        message: e.toString(),
        color: Colors.red,
      );
    }
  }

  Future<void> refreshPlans() async {
    currentPage = 1;
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
