import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/PartnerScreen/Model/PartnerModel.dart';
import 'package:mess/main.dart';

class PartnerController extends GetxController {
  var partners = <Partner>[].obs;
  var selectedPartner = Rxn<Partner>();
  var isLoading = false.obs;

  // ✅ Pagination controls
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalRecords = 0.obs;
  var limit = 10.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPartners();
  }

  /// ✅ Fetch all partners (paginated)
  Future<void> fetchPartners() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('$baseUrl/delivery-agent/?page=${currentPage.value}&limit=${limit.value}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        currentPage.value = data['currentPage'] ?? 1;
        totalPages.value = data['totalPages'] ?? 1;
        totalRecords.value = data['totalRecords'] ?? 0;

        final List<dynamic> list = data['data'] ?? [];
        partners.value = list.map((e) => Partner.fromJson(e)).toList();
      } else {
        Get.snackbar("Error", "Failed to fetch partners");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Fetch single partner details
  Future<void> fetchPartnerById(String id) async {
    try {
      isLoading(true);
      final url = Uri.parse('$baseUrl/delivery-agent/$id');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final partnerData = jsonData['data'] ?? jsonData;
        selectedPartner.value = Partner.fromJson(partnerData);
      } else {
        Get.snackbar("Error", "Failed to fetch partner details");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Add new delivery partner
  Future<void> addPartner({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      isLoading(true);
      final url = Uri.parse('$baseUrl/delivery-agent');
      final body = json.encode({
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201 ) {
        Get.snackbar("Success", "Delivery partner added successfully");
        await fetchPartners();
        Get.back(); // ✅ Auto-navigate back after success
      } else {
        final err = json.decode(response.body);
        Get.snackbar("Error", err['message'] ?? "Failed to add partner");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Update (Edit) delivery partner
  Future<void> updatePartner({
    required String id,
    String? name,
    String? phone,
    String? email,
    String? address,
    bool? isActive,
  }) async {
    try {
      isLoading(true);
      final url = Uri.parse('$baseUrl/delivery-agent/$id');
      final body = json.encode({
        if (name != null) "name": name,
        if (phone != null) "phone": phone,
        if (email != null) "email": email,
        if (address != null) "address": address,
        if (isActive != null) "isActive": isActive,
      });

      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Partner updated successfully");
        await fetchPartners();
        Get.back(); // ✅ Auto-navigate back after success
      } else {
        final err = json.decode(response.body);
        Get.snackbar("Error", err['message'] ?? "Failed to update partner");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Delete delivery partner
  Future<void> deletePartner(String id) async {
    try {
      isLoading(true);
      final url = Uri.parse('$baseUrl/delivery-agent/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200 ) {
        Get.snackbar("Success", "Partner deleted successfully");
        await fetchPartners();
      } else {
        final err = json.decode(response.body);
        Get.snackbar("Error", err['message'] ?? "Failed to delete partner");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Pagination helpers
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
}
