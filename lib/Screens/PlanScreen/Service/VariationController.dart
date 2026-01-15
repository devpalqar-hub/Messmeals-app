import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/PlanScreen/Models/VariationModel.dart';
import 'package:mess/main.dart';

class VariationController extends GetxController  {
  RxList<VariationModel> variations = <VariationModel>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> fetchVariations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url = Uri.parse('$baseUrl/variation');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        variations.value =
            jsonList.map((item) => VariationModel.fromJson(item)).toList();
      } else {
        errorMessage.value =
            'Failed to load variations (Status: ${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshVariations() async {
    await fetchVariations();
  }
}