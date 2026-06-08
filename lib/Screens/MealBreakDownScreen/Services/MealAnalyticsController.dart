import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/MealBreakDownScreen/Model/MealAnalyticsModel.dart';
import 'package:mess/main.dart';

class MealsAnalyticsController extends GetxController {
  DateTime selectedDate = DateTime.now(); // Defaults to today

  bool isLoading = true;
  AnalyticsModel? analyticsData;

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10938F), // Matching your Teal theme
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
      fetchAnalytics();
    }
  }

  Future<void> fetchAnalytics() async {
    isLoading = true;
    update();

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    HomeScreenController hctrl = Get.find();
    // Construct URL with same fromDate and toDate
    String url =
        '${baseUrl}/deliveries/analytics/variation-counts'
        '?messId=${hctrl.selectedMessId}'
        '&fromDate=$formattedDate'
        '&toDate=$formattedDate';

    try {
      final response = await get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$bearerToken',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        analyticsData = AnalyticsModel.fromJson(data);
      } else {
        // Handle Error
        print("Error fetching data");
      }
    } catch (e) {
      print(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }
}
