import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/MenuScreen/Models/MenuModel.dart';
import 'package:mess/main.dart';

class MessMenuController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeScreenController dashboardController =
      Get.find<HomeScreenController>();

  bool isLoading = false;
  bool isReady = false;
  List<MenuModel> menus = [];

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;

  String errorMessage = '';
  String searchQuery = '';

  List<MenuModel> get filteredMenus {
    if (searchQuery.isEmpty) return menus;
    final query = searchQuery.toLowerCase();
    return menus.where((menu) => menu.name.toLowerCase().contains(query)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    ensureLoaded();
  }

  Future<void> ensureLoaded() async {
    if (isReady) return;
    await fetchMenus();
  }

  Future<void> fetchMenus({int? page, int? perPage}) async {
    _setLoading(true);
    final pageNumber = page ?? currentPage;
    final itemsPerPage = perPage ?? limit;
    final messId = dashboardController.selectedMessId;

    try {
      final url = Uri.parse(
        "$baseUrl/menus?messId=$messId&page=$pageNumber&limit=$itemsPerPage",
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

        menus = list.map((e) => MenuModel.fromJson(e)).toList();
        currentPage = meta['page'] ?? 1;
        totalPages = meta['totalPages'] ?? 1;
        errorMessage = '';
      } else {
        errorMessage = "Failed to load menus";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
      isReady = true;
    }
  }

  /// [schedule] is keyed by lowercase weekday (monday..sunday) — only days with entries
  /// need to be included; pass an empty list for a day to clear it on update.
  Future<bool> saveMenu({
    String? id,
    required String name,
    required bool isActive,
    required Map<String, List<MenuDayEntry>> schedule,
  }) async {
    try {
      _setLoading(true);

      final bool isEdit = id != null;
      final uri = Uri.parse(isEdit ? "$baseUrl/menus/$id" : "$baseUrl/menus");

      final body = <String, dynamic>{
        "name": name,
        "isActive": isActive,
        if (!isEdit) "messId": dashboardController.selectedMessId,
        for (final entry in schedule.entries)
          entry.key: entry.value.map((e) => e.toJson()).toList(),
      };

      final response = await (isEdit
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
        await refreshMenus();

        Fluttertoast.showToast(
          msg: isEdit ? "Menu updated successfully" : "Menu created successfully",
        );

        return true;
      }

      String message = isEdit ? "Failed to update menu" : "Failed to create menu";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'] is List
              ? (decoded['message'] as List).join(', ')
              : decoded['message'].toString();
        }
      } catch (_) {}

      Fluttertoast.showToast(msg: message);
      return false;
    } catch (e) {
      debugPrint("SAVE MENU ERROR : $e");
      Fluttertoast.showToast(msg: "Something went wrong");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteMenu(String id) async {
    try {
      final url = Uri.parse("$baseUrl/menus/$id");
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
      );

      if (response.statusCode == 200) {
        menus.removeWhere((m) => m.id == id);
        update();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('DELETE MENU ERROR: $e');
      return false;
    }
  }

  // --- Helpers ---

  Future<void> refreshMenus() async {
    currentPage = 1;
    await fetchMenus(page: 1);
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
