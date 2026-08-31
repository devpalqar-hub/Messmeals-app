import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/ExpenseScreen/Models/ExpenseAnalyticsModel.dart';
import 'package:mess/Screens/ExpenseScreen/Models/ExpenseModel.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/main.dart';

/// Payment status filter for the expense list/summary tabs.
/// `null` means "All". Status is otherwise computed server-side from
/// amount vs paidAmount — the only value ever sent on create/update is
/// [pending], to log a placeholder entry with no amount yet.
enum ExpenseStatusFilter { paid, partiallyPaid, unpaid, pending }

extension on ExpenseStatusFilter {
  String get apiValue {
    switch (this) {
      case ExpenseStatusFilter.paid:
        return "PAID";
      case ExpenseStatusFilter.partiallyPaid:
        return "PARTIALLY_PAID";
      case ExpenseStatusFilter.unpaid:
        return "UNPAID";
      case ExpenseStatusFilter.pending:
        return "PENDING";
    }
  }
}

class ExpenseController extends GetxController {
  final HomeScreenController dashboardController =
      Get.find<HomeScreenController>();

  bool isLoading = false;
  bool isReady = false;
  bool isUploadingReceipt = false;
  List<ExpenseModel> expenses = [];

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;

  String errorMessage = '';
  String searchQuery = '';
  ExpenseStatusFilter? statusFilter;

  /// Embedded in the GET /expenses response: total/paid/unpaid/pending
  /// totals scoped to the current filters, independent of [statusFilter].
  ExpenseListSummary listSummary = ExpenseListSummary.fromJson(null);

  List<ExpenseModel> get filteredExpenses {
    if (searchQuery.isEmpty) return expenses;
    final query = searchQuery.toLowerCase();
    return expenses.where((expense) {
      return expense.title.toLowerCase().contains(query) ||
          expense.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    ensureLoaded();
  }

  Future<void> ensureLoaded() async {
    if (isReady) return;
    await fetchExpenses();
  }

  void setStatusFilter(ExpenseStatusFilter? filter) {
    if (statusFilter == filter) return;
    statusFilter = filter;
    fetchExpenses(page: 1);
  }

  Future<void> fetchExpenses({int? page, int? perPage}) async {
    _setLoading(true);
    final pageNumber = page ?? currentPage;
    final itemsPerPage = perPage ?? limit;
    final messId = dashboardController.selectedMessId;

    try {
      final url = Uri.parse(
        "$baseUrl/expenses?messId=$messId&page=$pageNumber&limit=$itemsPerPage"
        "${statusFilter != null ? '&status=${statusFilter!.apiValue}' : ''}",
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        final meta = data['meta'] ?? {};

        expenses = list.map((e) => ExpenseModel.fromJson(e)).toList();
        currentPage = meta['page'] ?? 1;
        totalPages = meta['totalPages'] ?? 1;
        listSummary = ExpenseListSummary.fromJson(
          data['summary'] is Map ? data['summary'] as Map<String, dynamic> : null,
        );
        errorMessage = '';
      } else {
        errorMessage = "Failed to load expenses";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
      isReady = true;
    }
  }

  Future<String?> uploadReceipt(File file) async {
    isUploadingReceipt = true;
    update();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/expenses/receipts/upload'),
      );
      request.headers['Authorization'] = bearerToken;
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final streamedResponse = await request.send();
      final body = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        final decoded = jsonDecode(body);
        final url =
            decoded is Map
                ? (decoded['url'] ??
                    decoded['receiptUrl'] ??
                    (decoded['data'] is Map ? decoded['data']['url'] : null))
                : null;

        if (url == null) {
          Fluttertoast.showToast(msg: "Receipt uploaded but URL missing");
        }
        return url?.toString();
      }

      Fluttertoast.showToast(msg: "Failed to upload receipt");
      return null;
    } catch (e) {
      debugPrint("UPLOAD RECEIPT ERROR: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
      return null;
    } finally {
      isUploadingReceipt = false;
      update();
    }
  }

  /// Creates or updates an expense. Status is never sent directly — it's
  /// always computed server-side from amount vs paidAmount — except
  /// [isPending] on create, which logs a placeholder with no amount yet.
  Future<bool> saveExpense({
    String? id,
    required String categoryId,
    required String title,
    double? amount,
    double? paidAmount,
    required String date,
    bool isPending = false,
    String description = '',
    String? receiptUrl,
    String? paymentMethod,
  }) async {
    try {
      _setLoading(true);

      final bool isEdit = id != null;
      final uri = Uri.parse(
        isEdit ? "$baseUrl/expenses/$id" : "$baseUrl/expenses",
      );

      final body = <String, dynamic>{
        "categoryId": categoryId,
        "title": title,
        "expenseDate": date,
        "description": description,
        if (amount != null) "amount": amount,
        if (paidAmount != null) "paidAmount": paidAmount,
        if (paymentMethod != null && paymentMethod.isNotEmpty)
          "paymentMethod": paymentMethod,
        if (receiptUrl != null) "receiptUrl": receiptUrl,
        if (!isEdit) "messId": dashboardController.selectedMessId,
        if (!isEdit && isPending) "status": "PENDING",
      };

      final response = await (isEdit
          ? http.patch(uri, headers: _headers, body: jsonEncode(body))
          : http.post(uri, headers: _headers, body: jsonEncode(body)));

      if (response.statusCode == 200 || response.statusCode == 201) {
        await refreshExpenses();
        Fluttertoast.showToast(
          msg:
              isEdit
                  ? "Expense updated successfully"
                  : "Expense added successfully",
        );
        return true;
      }

      Fluttertoast.showToast(msg: "Failed to save expense");
      return false;
    } catch (e) {
      debugPrint("SAVE EXPENSE ERROR : $e");
      Fluttertoast.showToast(msg: "Something went wrong");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Records a payment (cumulative total paid to date) against an expense.
  /// Safe to call repeatedly to log instalments; status is recalculated
  /// automatically from amount vs paidAmount.
  Future<bool> recordPayment({
    required String id,
    required double paidAmount,
    double? amount,
  }) async {
    try {
      _setLoading(true);

      final uri = Uri.parse("$baseUrl/expenses/$id/payment");
      final body = <String, dynamic>{
        "paidAmount": paidAmount,
        if (amount != null) "amount": amount,
      };

      final response = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await refreshExpenses();
        Fluttertoast.showToast(msg: "Payment recorded");
        return true;
      }

      Fluttertoast.showToast(msg: "Failed to record payment");
      return false;
    } catch (e) {
      debugPrint("RECORD PAYMENT ERROR : $e");
      Fluttertoast.showToast(msg: "Something went wrong");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      final url = Uri.parse("$baseUrl/expenses/$id");
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        await refreshExpenses();
        return true;
      }

      Fluttertoast.showToast(msg: "Failed to delete expense");
      return false;
    } catch (e) {
      debugPrint('DELETE EXPENSE ERROR: $e');
      return false;
    }
  }

  Future<void> refreshExpenses() async {
    currentPage = 1;
    await fetchExpenses(page: 1);
  }

  void updateSearch(String query) {
    searchQuery = query;
    update();
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
