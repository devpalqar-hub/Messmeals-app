// lib/models/plan_model.dart
class PlanModel {
  final String id;
  final String planName;
  final String price;
  final String minPrice;
  final String description;
  final List<PlanImage> images;
  final List<Variation> variations;

  PlanModel({
    required this.id,
    required this.planName,
    required this.price,
    required this.minPrice,
    required this.description,
    required this.images,
    required this.variations,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      price: json['price'] ?? '',
      minPrice: json['minPrice'] ?? '',
      description: json['description'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => PlanImage.fromJson(img))
              .toList() ??
          [],
      variations: (json['Variation'] as List<dynamic>?)
              ?.map((v) => Variation.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class PlanImage {
  final String id;
  final String url;
  final String altText;

  PlanImage({
    required this.id,
    required this.url,
    required this.altText,
  });

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

  Variation({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
