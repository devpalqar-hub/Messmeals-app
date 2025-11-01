import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/DeliveriesScreen/Services/DeliveriesController.dart';

class OrderCard extends StatefulWidget {
  final String id;
  final String status;
  final String amount;
  final int orderNo;
  final String customerName;
  final String phone;
  final DateTime date;

  final String? addressLine1;
  final String? addressLine2;
  final String? cityStateZip;
  final String? altPhone;
  final String? fax;
  final String? email;

  const OrderCard({
    super.key,
    required this.id,
    required this.status,
    required this.amount,
    required this.orderNo,
    required this.customerName,
    required this.phone,
    required this.date,
    this.addressLine1,
    this.addressLine2,
    this.cityStateZip,
    this.altPhone,
    this.fax,
    this.email,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  int _selectedStatus = 0;
  final DeliveriesController _controller = Get.find();

  /// ✅ Fixed commas between statuses
  final List<String> _statusValues = [
    "PENDING",
    "PROGRESS",
    "DELIVERED",
  ];

  @override
  void initState() {
    super.initState();
    // Match backend status to the pill
    _selectedStatus = _statusValues.indexOf(widget.status.toUpperCase());
    if (_selectedStatus == -1) _selectedStatus = 0;
  }

  String get _dateStr {
    final d = widget.date;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: status + amount
          Row(
            children: [
              _Capsule(label: widget.status),
              const Spacer(),
              Text(widget.amount,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),

          // Customer + Date
          Row(
            children: [
              Expanded(
                child: Text(widget.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              Text(_dateStr,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),

          // Phone + expand
          Row(
            children: [
              Text(widget.phone,
                  style: TextStyle(
                      color: Colors.blueGrey[700], fontWeight: FontWeight.w500)),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ),
            ],
          ),

          if (_expanded) const Divider(),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded ? _expandedDetails() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _expandedDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.addressLine1 != null) _line(widget.addressLine1!),
        if (widget.addressLine2 != null) _line(widget.addressLine2!),
        if (widget.cityStateZip != null) _line(widget.cityStateZip!),
        if (widget.altPhone != null) _line('Alt Phone: ${widget.altPhone!}'),
        if (widget.email != null) _line('Email: ${widget.email!}'),

        const Divider(thickness: 1),
        const SizedBox(height: 10),

        /// ✅ Pills (same design, fixed logic)
        _statusPillsContainer(),
        const SizedBox(height: 10),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _actionButton(Icons.place_outlined, 'Open in Map', Colors.blue, () {}),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionButton(Icons.call_outlined, 'Call Now', Colors.green, () {}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _line(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      );

  /// ✅ Simple Flat Pills (original UI)
  Widget _statusPillsContainer() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(_statusValues.length, (index) {
          final text = _statusValues[index];
          final isSelected = _selectedStatus == index;

          return Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _selectedStatus = index;
                });
                await _controller.updateDeliveryStatus(widget.id, text);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.black,
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

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _Capsule extends StatelessWidget {
  final String label;
  const _Capsule({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
