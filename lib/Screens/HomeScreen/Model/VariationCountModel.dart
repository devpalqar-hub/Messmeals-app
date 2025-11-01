class VariationCountModel {
  final String message;
  final int totalSubscriptions;
  final List<VariationData> data;

  VariationCountModel({
    required this.message,
    required this.totalSubscriptions,
    required this.data,
  });

  factory VariationCountModel.fromJson(Map<String, dynamic> json) {
    return VariationCountModel(
      message: json['message'] ?? '',
      totalSubscriptions: json['totalSubscriptions'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => VariationData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class VariationData {
  final String title;
  final int count;

  VariationData({
    required this.title,
    required this.count,
  });

  factory VariationData.fromJson(Map<String, dynamic> json) {
    return VariationData(
      title: json['title'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
