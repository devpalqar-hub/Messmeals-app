import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/ExpenseCategoryScreen/Models/ExpenseCategoryModel.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/main.dart';

class ExpenseCategoryController extends GetxController {
  final HomeScreenController dashboardController =
      Get.find<HomeScreenController>();

  bool isLoading = false;
  bool isReady = false;
  List<ExpenseCategoryModel> categories = [];
  String errorMessage = '';

  @override
  void onInit() {
    super.onInit();
    ensureLoaded();
  }

  Future<void> ensureLoaded() async {
    if (isReady) return;
    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    final messId = dashboardController.selectedMessId;

    try {
      final url = Uri.parse("$baseUrl/expense-categories?messId=$messId");

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded is List ? decoded : (decoded['data'] ?? []);

        categories = list.map((e) => ExpenseCategoryModel.fromJson(e)).toList();
        errorMessage = '';
      } else {
        errorMessage = "Failed to load categories";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
      isReady = true;
    }
  }

  Future<bool> saveCategory({
    String? id,
    required String name,
    String description = '',
  }) async {
    try {
      _setLoading(true);

      final bool isEdit = id != null;
      final uri = Uri.parse(
        isEdit ? "$baseUrl/expense-categories/$id" : "$baseUrl/expense-categories",
      );

      final body = <String, dynamic>{
        "name": name,
        "description": description,
        if (!isEdit) "messId": dashboardController.selectedMessId,
      };

      final response = await (isEdit
          ? http.patch(uri, headers: _headers, body: jsonEncode(body))
          : http.post(uri, headers: _headers, body: jsonEncode(body)));

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCategories();
        Fluttertoast.showToast(
          msg: isEdit ? "Category updated successfully" : "Category created successfully",
        );
        return true;
      }

      Fluttertoast.showToast(msg: "Failed to save category");
      return false;
    } catch (e) {
      debugPrint("SAVE CATEGORY ERROR : $e");
      Fluttertoast.showToast(msg: "Something went wrong");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final url = Uri.parse("$baseUrl/expense-categories/$id");
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        categories.removeWhere((c) => c.id == id);
        update();
        return true;
      }

      Fluttertoast.showToast(msg: "Failed to delete category");
      return false;
    } catch (e) {
      debugPrint('DELETE CATEGORY ERROR: $e');
      return false;
    }
  }

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization": bearerToken,
      };

  void _setLoading(bool value) {
    isLoading = value;
    update();
  }
}
