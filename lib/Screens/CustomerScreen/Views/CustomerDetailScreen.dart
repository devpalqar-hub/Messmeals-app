import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddWallet.dart';
import 'package:mess/Screens/CustomerScreen/Views/CancelSubscriptionBottomsheet.dart';
import 'package:mess/Screens/CustomerScreen/Views/PauseOrderDailogue.dart';
import 'package:mess/Screens/CustomerScreen/Views/RenewSubscription.dart';
import 'package:mess/Screens/CustomerScreen/Views/SubscriptionDetailCard.dart';
import 'package:mess/Screens/CustomerScreen/Views/WalletStatusCrad.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  String formatDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

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
    return today.isAfter(twoWeeksBefore) ||
        today.isAtSameMomentAs(twoWeeksBefore);
  }

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return GetBuilder<CustomerController>(
      builder: (controller) {
        final current = controller.customers.firstWhereOrNull(
              (c) =>
                  c.customerProfileId ==
                  customer.customerProfileId,
            ) ??
            customer;

        final activeSub = current.activeSubscriptions.isNotEmpty
            ? current.activeSubscriptions.first
            : null;

        final showRenewButton =
            activeSub != null && canRenew(activeSub.endDate);

        final endNote = activeSub != null
            ? (showRenewButton
                ? "Renew Subscription — ends in ${activeSub.endDate.difference(DateTime.now()).inDays} days"
                : "Active — ${activeSub.endDate.difference(DateTime.now()).inDays} days remaining")
            : '';

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                      Text(
                        "Customer Details",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final changed =
                              await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddCustomerScreen(customer: current),
                            ),
                          );
                          if (changed == true) {
                            await controller.fetchCustomerDetails(
                                current.customerProfileId);
                          }
                        },
                        child: _headerButton(
                            Icons.edit_outlined, "Edit"),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => _showDeleteDialog(
                            context, controller, current),
                        child: _headerButton(
                            Icons.delete_outline, "Delete"),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  /// ---------- PROFILE CARD ----------
                  _profileCard(current),

                  SizedBox(height: 16.h),

                  /// ---------- WALLET + STATS ----------
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: WalletStatusCard(
                          icon:
                              Icons.account_balance_wallet_rounded,
                          iconColor:
                              const Color(0xFF2ECC71),
                          label: 'WALLET \nBALANCE',
                          value:
                              "₹${current.walletBalance}",
                          actionText: 'Add money',
                          isPrimary: true,
                          onAction: () async {
                            final amountText =
                                await showAddWalletAmountSheet(
                                    context);
                            if (amountText != null &&
                                amountText
                                    .toString()
                                    .trim()
                                    .isNotEmpty) {
                              final amount =
                                  double.tryParse(
                                          amountText.toString()) ??
                                      0;
                              if (amount > 0) {
                                await controller
                                    .updateWalletBalance(
                                  customerProfileId:
                                      current.customerProfileId,
                                  amount: amount.toString(),
                                );
                                await controller
                                    .fetchCustomerDetails(
                                        current
                                            .customerProfileId);
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 4,
                        child: WalletStatusCard(
                          icon: Icons.inbox_rounded,
                          iconColor:
                              const Color(0xFF6C8CFF),
                          label: 'TOTAL \nORDERS',
                          value:
                              '${current.totalOrders}',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: WalletStatusCard(
                          icon: Icons.credit_card_rounded,
                          iconColor:
                              const Color(0xFFB066FF),
                          label: 'TOTAL\nSPENT',
                          value:
                              "₹${current.totalSpent}",
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: WalletStatusCard(
                          icon:
                              Icons.calendar_today_rounded,
                          iconColor:
                              const Color(0xFFFF8A3D),
                          label: 'DAYS\nLEFT',
                          value: current
                                  .activeSubscriptions
                                  .isNotEmpty
                              ? '${current.noOfDaysToEnd}'
                              : '0',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  /// ---------- SUBSCRIPTION ----------
                  if (current.activeSubscriptions.isEmpty)
                    _noSubscriptionCard(
                        context, controller, current)
                  else
                    SubscriptionDetailsCard(
                      activeSubscriptionId:
                          activeSub!.id,
                      customerProfileId:
                          current.customerProfileId,
                      currentPlan:
                          activeSub.plan.name,
                      planPrice:
                          "₹${activeSub.discountedPrice > 0 ? activeSub.discountedPrice : activeSub.totalPrice}",
                      startDate:
                          formatDate(activeSub.startDate),
                      endDate:
                          formatDate(activeSub.endDate),
                      endNote: endNote,
                      variationTitles: activeSub
                          .plan.variation
                          .map((v) => v.title)
                          .toList(),
                      onPause: () async {
                        final result =
                            await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) =>
                              PauseOrderBottomSheet(
                            orderStart:
                                activeSub.startDate,
                            orderEnd:
                                activeSub.endDate,
                            customerProfileId:
                                current.customerProfileId,
                          ),
                        );
                        if (result != null &&
                            result is Map<String, dynamic>) {
                          await controller.pauseSubscription(
                            activeSub.id,
                            current.customerProfileId,
                            result['start'],
                            result['end'],
                          );
                        }
                      },
                      onRenew: showRenewButton
                          ? () async {
                              final result =
                                  await showRenewSubscriptionSheet(
                                context,
                                customerProfileId:
                                    current.customerProfileId,
                              );
                              if (result is Map<String, dynamic>) {
                                final ok =
                                    await controller
                                        .renewSubscription(
                                  planId: result['planId'],
                                  startDate: _toIsoDate(
                                      result['start']),
                                  endDate: _toIsoDate(
                                      result['end']),
                                  deliveryPartnerId:
                                      result['partnerId'],
                                  discount:
                                      result['discount'] ?? '0',
                                  customerProfileId:
                                      current.customerProfileId,
                                );
                                if (ok) {
                                  await controller
                                      .fetchCustomerDetails(
                                          current
                                              .customerProfileId);
                                }
                              }
                            }
                          : () {},
                      onCancel: () async {
                        final result =
                            await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) =>
                              CancelSubscriptionBottomSheet(
                            startDate:
                                activeSub.startDate,
                            endDate:
                                activeSub.endDate,
                            customerProfileId:
                                current.customerProfileId,
                          ),
                        );
                        if (result != null &&
                            result is Map<String, dynamic>) {
                          await controller
                              .fetchCustomerDetails(
                                  current.customerProfileId);
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ---------- HELPERS ----------

  Widget _profileCard(CustomerModel current) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                current.name.isNotEmpty
                    ? current.name
                        .substring(0, 2)
                        .toUpperCase()
                    : "U",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(current.name,
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight:
                              FontWeight.w600)),
                  _infoRow(Icons.phone, current.phone),
                  _infoRow(
                      Icons.email_outlined, current.email),
                  _infoRow(Icons.location_on_outlined,
                      current.address),
                ],
              ),
            ),
          ],
        ),
      );

  static Widget _headerButton(
          IconData icon, String text) =>
      Container(
        padding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 4.w),
            Text(text,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );

  static Widget _infoRow(IconData icon, String text) =>
      Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: Colors.grey),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600])),
            ),
          ],
        ),
      );

  void _showDeleteDialog(BuildContext context,
      CustomerController controller, CustomerModel current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Customer"),
        content: Text(
            "Are you sure you want to delete ${current.name}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
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

  Widget _noSubscriptionCard(BuildContext context,
      CustomerController controller, CustomerModel current) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 36.sp),
          SizedBox(height: 8.h),
          Text("No subscriptions added yet"),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: () async {
              final result =
                  await showRenewSubscriptionSheet(
                context,
                customerProfileId: current.customerProfileId,
              );
              if (result != null) {
                await controller.fetchCustomerDetails(
                    current.customerProfileId);
              }
            },
            child: const Text("Add Subscription"),
          ),
        ],
      ),
    );
  }
}
