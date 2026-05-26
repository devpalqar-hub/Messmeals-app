import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/PlanScreen/Models/PlanModel.dart';
import 'package:mess/main.dart';

class PlanController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeScreenController dashboardController =
      Get.find<HomeScreenController>();

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

  @override
  void onInit() {
    super.onInit();
    ensureLoaded();
  }

  Future<void> ensureLoaded() async {
    if (isReady) return;
    await fetchPlans();
  }

  Future<void> fetchPlans({int? page, int? perPage}) async {
    _setLoading(true);
    final pageNumber = page ?? currentPage;
    final itemsPerPage = perPage ?? limit;
    final messId = authController.selectedMessId;

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
        final List list = data['data'] ?? [];
        final meta = data['meta'] ?? {};

        plans = list.map((e) => PlanModel.fromJson(e)).toList();
        currentPage = meta['page'] ?? 1;
        totalPages = meta['totalPages'] ?? 1;
        errorMessage = '';
      } else {
        errorMessage = "Failed to load plans";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
      isReady = true;
    }
  }

  Future<bool> savePlan({
    String? id,
    required String planName,
    required String price,
    required String minPrice,
    required String description,
    required List<String> variationIds,

    File? imageFile,
    String? existingImage,
  }) async {
    try {
      _setLoading(true);

      final bool isEdit = id != null;
      final uri = Uri.parse(isEdit ? "$baseUrl/plans/$id" : "$baseUrl/plans");

      final parsedPrice = double.tryParse(price) ?? 0;
      final parsedMinPrice = double.tryParse(minPrice) ?? 0;

      if (imageFile == null) {
        final body = {
          "planName": planName,
          "price": parsedPrice,
          "minPrice": parsedMinPrice,
          "description": description,
          "variationIds": variationIds,
          "planImages": existingImage != null ? [existingImage] : [],
          "messId": authController.selectedMessId,
        };

        final response =
            await (isEdit
                ? http.patch(
                  uri,
                  headers: {
                    "Authorization": bearerToken,
                    "Content-Type": "application/json",
                  },
                  body: body,
                )
                : http.post(
                  uri,
                  headers: {
                    "Authorization": bearerToken,
                    "Content-Type": "application/json",
                  },
                  body: body,
                ));

        if (response.statusCode == 200 || response.statusCode == 201) {
          await refreshPlans();
          if (!isEdit) await dashboardController.fetchDashboardStats();
          return true;
        }

        return false;
      }

      final request = http.MultipartRequest(isEdit ? 'PATCH' : 'POST', uri);

      request.headers["Authorization"] = bearerToken;

      request.fields.addAll({
        'planName': planName,
        'price': parsedPrice.toString(),
        'minPrice': parsedMinPrice.toString(),
        'description': description,
        'variationIds': jsonEncode(variationIds),
        'messId': authController.selectedMessId,
      });

      request.files.add(
        await http.MultipartFile.fromPath('planImages', imageFile.path),
      );

      final res = await request.send();
      final responseBody = await res.stream.bytesToString();

      if (res.statusCode == 200 || res.statusCode == 201) {
        await refreshPlans();
        if (!isEdit) await dashboardController.fetchDashboardStats();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePlan(String id) async {
    try {
      final url = Uri.parse("$baseUrl/plans/$id");
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: jsonEncode({"messId": authController.selectedMessId}),
      );

      if (response.statusCode == 200) {
        plans.removeWhere((p) => p.id == id);
        await dashboardController.fetchDashboardStats();
        update();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('DELETE ERROR: $e');
      return false;
    }
  }

  // --- Helpers ---

  Future<void> refreshPlans() async {
    currentPage = 1;
    await fetchPlans(page: 1);
  }

  void _setLoading(bool value) {
    isLoading = value;
    update();
  }

  void updateSearch(String query) {
    searchQuery = query;
    update();
  }
}
