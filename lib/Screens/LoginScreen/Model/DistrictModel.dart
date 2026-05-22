class DistrictModel {
  final String id;
  final String name;
  final String image;
  final bool isPopular;

  DistrictModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isPopular,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isPopular: json['isPopular'] ?? false,
    );
  }
}