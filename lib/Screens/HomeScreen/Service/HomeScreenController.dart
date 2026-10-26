import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/DeliveriesScreen/Model/DeliveryModel.dart';
import 'package:mess/Screens/DeliveriesScreen/DeliveriesScreen.dart'
    show DeliveriesController;
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/ExpenseScreen/Service/ExpenseController.dart';
import 'package:mess/Screens/MenuScreen/Service/MenuController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/HomeScreen/Model/DashboardModel.dart';
import 'package:mess/Screens/HomeScreen/Model/MessModel.dart';
import 'package:mess/Screens/HomeScreen/Model/VariationCountModel.dart';
import 'package:mess/Screens/LoginScreen/Model/UserModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DashboardDateFilter { thisWeek, thisMonth, lastMonth, custom }

class HomeScreenController extends GetxController {
  // Standard variables instead of Rx
  DashboardModel? dashboardData;
  VariationCountModel? variationData;

  UserModel? user;
  bool isLoading = false;
  bool isVariationLoading = false;
  bool profileLoadFailed = false;

  // Defaults to "This Month" (1st of this month → today)
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? selectedEndDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DashboardDateFilter selectedDateFilter = DashboardDateFilter.thisMonth;
  String authToken = "";
  final AuthController authController = Get.put(AuthController());
  List<MessModel> messes = [];
  String? selectedMessId;
  @override
  void onInit() {
    super.onInit();

    // Initial fetch if messId exists

    // fetchMyMesses();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    profileLoadFailed = false;
    update();

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/users/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': '$bearerToken',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        user = UserModel.fromJson(json.decode(response.body));
        fetchMyMesses();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleLogout();
      } else {
        debugPrint(
          'FETCH PROFILE FAILED: ${response.statusCode} ${response.body}',
        );
        profileLoadFailed = true;
        update();
      }
    } catch (e) {
      debugPrint('FETCH PROFILE ERROR: $e');
      profileLoadFailed = true;
      update();
    }
  }

  Future<void> fetchMyMesses() async {
    try {
      authToken = await _getToken() ?? "";
      messes.clear();
      final response = await http.get(
        Uri.parse('$baseUrl/customer/owners/messes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('MY MESSES: ${response.statusCode}');
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data = decoded is List ? decoded : (decoded['data'] ?? []);

        final loadedMesses =
            data.map((item) => MessModel.fromJson(item)).toList();

        messes = loadedMesses;

        // Keep currently selected mess if it still exists
        if (selectedMessId != null &&
            messes.any((mess) => mess.id == selectedMessId)) {
          // Keep current selection
        } else if (messes.isNotEmpty) {
          selectedMessId = messes.first.id;
        } else {
          selectedMessId = null;
        }

        update();

        if (selectedMessId != null) {
          refreshAllData();
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleLogout();
      } else {
        AppToast.error("Failed to fetch messes");
      }
    } catch (e) {
      debugPrint('FETCH MESSES ERROR: $e');
      AppToast.error(e.toString());
    }
  }

  // Helper to refresh everything and update UI
  void refreshAllData() {
    fetchDashboardStats();
    // Variation counts are a single-day lookup — use the last date of the
    // selected range so they reflect the most recent day in scope.
    fetchVariationCount(selectedEndDate ?? selectedDate);
  }

  bool addMessLoading = false;
  void addNewMess({
    required String name,
    required String zipCode,
    String? phone,
    String? address,
  }) async {
    addMessLoading = true;
    update();
    final response = await http.post(
      Uri.parse('$baseUrl/mess/admin/my-mess'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$bearerToken',
      },
      body: jsonEncode({
        "name": name,
        "address": address,
        "phone": phone ?? user!.phone,
        "email": user!.email,
        "zipcode": zipCode,
        // BUG #3194 — without this, a newly created mess wasn't marked
        // active, so it never showed up on the customer-facing site.
        "is_active": true,
      }),
    );

    addMessLoading = false;
    update();
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      var body = json.decode(response.body);
      Get.back();
      messes = [];

      await fetchMyMesses();
      selectedMessId = body["data"]["id"];
      fetchDashboardStats();
      _refetchMessScopedControllers();
    }
    update();
    print(response.body);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Fetches the full details of a single mess (GET /mess/{id}) — the mess
  /// list endpoint only returns a handful of fields, so this is used to
  /// prefill the edit screen with everything, including images.
  Future<MessModel?> fetchMessDetails(String messId) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/mess/$messId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('MESS DETAILS: ${response.statusCode}');
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final data =
            (decoded is Map && decoded['data'] is Map)
                ? decoded['data']
                : decoded;

        return MessModel.fromJson(Map<String, dynamic>.from(data));
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleLogout();
        return null;
      }

      AppToast.error("Failed to load mess details");
      return null;
    } catch (e) {
      debugPrint('MESS DETAILS ERROR: $e');
      AppToast.error(e.toString());
      return null;
    }
  }

  /// Uploads local image files (picked from camera/gallery) to S3 and
  /// returns the hosted URLs so they can be passed to createMess /
  /// updateMess / addCoverImage / addGalleryImages.
  Future<List<String>> uploadImages(List<File> files) async {
    if (files.isEmpty) return [];

    try {
      final token = await _getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.messmeals.com/s3/upload-multiple'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      for (final file in files) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      final streamedResponse = await request.send();
      final body = await streamedResponse.stream.bytesToString();

      debugPrint('UPLOAD IMAGES: ${streamedResponse.statusCode}');
      debugPrint(body);

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        final decoded = jsonDecode(body);

        final List rawUrls =
            decoded is List
                ? decoded
                : (decoded['urls'] ?? decoded['data'] ?? []);

        return rawUrls
            .map((e) => e is String ? e : (e['url']?.toString() ?? ''))
            .where((url) => url.isNotEmpty)
            .toList();
      }

      AppToast.error("Failed to upload images");
      return [];
    } catch (e) {
      debugPrint('UPLOAD IMAGES ERROR: $e');
      AppToast.error(e.toString());
      return [];
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading = true;
      update(); // Notify UI to show loader

      final token = await _getToken();
      final messId = selectedMessId;

      final date1 = _formatDate(selectedDate);
      final date2 = selectedEndDate != null ? _formatDate(selectedEndDate!) : null;

      final url = Uri.parse('$baseUrl/auth/stats').replace(
        queryParameters: {
          if (messId != null) 'messId': messId,
          'date1': date1,
          if (date2 != null) 'date2': date2,
        },
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        dashboardData = DashboardModel.fromJson(data);
        update();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        _handleLogout();
      } else {
        AppToast.error("Failed to fetch dashboard stats");
      }
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      isLoading = false;
      update(); // Notify UI that loading is finished
    }
  }

  Future<void> fetchVariationCount(DateTime date) async {
    try {
      isVariationLoading = true;
      final token = await _getToken();
      final messId = selectedMessId;

      if (messId == null || messId.isEmpty) return;

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final url = Uri.parse(
        '$baseUrl/customer/variation/count?date=$formattedDate&messId=$messId',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        variationData = VariationCountModel.fromJson(data);
      } else {
        AppToast.error("Failed to fetch variation count");
      }
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      isVariationLoading = false;
      update();
    }
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  /// Applies a preset ("This Week" / "This Month" / "Last Month") or a custom
  /// range to the dashboard, then refetches revenue stats + variation count.
  void applyDateFilter(
    DashboardDateFilter filter, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    selectedDateFilter = filter;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case DashboardDateFilter.thisWeek:
        selectedDate = today.subtract(Duration(days: today.weekday - 1));
        selectedEndDate = today;
        break;
      case DashboardDateFilter.thisMonth:
        selectedDate = DateTime(today.year, today.month, 1);
        selectedEndDate = today;
        break;
      case DashboardDateFilter.lastMonth:
        selectedDate = DateTime(today.year, today.month - 1, 1);
        selectedEndDate = DateTime(today.year, today.month, 0); // last day of previous month
        break;
      case DashboardDateFilter.custom:
        selectedDate = customStart ?? selectedDate;
        selectedEndDate =
            (customEnd != null && customEnd != customStart) ? customEnd : null;
        break;
    }

    fetchDashboardStats();
    // Variation counts are a single-day lookup — use the last date of the
    // selected range so they reflect the most recent day in scope.
    fetchVariationCount(selectedEndDate ?? selectedDate);
  }

  Future<void> _handleLogout() async {
    await authController.logout(showMessage: false);
  }

  /// Create a new mess
  Future<MessModel?> createMess({
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    required bool isActive,
    required bool isPremium,
    required bool isVerified,
    required Map<String, String> openingHours,
    required String location,
    String? districtId,
    required List<String> foodTypes,
    required List<String> messAdminIds,
    required List<String> tags,
    required List<String> features,
    List<String> images = const [],
    String? icon,
  }) async {
    try {
      isLoading = true;
      update();

      final token = await _getToken();

      final body = {
        "name": name,
        "description": description,
        "address": address,
        "phone": phone,
        "email": email,
        "is_active": isActive,
        "isPremium": isPremium,
        "is_verified": isVerified,
        "openingHours": openingHours,
        "messAdminIds": messAdminIds,
        "location": location,
        "foodTypes": foodTypes,
        "tags": tags,
        "features": features,
        "images": images.map((url) => {"url": url}).toList(),
      };

      if (districtId != null && districtId.isNotEmpty) {
        body["districtId"] = districtId;
      }

      if (icon != null && icon.isNotEmpty) {
        body["icon"] = icon;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/mess/admin/my-mess'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('CREATE MESS: ${response.statusCode}');
      debugPrint(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        final data = decoded['data'] ?? decoded;

        final newMess = MessModel.fromJson(data);

        // Add new mess to local list
        messes.add(newMess);

        // Select newly created mess
        selectedMessId = newMess.id;

        update();

        return newMess;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleLogout();
        return null;
      }

      AppToast.error("Failed to create mess (${response.statusCode})");

      return null;
    } catch (e) {
      debugPrint('CREATE MESS ERROR: $e');
      AppToast.error(e.toString());
      return null;
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Update an existing mess
  Future<bool> updateMess({
    required String messId,
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    required bool isActive,
    required bool isPremium,
    required bool isVerified,
    required Map<String, String> openingHours,
    required String location,
    String? districtId,
    required List<String> foodTypes,
    required List<String> tags,
    required List<String> features,
    List<String> images = const [],
    String? icon,
  }) async {
    try {
      isLoading = true;
      update();

      final token = await _getToken();

      final body = {
        "name": name,
        "description": description,
        "address": address,
        "phone": phone,
        "is_active": isActive,
        "isPremium": isPremium,
        "is_verified": isVerified,
        "openingHours": openingHours,
        "location": location,
        "foodTypes": foodTypes,
        "tags": tags,
        "features": features,
        "images": images.map((url) => {"url": url}).toList(),
      };

      // Sent only when present — an empty string fails the backend's email
      // format validator, and a freshly signed-up mess may not have one yet.
      if (email.trim().isNotEmpty) {
        body["email"] = email;
      }

      if (icon != null && icon.isNotEmpty) {
        body["icon"] = icon;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/mess/$messId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('UPDATE MESS: ${response.statusCode}');
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'] ?? decoded;

        final updatedMess = MessModel.fromJson(data);

        // Replace existing mess in local list
        final index = messes.indexWhere((mess) => mess.id == messId);

        if (index != -1) {
          messes[index] = updatedMess;
        }

        selectedMessId = messId;

        update();

        return true;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleLogout();
        return false;
      }

      String detail = '';
      try {
        final decoded = jsonDecode(response.body);
        final msg = decoded['message'];
        detail = msg is List ? msg.join(', ') : (msg?.toString() ?? '');
      } catch (_) {}
      AppToast.error(
        detail.isNotEmpty
            ? "Failed to update mess: $detail"
            : "Failed to update mess (${response.statusCode})",
      );

      return false;
    } catch (e) {
      debugPrint('UPDATE MESS ERROR: $e');
      AppToast.error(e.toString());
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  /// DELETE /mess/{id} — used for "Delete Account", since this app's only
  /// account-deletion endpoint is deleting the owner's mess.
  Future<bool> deleteMess(String messId) async {
    try {
      final token = await _getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/mess/$messId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('DELETE MESS: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleLogout();
        return false;
      }

      String detail = '';
      try {
        final decoded = jsonDecode(response.body);
        final msg = decoded['message'];
        detail = msg is List ? msg.join(', ') : (msg?.toString() ?? '');
      } catch (_) {}
      AppToast.error(
        detail.isNotEmpty
            ? "Failed to delete account: $detail"
            : "Failed to delete account (${response.statusCode})",
      );
      return false;
    } catch (e) {
      debugPrint('DELETE MESS ERROR: $e');
      AppToast.error(e.toString());
      return false;
    }
  }

  Future<bool> addGalleryImages({
    required String messId,
    required List<String> imageUrls,
  }) async {
    if (imageUrls.isEmpty) return true;

    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/mess/$messId/gallery/images'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"images": imageUrls}),
      );

      debugPrint('GALLERY IMAGES: ${response.statusCode}');
      debugPrint(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      AppToast.error("Failed to add gallery images");

      return false;
    } catch (e) {
      debugPrint('GALLERY IMAGE ERROR: $e');
      AppToast.error(e.toString());
      return false;
    }
  }

  Future<bool> deleteGalleryImage({
    required String messId,
    required String imageId,
  }) async {
    try {
      final token = await _getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/mess/$messId/gallery/images/$imageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('DELETE GALLERY IMAGE: ${response.statusCode}');
      debugPrint(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      AppToast.error("Failed to remove image");

      return false;
    } catch (e) {
      debugPrint('DELETE GALLERY IMAGE ERROR: $e');
      AppToast.error(e.toString());
      return false;
    }
  }

  Future<bool> addCoverImage({
    required String messId,
    required String imageUrl,
  }) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/mess/$messId/cover/image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "images": [imageUrl],
        }),
      );

      debugPrint('COVER IMAGE: ${response.statusCode}');
      debugPrint(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      AppToast.error("Failed to add cover image");

      return false;
    } catch (e) {
      debugPrint('COVER IMAGE ERROR: $e');
      AppToast.error(e.toString());
      return false;
    }
  }

  void selectMess(String messId) {
    if (selectedMessId == messId) return;

    selectedMessId = messId;

    dashboardData = null;
    variationData = null;

    update();

    refreshAllData();
    _refetchMessScopedControllers();
  }

  /// Plans/Customers/Partners/Menu/Expenses/Deliveries each cache their own
  /// list in a GetX singleton that only fetches once and keeps it — without
  /// this, switching mess left every feature screen still showing whichever
  /// mess it had last loaded instead of the one just selected.
  void _refetchMessScopedControllers() {
    if (Get.isRegistered<PlanController>()) {
      Get.find<PlanController>().refreshPlans();
    }
    if (Get.isRegistered<CustomerController>()) {
      Get.find<CustomerController>().refreshCustomers();
    }
    if (Get.isRegistered<PartnerController>()) {
      Get.find<PartnerController>().fetchPartners();
    }
    if (Get.isRegistered<MessMenuController>()) {
      Get.find<MessMenuController>().refreshMenus();
    }
    if (Get.isRegistered<ExpenseController>()) {
      Get.find<ExpenseController>().refreshExpenses();
    }
    if (Get.isRegistered<DeliveriesController>()) {
      Get.find<DeliveriesController>().fetchDeliveries();
    }
  }
}
