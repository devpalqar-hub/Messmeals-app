// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:get/get.dart';
import 'package:mess/Screens/DeliveryPartner/Customers/Models/PartnerCustomerModel.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Service/PartnerDeliveryController.dart';

/// Customers are derived from the delivery agent's own deliveries (deduped)
/// rather than a dedicated endpoint — see [PartnerCustomerModel].
class PartnerCustomerController extends GetxController {
  final PartnerDeliveryController deliveryController =
      Get.find<PartnerDeliveryController>();

  bool isLoading = false;
  String searchQuery = '';
  String? planFilter;

  List<PartnerCustomerModel> get customers {
    final byId = <String, PartnerCustomerModel>{};
    for (final d in deliveryController.deliveries) {
      if (d.customerId.isEmpty) continue;
      byId[d.customerId] = PartnerCustomerModel.fromDelivery(d);
    }
    return byId.values.toList();
  }

  List<PartnerCustomerModel> get filteredCustomers {
    var list = customers;
    if (planFilter != null && planFilter!.isNotEmpty) {
      list = list.where((c) => c.planName == planFilter).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list =
          list
              .where(
                (c) =>
                    c.name.toLowerCase().contains(q) || c.phone.contains(q),
              )
              .toList();
    }
    return list;
  }

  List<String> get availablePlans =>
      customers.map((c) => c.planName).where((p) => p.isNotEmpty).toSet().toList();

  Future<void> ensureLoaded() async {
    if (deliveryController.deliveries.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    isLoading = true;
    update();
    await deliveryController.fetchDeliveries();
    isLoading = false;
    update();
  }

  void updateSearch(String query) {
    searchQuery = query;
    update();
  }

  void updatePlanFilter(String? plan) {
    planFilter = plan;
    update();
  }
}

*/
