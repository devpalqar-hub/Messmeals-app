import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mess/Screens/DeliveriesScreen/Model/DeliveryModel.dart';
import 'package:mess/Screens/DeliveriesScreen/Services/DeliveriesController.dart';

class OrderCard extends StatefulWidget {
  final Delivery delivery;

  const OrderCard({super.key, required this.delivery});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> with TickerProviderStateMixin {
  bool _expanded = false;
  int _selectedStatus = 0;

  final DeliveriesController _controller = Get.find();

  final List<String> _statusValues = ["PENDING", "PROGRESS", "DELIVERED"];

  Customer? get customer => widget.delivery.customer;
  User? get user => customer?.user;
  Plan? get plan => widget.delivery.plan;

  bool _has(String? v) => v != null && v.trim().isNotEmpty;

  String get formattedDate {
    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(DateTime.parse(widget.delivery.date));
    } catch (_) {
      return widget.delivery.date;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus = _statusValues.indexOf(
      widget.delivery.status.toUpperCase(),
    );
    if (_selectedStatus == -1) _selectedStatus = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== TOP SECTION =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LEFT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Capsule(label: _statusValues[_selectedStatus]),
                    SizedBox(height: 8.h),

                    if (_has(user?.name))
                      Text(
                        user!.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    SizedBox(height: 4.h),

                    if (_has(user?.phone))
                      _rowInfo(Icons.call_outlined, user!.phone),

                    if (_has(customer?.address))
                      _rowInfo(Icons.location_on_outlined, customer!.address),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "₹${plan?.price ?? 0}",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  SizedBox(
                    width: 110,
                    child: Text(
                      plan?.planName ?? '',
                      maxLines: 2,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child:
                !_expanded
                    ? const SizedBox()
                    : Column(
                      children: [
                        const SizedBox(height: 6),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        _statusPillsContainer(),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _actionButton(
                                Icons.place_outlined,
                                "Open Map",
                                Colors.blue,
                                _openInMap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _actionButton(
                                Icons.call_outlined,
                                "Call",
                                Colors.green,
                                _callNow,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  /// ===== HELPERS =====

  Widget _rowInfo(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey[600]),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPillsContainer() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(_statusValues.length, (index) {
          final isSelected = _selectedStatus == index;
          final text = _statusValues[index];

          return Expanded(
            child: GestureDetector(
              onTap: () async {
                final success = await _controller.updateDeliveryStatus(
                  widget.delivery.id,
                  text,
                );
                if (success) {
                  setState(() => _selectedStatus = index);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===== ACTIONS =====

  Future<void> _openInMap() async {
    if (!_has(customer?.address)) return;

    final encoded = Uri.encodeComponent(customer!.address);

    await launchUrl(
      Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded"),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _callNow() async {
    if (!_has(user?.phone)) return;

    await launchUrl(Uri(scheme: 'tel', path: user!.phone));
  }
}

/// ===== STATUS CAPSULE =====

class _Capsule extends StatelessWidget {
  final String label;

  const _Capsule({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
