/// A single mess image, as returned by GET /mess/{id}.
///
/// The API returns `images` as a flat list — items may just be plain URL
/// strings, or objects like `{"url": "...", "type": "cover"}`. This model
/// handles both shapes defensively.
class MessImageModel {
  final String url;
  final String? type;

  MessImageModel({required this.url, this.type});

  factory MessImageModel.fromJson(dynamic json) {
    if (json is String) {
      return MessImageModel(url: json);
    }

    if (json is Map) {
      final url = (json['url'] ?? json['image'] ?? '').toString();
      final type = (json['type'] ?? json['category'])?.toString();
      return MessImageModel(url: url, type: type);
    }

    return MessImageModel(url: '');
  }

  bool get isCover => (type ?? '').toLowerCase().contains('cover');
}

class MessModel {
  String? id;
  String? name;
  String? description;
  String? address;
  String? phone;
  String? email;
  bool? isActive;
  bool? isPremium;
  bool? isVerified;
  String? location;
  String? districtId;
  Map<String, String> openingHours;
  List<String> foodTypes;
  List<String> tags;
  List<String> features;
  List<MessImageModel> images;

  MessModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.isActive,
    this.isPremium,
    this.isVerified,
    this.location,
    this.districtId,
    Map<String, String>? openingHours,
    List<String>? foodTypes,
    List<String>? tags,
    List<String>? features,
    List<MessImageModel>? images,
  }) : openingHours = openingHours ?? {},
       foodTypes = foodTypes ?? [],
       tags = tags ?? [],
       features = features ?? [],
       images = images ?? [];

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      isActive: json['is_active'] is bool ? json['is_active'] : null,
      isPremium: json['isPremium'] is bool ? json['isPremium'] : null,
      isVerified: json['is_verified'] is bool ? json['is_verified'] : null,
      location: json['location']?.toString(),
      districtId: json['districtId']?.toString(),
      openingHours:
          json['openingHours'] is Map
              ? Map<String, String>.from(
                (json['openingHours'] as Map).map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              )
              : {},
      foodTypes:
          json['foodTypes'] is List
              ? List<String>.from(
                (json['foodTypes'] as List).map((e) => e.toString()),
              )
              : [],
      tags:
          json['tags'] is List
              ? List<String>.from(
                (json['tags'] as List).map((e) => e.toString()),
              )
              : [],
      features:
          json['features'] is List
              ? List<String>.from(
                (json['features'] as List).map((e) => e.toString()),
              )
              : [],
      images:
          json['images'] is List
              ? (json['images'] as List)
                  .map((e) => MessImageModel.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'is_active': isActive,
      'isPremium': isPremium,
      'is_verified': isVerified,
      'location': location,
      'districtId': districtId,
      'openingHours': openingHours,
      'foodTypes': foodTypes,
      'tags': tags,
      'features': features,
    };
  }
}
