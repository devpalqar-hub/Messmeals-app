class ExpenseCategoryModel {
  final String id;
  final String messId;
  final String name;
  final String description;
  final bool isActive;

  ExpenseCategoryModel({
    required this.id,
    required this.messId,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: (json['id'] ?? '').toString(),
      messId: (json['messId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
    );
  }
}
