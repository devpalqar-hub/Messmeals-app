// lib/Screens/VariationScreen/Service/VariationController.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/main.dart';


class PlanSummary {
  final String id;
  final String planName;
  final String price;
  final String minPrice;
  final String description;

  PlanSummary({
    required this.id,
    required this.planName,
    required this.price,
    required this.minPrice,
    required this.description,
  });

  factory PlanSummary.fromJson(Map<String, dynamic> json) {
    return PlanSummary(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      price: json['price'] ?? '',
      minPrice: json['minPrice'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class VariationModel {
  final String id;
  final String title;
  final String description;
  final List<PlanSummary> plans;

  VariationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.plans,
  });

  factory VariationModel.fromJson(Map<String, dynamic> json) {
    final planList = (json['plans'] as List?)
            ?.map((p) => PlanSummary.fromJson(p))
            .toList() ??
        [];
    return VariationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      plans: planList,
    );
  }
}

///