import 'dart:convert';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/PlanScreen/Models/VariationModel.dart';
import 'package:mess/main.dart';

class VariationController extends GetxController {
  // Standard data types instead of .obs
  List<VariationModel> variations = [];
  bool isLoading = false;
  String errorMessage = '';
  bool isReady = false;

  /// Call this to ensure data is loaded without double-fetching
  Future<void> ensureLoaded() async {
    if (isReady && variations.isNotEmpty) return;
    await fetchVariations();
  }

 Future<void> fetchVariations() async {
    try {
      isLoading = true;
      errorMessage = '';
      update();

      final url = Uri.parse('$baseUrl/variation');
      final headers = {
        'Content-Type': 'application/json',
      };

      // --- LOG REQUEST ---
      print("🌐 [GET] Request: $url");
      print("📩 Headers: $headers");

      final response = await http.get(url, headers: headers);

      // --- LOG RESPONSE ---
      print("✅ [${response.statusCode}] Response from: $url");
      print("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        variations = jsonList.map((item) => VariationModel.fromJson(item)).toList();
        isReady = true;
      } else {
        errorMessage = 'Failed to load variations (Status: ${response.statusCode})';
        print("⚠️ Error Message: $errorMessage");
      }
    } catch (e) {
      errorMessage = e.toString();
      print("❌ Exception in fetchVariations: $e");
    } finally {
      isLoading = false;
      update();
      print("🔄 fetchVariations: UI Updated, isLoading = false");
    }
  }
  Future<void> refreshVariations() async {
    await fetchVariations();
  }
}