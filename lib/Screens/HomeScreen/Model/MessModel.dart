/// A single mess image, as returned by GET /mess/{id}.
///
/// The API returns `images` as a flat list — items may just be plain URL
/// strings, or MessImages records like `{"id": "...", "url": "...", "isCover": true}`.
/// This model handles both shapes defensively.
class MessImageModel {
  final String? id;
  final String url;
  final String? type;
  final bool isCoverFlag;

  MessImageModel({this.id, required this.url, this.type, this.isCoverFlag = false});

  factory MessImageModel.fromJson(dynamic json) {
    if (json is String) {
      return MessImageModel(url: json);
    }

    if (json is Map) {
      final id = json['id']?.toString();
      final url = (json['url'] ?? json['image'] ?? '').toString();
      final type = (json['type'] ?? json['category'])?.toString();
      final isCoverFlag = json['isCover'] == true;
      return MessImageModel(id: id, url: url, type: type, isCoverFlag: isCoverFlag);
    }

    return MessImageModel(url: '');
  }

  bool get isCover =>
      isCoverFlag || (type ?? '').toLowerCase().contains('cover');
}

/// Extracts a flat `List<String>` from an API list whose items may either
/// already be plain strings, or relation objects like
/// `{"id": "...", "messId": "...", "foodType": "VEG"}` /
/// `{"id": "...", "messId": "...", "tag": "FIXED_MENU"}` — GET /mess and
/// GET /mess/{id} return the latter shape for `foodTypes` and `tags`.
List<String> _stringListFrom(List list, {required String key}) {
  return list
      .map((e) {
        if (e is String) return e;
        if (e is Map) return (e[key] ?? '').toString();
        return e.toString();
      })
      .where((s) => s.isNotEmpty)
      .toList();
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
  /// Optional icon/logo URL for the mess.
  String? icon;
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
    this.icon,
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
      icon: json['icon']?.toString(),
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
              ? _stringListFrom(json['foodTypes'] as List, key: 'foodType')
              : [],
      tags:
          json['tags'] is List
              ? _stringListFrom(json['tags'] as List, key: 'tag')
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
      'icon': icon,
      'openingHours': openingHours,
      'foodTypes': foodTypes,
      'tags': tags,
      'features': features,
    };
  }
}
