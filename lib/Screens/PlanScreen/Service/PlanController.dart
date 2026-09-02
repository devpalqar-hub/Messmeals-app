import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    final messId = dashboardController.selectedMessId;

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
        print("Fetched data ${data} ");
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
    List<String>? menuIds,
    required bool isMonthlyPlan,
    required bool isDailyPlan,
    List<File>? imageFiles,
    List<String>? existingImage,
  }) async {
    try {
      _setLoading(true);

      final bool isEdit = id != null;

      /// =========================================
      /// STEP 1 : UPLOAD IMAGE
      /// =========================================

      // List<Map<String, dynamic>> uploadedImages = [];

      // if (imageFiles != null && imageFiles.isNotEmpty) {
      //   final uploadUri = Uri.parse("$baseUrl/plans/images/upload");

      //   final uploadRequest = http.MultipartRequest("POST", uploadUri);
      //   uploadRequest.headers.addAll({"Authorization": bearerToken});

      //   for (File file in imageFiles) {
      //     String filePath = file.path.toLowerCase();

      //     MediaType mediaType = MediaType("image", "jpeg");

      //     if (filePath.endsWith(".png")) {
      //       mediaType = MediaType("image", "png");
      //     } else if (filePath.endsWith(".webp")) {
      //       mediaType = MediaType("image", "webp");
      //     } else if (filePath.endsWith(".jpg") || filePath.endsWith(".jpeg")) {
      //       mediaType = MediaType("image", "jpeg");
      //     }

      //     uploadRequest.files.add(
      //       await http.MultipartFile.fromPath(
      //         "files",
      //         file.path,
      //         contentType: mediaType,
      //       ),
      //     );
      //   }

      //   final uploadResponse = await uploadRequest.send();
      //   final uploadBody = await uploadResponse.stream.bytesToString();

      //   if (uploadResponse.statusCode == 200 ||
      //       uploadResponse.statusCode == 201) {
      //     final decoded = jsonDecode(uploadBody);

      //     final List urls = decoded["urls"] ?? [];

      //     uploadedImages = urls.map((e) => {"url": e}).toList();
      //   } else {
      //     Fluttertoast.showToast(msg: "Image upload failed");
      //     return false;
      //   }
      // }

      // /// =========================================
      // /// EXISTING IMAGE FOR EDIT
      // /// =========================================

      // List<String> finalImages = [];

      // // old image
      // if (existingImage != null && existingImage.isNotEmpty) {
      //   finalImages.addAll(existingImage);
      // }

      // // new uploaded images
      // if (uploadedImages.isNotEmpty) {
      //   finalImages.addAll(uploadedImages.map((e) => e["url"].toString()));
      // }

      /// =========================================
      /// STEP 2 : SAVE PLAN
      /// =========================================

      final uri = Uri.parse(isEdit ? "$baseUrl/plans/$id" : "$baseUrl/plans");

      final body = {
        "planName": planName,

        "price": double.tryParse(price) ?? 0,

        "minPrice": double.tryParse(minPrice) ?? 0,

        "description": description,

        "messId": dashboardController.selectedMessId,

        "variationIds": variationIds,

        if (menuIds != null) "menuIds": menuIds,

        "isMonthlyPlan": isMonthlyPlan,

        "isDailyPlan": isDailyPlan,

        //  "images": uploadedImages,
      };

      /// attach images only if available
      // if (isEdit && finalImages.isNotEmpty) {
      //   body.remove("images"); // remove old key
      //   body["planImages"] = finalImages;
      // }

      final response =
          await (isEdit
              ? http.patch(
                uri,
                headers: {
                  "Authorization": bearerToken,
                  "Content-Type": "application/json",
                },
                body: jsonEncode(body),
              )
              : http.post(
                uri,
                headers: {
                  "Authorization": bearerToken,
                  "Content-Type": "application/json",
                },
                body: jsonEncode(body),
              ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        await refreshPlans();

        if (!isEdit) {
          await dashboardController.fetchDashboardStats();
        }

        Fluttertoast.showToast(
          msg:
              isEdit
                  ? "Plan updated successfully"
                  : "Plan created successfully",
        );

        return true;
      }

      Fluttertoast.showToast(msg: "Failed to save plan");

      return false;
    } catch (e) {
      debugPrint("SAVE PLAN ERROR : $e");

      Fluttertoast.showToast(msg: "Something went wrong");

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
        body: jsonEncode({"messId": dashboardController.selectedMessId}),
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
