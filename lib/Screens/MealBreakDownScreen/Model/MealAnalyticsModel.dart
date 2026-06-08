import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// --- MODELS ---
class AnalyticsModel {
  final int totalDeliveries;
  final int totalVariationDeliveries;
  final List<VariationCount> byVariation;
  final List<PlanCount> byPlan;

  AnalyticsModel({
    required this.totalDeliveries,
    required this.totalVariationDeliveries,
    required this.byVariation,
    required this.byPlan,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalDeliveries: json['summary']['totalDeliveries'] ?? 0,
      totalVariationDeliveries:
          json['summary']['totalVariationDeliveries'] ?? 0,
      byVariation:
          (json['byVariation'] as List)
              .map((v) => VariationCount.fromJson(v))
              .where((v) => v.totalCount > 0) // Only keep if has count
              .toList(),
      byPlan:
          (json['byPlan'] as List).map((p) => PlanCount.fromJson(p)).toList(),
    );
  }
}

class VariationCount {
  final String title;
  final int totalCount;

  VariationCount({required this.title, required this.totalCount});

  factory VariationCount.fromJson(Map<String, dynamic> json) {
    return VariationCount(
      title: json['variationTitle'] ?? '',
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

class PlanCount {
  final String planName;
  final int totalDeliveries;
  final List<VariationCount> variations;

  PlanCount({
    required this.planName,
    required this.totalDeliveries,
    required this.variations,
  });

  factory PlanCount.fromJson(Map<String, dynamic> json) {
    return PlanCount(
      planName: json['planName'] ?? '',
      totalDeliveries: json['totalDeliveries'] ?? 0,
      variations:
          (json['variations'] as List)
              .map(
                (v) => VariationCount(
                  title: v['variationTitle'] ?? '',
                  totalCount: v['count'] ?? 0,
                ),
              )
              .where((v) => v.totalCount > 0) // Only keep if has count
              .toList(),
    );
  }
}

// --- CONTROLLER ---
class MealsAnalyticsController extends GetxController {
  final String messId = "56f0bd9b-b1c3-4998-b058-766157791782";
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

    // Construct URL with same fromDate and toDate
    String url =
        'https://staging-api.messmeals.com/deliveries/analytics/variation-counts'
        '?messId=$messId'
        '&fromDate=$formattedDate'
        '&toDate=$formattedDate';

    try {
      // Replace with your actual API call / headers
      final response = await http.get(Uri.parse(url));

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
