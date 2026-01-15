import 'package:flutter/material.dart';
import 'package:mess/Screens/DeliveriesScreen/Model/DeliveryModel.dart';
import 'package:mess/Screens/DeliveriesScreen/Services/DeliveriesController.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class OrderCard extends StatefulWidget {
  final Delivery delivery;

  const OrderCard({super.key, required this.delivery});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _expanded = false;
  int _selectedStatus = 0;

  final DeliveriesController _controller = Get.find<DeliveriesController>();

  final List<String> _statusValues = ["PENDING", "PROGRESS", "DELIVERED"];

  @override
  void initState() {
    super.initState();
    _selectedStatus =
        _statusValues.indexOf(widget.delivery.status.toUpperCase());
    if (_selectedStatus == -1) _selectedStatus = 0;
  }

  Customer? get customer => widget.delivery.customer;
  User? get user => customer?.user;
  Plan? get plan => widget.delivery.plan;

  bool _has(String? v) => v != null && v.trim().isNotEmpty;

  String get formattedDate {
    try {
      return DateFormat('dd MMM yyyy')
          .format(DateTime.parse(widget.delivery.date));
    } catch (_) {
      return widget.delivery.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (Status + Details + Price)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LEFT SIDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     SizedBox(height: 6),
                    _Capsule(label: _statusValues[_selectedStatus]),
                    SizedBox(height: 3),

                    if (_has(user?.name)) Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: _text(user!.name, bold: true),
                    ),
                     SizedBox(height: 3),
                    if (_has(user?.phone))
                      _rowInfo(Icons.call_outlined, user!.phone),
                    if (_has(customer?.address))
                      SizedBox(height: 3),
                      _rowInfo(Icons.location_on_outlined, customer!.address),
                  ],
                ),
              ),

              /// RIGHT SIDE (TIGHT — NO TOP SPACE)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                   SizedBox(height: 10),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                   const SizedBox(height: 10),
                  Text(
                    "₹${plan?.price ?? '0'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                   const SizedBox(height: 10),
                  Text(
                    plan?.planName ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// EXPAND BUTTON
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon:
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () =>
                  setState(() => _expanded = !_expanded),
            ),
          ),

          /// EXPANDED CONTENT
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: !_expanded
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      const SizedBox(height: 15),
                      Divider(height:1,),
                       const SizedBox(height: 20),

                      _statusPillsContainer(),

                      const SizedBox(height: 12),

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
                          const SizedBox(width: 12),
                          Expanded(
                            child: _actionButton(
                              Icons.call_outlined,
                              "Call Now",
                              Colors.green,
                              _callNow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// ---------------- HELPERS ----------------

  Widget _text(String text, {bool bold = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      );

  Widget _rowInfo(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );

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
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- ACTIONS ----------------

  Future<void> _openInMap() async {
    if (!_has(customer?.address)) return;
    final encoded = Uri.encodeComponent(customer!.address);
    await launchUrl(
      Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$encoded"),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _callNow() async {
    if (!_has(user?.phone)) return;
    await launchUrl(Uri(scheme: 'tel', path: user!.phone));
  }
}

/// ---------------- STATUS CAPSULE ----------------

class _Capsule extends StatelessWidget {
  final String label;

  const _Capsule({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
