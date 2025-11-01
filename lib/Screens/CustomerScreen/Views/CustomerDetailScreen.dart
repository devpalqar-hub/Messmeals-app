import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddWallet.dart';
import 'package:mess/Screens/CustomerScreen/Views/RenewSubscription.dart';
import 'package:mess/Screens/CustomerScreen/Views/SubscriptionDetailCard.dart';
import 'package:mess/Screens/CustomerScreen/Views/WalletStatusCrad.dart';
import 'package:mess/Screens/PartnerScreen/Views/RecentlyDeliveryCard.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _toIsoDate(String uiDate) {
    try {
      final parsed = DateFormat('MMM d, yyyy').parse(uiDate);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return uiDate;
    }
  }

  /// TODO: Replace static mapping with real API IDs
  

  bool canRenew(DateTime endDate) {
    final today = DateTime.now();
    final twoWeeksBefore = endDate.subtract(const Duration(days: 14));
    return today.isAfter(twoWeeksBefore) || today.isAtSameMomentAs(twoWeeksBefore);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());

    final activeSub = customer.activeSubscriptions.isNotEmpty
        ? customer.activeSubscriptions.first
        : null;

    bool showRenewButton = false;
    String endNote = '';

    if (activeSub != null) {
      final endDate = activeSub.endDate;
      final today = DateTime.now();
      final daysLeft = endDate.difference(today).inDays;

      if (canRenew(endDate)) {
        showRenewButton = true;
        endNote = "Renew Subscription — ends in $daysLeft days";
      } else {
        endNote = "Active — $daysLeft days remaining";
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- HEADER ----------
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Customer Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),

                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddCustomerScreen(customer: customer),
                        ),
                      );
                    },
                    child: _headerButton(Icons.edit_outlined, "Edit"),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context, controller),
                    child: _headerButton(Icons.delete_outline, "Delete"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// ---------- PROFILE CARD ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name.substring(0, 2).toUpperCase()
                            : "U",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 35),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              fontFamily: "Inter",
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _infoRow(Icons.phone, customer.phone),
                          _infoRow(Icons.email_outlined, customer.email),
                          _infoRow(Icons.location_on_outlined, customer.address),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// ---------- WALLET + STATS ----------
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: WalletStatusCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: const Color(0xFF2ECC71),
                      label: 'WALLET \nBALANCE',
                      value: "₹${customer.walletBalance}",
                      actionText: 'Add money',
                      isPrimary: true,
                 onAction: () async {
  // Open bottom sheet
  final amountText = await showAddWalletAmountSheet(context);

  if (amountText != null && amountText.toString().trim().isNotEmpty) {
    final amount = double.tryParse(amountText.toString()) ?? 0;

    if (amount > 0) {
      await controller.updateWalletBalance(
        customerProfileId: customer.customerProfileId,
        amount: amount.toString(),
      );

      // ✅ Refresh screen with updated customer details
      await controller.fetchCustomerDetails(customer.customerProfileId);

    } else {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid amount greater than 0.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
      );
    }
  }
},

                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: WalletStatusCard(
                      icon: Icons.inbox_rounded,
                      iconColor: const Color(0xFF6C8CFF),
                      label: 'TOTAL \nORDERS',
                      value: '${customer.totalOrders}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: WalletStatusCard(
                      icon: Icons.credit_card_rounded,
                      iconColor: const Color(0xFFB066FF),
                      label: 'TOTAL\nSPENT',
                      value: "₹${customer.totalSpent}",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WalletStatusCard(
                      icon: Icons.calendar_today_rounded,
                      iconColor: const Color(0xFFFF8A3D),
                      label: 'DAYS\nLEFT',
                      value: activeSub != null
                          ? '${customer.noOfDaysToEnd}'
                          : '0',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// ---------- SUBSCRIPTION CARD ----------
           /// ---------- SUBSCRIPTION CARD OR EMPTY STATE ----------
if (customer.activeSubscriptions.isEmpty) ...[
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade300),
      color: const Color(0xFFF9FAFB),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, color: Colors.grey, size: 36),
        const SizedBox(height: 8),
        const Text(
          "No subscriptions added yet",
          style: TextStyle(
            fontSize: 15,
            fontFamily: "Inter",
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EBA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final result = await showRenewSubscriptionSheet(
                context,
                customerProfileId: customer.customerProfileId,
              );

              if (result != null && result is Map<String, dynamic>) {
                await controller.renewSubscription(
                  planId: result['planId'],
                  startDate: _toIsoDate(result['start']),
                  endDate: _toIsoDate(result['end']),
                  deliveryPartnerId: result['partnerId'],
                  discount: result['discount'] ?? '0',
                  customerProfileId: customer.customerProfileId,
                );
              }
            },
            child: const Text(
              "Add Subscription",
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
] else ...[
  SubscriptionDetailsCard(
  activeSubscriptionId: activeSub!.id, // ✅ added
  customerProfileId: customer.customerProfileId, // ✅ added
  currentPlan: activeSub.plan.name,
  planPrice: "₹${activeSub.discountedPrice > 0 ? activeSub.discountedPrice : activeSub.totalPrice}",
  startDate: formatDate(activeSub.startDate),
  endDate: formatDate(activeSub.endDate),
  endNote: endNote,
  variationTitles: customer.activeSubscriptions.first.plan.variation.map((v) => v.title).toList(),
  onRenew: showRenewButton ? () async {
    final result = await showRenewSubscriptionSheet(
      context,
      customerProfileId: customer.customerProfileId,
    );
    if (result != null && result is Map<String, dynamic>) {
      await controller.renewSubscription(
        planId: result['planId'],
        startDate: _toIsoDate(result['start']),
        endDate: _toIsoDate(result['end']),
        deliveryPartnerId: result['partnerId'],
        discount: result['discount'] ?? '0',
        customerProfileId: customer.customerProfileId,
      );
    }
  } : () {},
  onCancel: () async {
    final success = await controller.cancelSubscription(
      activeSub.id,
      customer.id,
    );
    if (success) {
      Get.back();
    }
  },
)

],


              const SizedBox(height: 15),

              /// ---------- RECENT DELIVERIES ----------
              RecentDeliveriesSection(
                deliveries: [
                  {
                    "status": "Completed",
                    "deliveryId": "DLV-1024",
                    "date": "Oct 22, 2025",
                    "amount": "₹540.00",
                  },
                  {
                    "status": "Pending",
                    "deliveryId": "DLV-1023",
                    "date": "Oct 20, 2025",
                    "amount": "₹235.00",
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- DELETE DIALOG ----------
  void _showDeleteDialog(BuildContext context, CustomerController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Customer"),
        content: Text(
          "Are you sure you want to delete ${customer.name}? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteCustomer(customer.id);
              await controller.refreshCustomers();
              Get.back();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// ---------- HELPERS ----------
  Widget _headerButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xff717182),
                fontSize: 14,
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
