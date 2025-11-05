import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddWallet.dart';
import 'package:mess/Screens/CustomerScreen/Views/PauseOrderDailogue.dart';
import 'package:mess/Screens/CustomerScreen/Views/RenewSubscription.dart';
import 'package:mess/Screens/CustomerScreen/Views/SubscriptionDetailCard.dart';
import 'package:mess/Screens/CustomerScreen/Views/WalletStatusCrad.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  String _toIsoDate(String uiDate) {
    try {
      final parsed = DateFormat('MMM d, yyyy').parse(uiDate);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return uiDate;
    }
  }

  bool canRenew(DateTime endDate) {
    final today = DateTime.now();
    final twoWeeksBefore = endDate.subtract(const Duration(days: 14));
    return today.isAfter(twoWeeksBefore) || today.isAtSameMomentAs(twoWeeksBefore);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerController>();

    return Obx(() {
      final current = controller.customers.firstWhereOrNull(
            (c) => c.customerProfileId == customer.customerProfileId,
          ) ??
          customer;

      final activeSub = current.activeSubscriptions.isNotEmpty ? current.activeSubscriptions.first : null;
      final showRenewButton = activeSub != null && canRenew(activeSub.endDate);
      final endNote = activeSub != null
          ? (showRenewButton
              ? "Renew Subscription — ends in ${activeSub.endDate.difference(DateTime.now()).inDays} days"
              : "Active — ${activeSub.endDate.difference(DateTime.now()).inDays} days remaining")
          : '';

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- HEADER ----------
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
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCustomerScreen(customer: current),
                          ),
                        );
                        if (changed == true) {
                          await controller.fetchCustomerDetails(current.customerProfileId);
                        }
                      },
                      child: _headerButton(Icons.edit_outlined, "Edit"),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showDeleteDialog(context, controller, current),
                      child: _headerButton(Icons.delete_outline, "Delete"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ---------- PROFILE CARD ----------
               Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Avatar
      CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          current.name.isNotEmpty ? current.name.substring(0, 2).toUpperCase() : "U",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
            fontSize: 18,
          ),
        ),
      ),
      const SizedBox(width: 20),

      // Info + Button (aligned at top-right)
      Expanded(
        child: Stack(
          children: [
            // Profile Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    fontFamily: "Inter",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                _infoRow(Icons.phone, current.phone),
                _infoRow(Icons.email_outlined, current.email),
                _infoRow(Icons.location_on_outlined, current.address),
              ],
            ),

           
             
          ],
        ),
      ),
    ],
  ),
),


                const SizedBox(height: 15),

                // ---------- WALLET + STATS ----------
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: WalletStatusCard(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: const Color(0xFF2ECC71),
                        label: 'WALLET \nBALANCE',
                        value: "₹${current.walletBalance}",
                        actionText: 'Add money',
                        isPrimary: true,
                        onAction: () async {
                          final amountText = await showAddWalletAmountSheet(context);
                          if (amountText != null && amountText.toString().trim().isNotEmpty) {
                            final amount = double.tryParse(amountText.toString()) ?? 0;
                            if (amount > 0) {
                              await controller.updateWalletBalance(
                                customerProfileId: current.customerProfileId,
                                amount: amount.toString(),
                              );
                              await controller.fetchCustomerDetails(current.customerProfileId);
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
                        value: '${current.totalOrders}',
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
                        value: "₹${current.totalSpent}",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WalletStatusCard(
                        icon: Icons.calendar_today_rounded,
                        iconColor: const Color(0xFFFF8A3D),
                        label: 'DAYS\nLEFT',
                        value: current.activeSubscriptions.isNotEmpty ? '${current.noOfDaysToEnd}' : '0',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ---------- SUBSCRIPTION ----------
                if (current.activeSubscriptions.isEmpty)
                  _noSubscriptionCard(context, controller, current)
                else
                  SubscriptionDetailsCard(
                    activeSubscriptionId: current.activeSubscriptions.first.id,
                    customerProfileId: current.customerProfileId,
                    currentPlan: current.activeSubscriptions.first.plan.name,
                    planPrice:
                        "₹${current.activeSubscriptions.first.discountedPrice > 0 ? current.activeSubscriptions.first.discountedPrice : current.activeSubscriptions.first.totalPrice}",
                    startDate: formatDate(current.activeSubscriptions.first.startDate),
                    endDate: formatDate(current.activeSubscriptions.first.endDate),
                    endNote: endNote,
                onPause: () async {
  final activeSub = current.activeSubscriptions.first;
  final result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => PauseOrderBottomSheet(
      orderStart: activeSub.startDate,
      orderEnd: activeSub.endDate,
      customerProfileId: current.customerProfileId,
    ),
  );

  if (result != null && result is Map<String, dynamic>) {
    await controller.pauseSubscription(
      activeSub.id,                 // ✅ Corrected here
      current.customerProfileId,    
      result['start'],              
      result['end'],                
    );
  }
},

                    variationTitles:
                        current.activeSubscriptions.first.plan.variation.map((v) => v.title).toList(),
                    onRenew: showRenewButton
                        ? () async {
                            final result = await showRenewSubscriptionSheet(context,
                                customerProfileId: current.customerProfileId);
                            if (result is Map<String, dynamic>) {
                              final ok = await controller.renewSubscription(
                                planId: result['planId'],
                                startDate: _toIsoDate(result['start']),
                                endDate: _toIsoDate(result['end']),
                                deliveryPartnerId: result['partnerId'],
                                discount: result['discount'] ?? '0',
                                customerProfileId: current.customerProfileId,
                              );
                              if (ok) {
                                await controller.fetchCustomerDetails(current.customerProfileId);
                              }
                            }
                          }
                        : () {},
                    onCancel: () async {
                      final success = await controller.cancelSubscription(
                        current.activeSubscriptions.first.id,
                        current.id,
                      );
                      if (success) {
                        await controller.fetchCustomerDetails(current.customerProfileId);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ---------- DELETE DIALOG ----------
  void _showDeleteDialog(BuildContext context, CustomerController controller, CustomerModel current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Customer"),
        content: Text("Are you sure you want to delete ${current.name}? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteCustomer(current.id);
              Get.back();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
  
  Widget _noSubscriptionCard( BuildContext context, 
  CustomerController controller, CustomerModel current, )
   { return Container
   ( width: double.infinity, padding: const EdgeInsets.all(20), 
   decoration: BoxDecoration
   ( borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade300), 
    color: const Color(0xFFF9FAFB), ), 
    child: Column( crossAxisAlignment: CrossAxisAlignment.center,
     children: [ const Icon(Icons.info_outline, 
     color: Colors.grey, size: 36), 
     const SizedBox(height: 8),
      const Text( "No subscriptions added yet",
       style: TextStyle( fontSize: 15,
        fontFamily: "Inter", color: Colors.black54, fontWeight: FontWeight.w500, ), ),
         const SizedBox(height: 12), SizedBox( width: double.infinity, height: 46,
          child: ElevatedButton( 
            style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFF0D6EBA), 
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(8), ), ), 
            onPressed: () async { final result = await showRenewSubscriptionSheet(context, 
            customerProfileId: current.customerProfileId);
            if (result != null && result is Map<String, dynamic>)
             { final ok = await controller.renewSubscription( planId: result['planId'],
              startDate: _toIsoDate(result['start']),
               endDate: _toIsoDate(result['end']), 
               deliveryPartnerId: result['partnerId'], 
               discount: result['discount'] ?? '0', 
               customerProfileId: current.customerProfileId, );
               if (ok) { await controller.fetchCustomerDetails(current.customerProfileId);  } } }, 
               child: const Text( "Add Subscription", 
               style: TextStyle( fontFamily: "Inter", 
               fontWeight: FontWeight.w600,
                fontSize: 16, color: Colors.white, ),
                 ), ), ), ], ), ); }

  // ---------- HELPER BUTTON ----------
  Widget _headerButton(IconData icon, String text) => Container(
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
            Text(text,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87, fontFamily: "Inter")),
          ],
        ),
      );

  Widget _infoRow(IconData icon, String text) => Padding(
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
