// lib/Screens/MenuScreen/Models/MenuModel.dart

/// Single source of truth mapping each weekday to its lowercase JSON key,
/// matching the backend's CreateMenuDto / UpdateMenuDto day properties.
const List<String> kMenuWeekDays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

const Map<String, String> kMenuWeekDayLabels = {
  'monday': 'Monday',
  'tuesday': 'Tuesday',
  'wednesday': 'Wednesday',
  'thursday': 'Thursday',
  'friday': 'Friday',
  'saturday': 'Saturday',
  'sunday': 'Sunday',
};

/// One meal entry within a day of a Menu's schedule,
/// e.g. { variationId: <Lunch>, items: "Rice, Dal, Sabzi" }.
class MenuDayEntry {
  final String variationId;
  final String items;

  MenuDayEntry({required this.variationId, required this.items});

  factory MenuDayEntry.fromJson(Map<String, dynamic> json) {
    return MenuDayEntry(
      variationId: json['variationId'] ?? '',
      items: json['items'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'variationId': variationId,
    'items': items,
  };

  MenuDayEntry copyWith({String? variationId, String? items}) {
    return MenuDayEntry(
      variationId: variationId ?? this.variationId,
      items: items ?? this.items,
    );
  }
}

class MenuModel {
  final String id;
  final String messId;
  final String name;
  final bool isActive;

  /// Keyed by lowercase weekday (monday..sunday); only days with entries are present.
  final Map<String, List<MenuDayEntry>> schedule;

  MenuModel({
    required this.id,
    required this.messId,
    required this.name,
    required this.isActive,
    required this.schedule,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final schedule = <String, List<MenuDayEntry>>{};
    for (final day in kMenuWeekDays) {
      final raw = json[day];
      if (raw is List && raw.isNotEmpty) {
        schedule[day] = raw
            .map((e) => MenuDayEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    return MenuModel(
      id: json['id'] ?? '',
      messId: json['messId'] ?? '',
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? true,
      schedule: schedule,
    );
  }

  /// Total entries across every day — used for card previews/counters.
  int get totalEntries =>
      schedule.values.fold(0, (sum, entries) => sum + entries.length);
}
