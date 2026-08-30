// lib/models/plan_model.dart
class PlanModel {
  final String id;
  final String planName;
  final String price;
  final String minPrice;
  final String description;
  final List<PlanImage> images;
  final List<Variation> variations;
  final List<MenuSummary> menus;
  final bool isMonthlyPlan;

  PlanModel({
    required this.id,
    required this.planName,
    required this.price,
    required this.minPrice,
    required this.description,
    required this.images,
    required this.variations,
    required this.menus,
    required this.isMonthlyPlan,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      price: json['price'] ?? '',
      minPrice: json['minPrice'] ?? '',
      description: json['description'] ?? '',
      isMonthlyPlan: json["isMonthlyPlan"],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => PlanImage.fromJson(img))
              .toList() ??
          [],
      variations:
          (json['Variation'] as List<dynamic>?)
              ?.map((v) => Variation.fromJson(v))
              .toList() ??
          [],
      menus:
          (json['menus'] as List<dynamic>?)
              ?.map((m) => MenuSummary.fromJson(m))
              .toList() ??
          [],
    );
  }
}

/// Lightweight menu reference as returned inline on a Plan (id + name only).
class MenuSummary {
  final String id;
  final String name;

  MenuSummary({required this.id, required this.name});

  factory MenuSummary.fromJson(Map<String, dynamic> json) {
    return MenuSummary(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class PlanImage {
  final String id;
  final String url;
  final String altText;

  PlanImage({required this.id, required this.url, required this.altText});

  factory PlanImage.fromJson(Map<String, dynamic> json) {
    return PlanImage(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      altText: json['altText'] ?? '',
    );
  }
}

class Variation {
  final String id;
  final String title;
  final String description;

  Variation({required this.id, required this.title, required this.description});

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
