// lib/models/plan_model.dart

/// The plan's own weekly schedule. EVERYDAY = no day restriction, CUSTOM =
/// restricted to [PlanModel.availableDays]. Matches the backend's
/// `scheduleType` enum on CreatePlanDto/UpdatePlanDto exactly.
const List<String> kPlanWeekDays = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

const Map<String, String> kPlanWeekDayLabels = {
  'MONDAY': 'Mon',
  'TUESDAY': 'Tue',
  'WEDNESDAY': 'Wed',
  'THURSDAY': 'Thu',
  'FRIDAY': 'Fri',
  'SATURDAY': 'Sat',
  'SUNDAY': 'Sun',
};

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
  final String scheduleType;
  final List<String> availableDays;

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
    required this.scheduleType,
    required this.availableDays,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      price: json['price'] ?? '',
      minPrice: json['minPrice'] ?? '',
      description: json['description'] ?? '',
      isMonthlyPlan: json["isMonthlyPlan"],
      scheduleType: (json['scheduleType'] ?? 'EVERYDAY').toString(),
      availableDays:
          (json['availableDays'] as List<dynamic>?)
              ?.map((d) => d.toString())
              .toList() ??
          [],
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
