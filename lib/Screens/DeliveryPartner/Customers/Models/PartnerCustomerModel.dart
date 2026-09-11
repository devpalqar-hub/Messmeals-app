// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:mess/Screens/DeliveryPartner/Deliveries/Models/PartnerDeliveryModel.dart';

/// There's no dedicated "my customers" endpoint for delivery agents, so this
/// is derived client-side from the agent's own deliveries (deduped by
/// customer id) — each entry just remembers the most recent delivery's
/// plan/address for that customer.
class PartnerCustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String? landmark;
  final String? mapUrl;
  final String planName;

  PartnerCustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.landmark,
    this.mapUrl,
    required this.planName,
  });

  factory PartnerCustomerModel.fromDelivery(PartnerDeliveryModel d) {
    return PartnerCustomerModel(
      id: d.customerId,
      name: d.customerName,
      phone: d.customerPhone,
      address: d.address,
      landmark: d.landmark,
      mapUrl: d.mapUrl,
      planName: d.planName,
    );
  }
}

*/
