// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

/// One meal/variation attached to a delivery, e.g. "Lunch" x1.
class PartnerDeliveryItem {
  final String label;
  final int count;

  PartnerDeliveryItem({required this.label, required this.count});

  factory PartnerDeliveryItem.fromJson(Map<String, dynamic> json) {
    final variation =
        json['variation'] is Map ? json['variation'] as Map<String, dynamic> : null;
    return PartnerDeliveryItem(
      label:
          (variation?['title'] ?? json['variationTitle'] ?? json['title'] ?? '')
              .toString(),
      count: _toInt(json['quantity'] ?? json['count'] ?? 1),
    );
  }
}

/// A delivery assigned to the logged-in delivery agent. Response shape for
/// `/delivery-agent/my/deliveries*` isn't formally documented by the
/// backend, so this parses tolerantly (several fallback key names per
/// field) — same approach used for every other undocumented endpoint in
/// this app; expect one round of field-name fixes once tested against a
/// real response.
class PartnerDeliveryModel {
  final String id;
  final String status;
  final String date;
  final String? time;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String? landmark;
  final String? mapUrl;
  final String planName;
  final String? specialInstructions;
  final List<PartnerDeliveryItem> items;

  PartnerDeliveryModel({
    required this.id,
    required this.status,
    required this.date,
    this.time,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    this.landmark,
    this.mapUrl,
    required this.planName,
    this.specialInstructions,
    required this.items,
  });

  String get mealSummary =>
      items.map((i) => i.label).where((l) => l.isNotEmpty).join(' • ');

  factory PartnerDeliveryModel.fromJson(Map<String, dynamic> json) {
    final customer =
        json['customer'] is Map ? json['customer'] as Map<String, dynamic> : null;
    final customerUser =
        customer?['user'] is Map
            ? customer!['user'] as Map<String, dynamic>
            : null;
    final plan = json['plan'] is Map ? json['plan'] as Map<String, dynamic> : null;

    final rawItems = json['deliveryVariations'] ?? json['items'] ?? json['variations'];
    final items =
        rawItems is List
            ? rawItems
                .map((e) => PartnerDeliveryItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <PartnerDeliveryItem>[];

    return PartnerDeliveryModel(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? 'PENDING').toString().toUpperCase(),
      date: (json['date'] ?? '').toString(),
      time: (json['deliveryTime'] ?? json['time'] ?? json['slot'])?.toString(),
      customerId: (customer?['id'] ?? json['customerId'] ?? '').toString(),
      customerName:
          (customerUser?['name'] ?? customer?['name'] ?? json['customerName'] ?? 'Customer')
              .toString(),
      customerPhone:
          (customerUser?['phone'] ?? customer?['phone'] ?? json['customerPhone'] ?? '')
              .toString(),
      address: (customer?['address'] ?? json['address'] ?? '').toString(),
      landmark: (customer?['landmark'] ?? json['landmark'])?.toString(),
      mapUrl:
          (customer?['latitude_logitude'] ?? customer?['currentLocation'] ?? json['location'])
              ?.toString(),
      planName: (plan?['planName'] ?? json['planName'] ?? '').toString(),
      specialInstructions:
          (json['specialInstructions'] ?? json['notes'] ?? json['instructions'])?.toString(),
      items: items,
    );
  }
}

*/
