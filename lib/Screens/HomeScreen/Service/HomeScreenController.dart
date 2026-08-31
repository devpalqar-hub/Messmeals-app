import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/DeliveriesScreen/Model/DeliveryModel.dart';
import 'package:mess/Screens/HomeScreen/Model/DashboardModel.dart';
import 'package:mess/Screens/HomeScreen/Model/MessModel.dart';
import 'package:mess/Screens/HomeScreen/Model/VariationCountModel.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/LoginScreen/Model/UserModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenController extends GetxController {
  // Standard variables instead of Rx
  DashboardModel? dashboardData;
  VariationCountModel? variationData;

  UserModel? user;
  bool isLoading = false;
  bool isVariationLoading = false;
  bool profileLoadFailed = false;
  DateTime selectedDate = DateTime.now();
  String authToken = "";
  final AuthController authController = Get.put(AuthController());
  List<MessModel> messes =[ ];
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
    fetchVariationCount(selectedDate);
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

      final url = Uri.parse('$baseUrl/auth/stats?messId=$messId');

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

  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    fetchVariationCount(newDate);
    // update() is called inside fetchVariationCount finally block
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.deleteAll();
    Get.offAll(() => LoginScreen());
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
        "email": email,
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

      AppToast.error("Failed to update mess (${response.statusCode})");

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
  }
}
