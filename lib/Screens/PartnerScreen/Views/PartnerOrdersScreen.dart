import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mess/Screens/DeliveriesScreen/DeliveriesScreen.dart';
import 'package:mess/Screens/DeliveriesScreen/Model/DeliveryModel.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

/// This delivery partner's full order list (`GET /deliveries?messId=&
/// partnerId=`, up to 100 at once, scrollable rather than paginated) as a
/// single drag-to-reorder list: dragging an order up or down sets its
/// delivery priority for this partner's route (`sortOrderId`), e.g.
/// dragging the 4th order to the top makes it deliver first.
class PartnerOrdersScreen extends StatefulWidget {
  final String partnerId;
  final String partnerName;

  const PartnerOrdersScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<PartnerOrdersScreen> createState() => _PartnerOrdersScreenState();
}

class _PartnerOrdersScreenState extends State<PartnerOrdersScreen> {
  final DeliveriesController _controller = Get.put(DeliveriesController());
  List<Delivery> _orders = [];

  // The number shown on each card is a permanent label, captured once
  // when an order is first loaded — dragging never touches it, even for
  // the card you move. `delivery.sortOrderId` keeps changing underneath
  // (that's the real priority value that gets sorted and saved) but this
  // map is what the badge actually reads.
  final Map<String, int> _displayNumber = {};

  @override
  void initState() {
    super.initState();
    _controller.limit = 100;
    _fetch();
  }

  Future<void> _fetch() async {
    await _controller.fetchDeliveries(partnerId: widget.partnerId);
    _orders = List.of(_controller.deliveries)..sort(_byPriority);
    // The label is always a clean 1, 2, 3... by current list position —
    // never the raw backend value, since that can carry messy leftovers
    // (0s, negatives) from earlier testing/reordering.
    for (var i = 0; i < _orders.length; i++) {
      _displayNumber.putIfAbsent(_orders[i].id, () => i + 1);
    }
    if (mounted) setState(() {});
  }

  int _byPriority(Delivery a, Delivery b) {
    final aOrder = a.sortOrderId;
    final bOrder = b.sortOrderId;
    if (aOrder == null && bOrder == null) return 0;
    if (aOrder == null) return 1; // unordered items sink to the bottom
    if (bOrder == null) return -1;
    return aOrder.compareTo(bOrder);
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final previous = List.of(_orders);

    final moved = _orders.removeAt(oldIndex);
    _orders.insert(newIndex, moved);

    // Only the order you actually dragged gets a new priority number —
    // every other order keeps the number it already had, so dragging
    // order #29 to the top still shows "29" at position 1.
    final before = newIndex > 0 ? _orders[newIndex - 1].sortOrderId : null;
    final after =
        newIndex < _orders.length - 1
            ? _orders[newIndex + 1].sortOrderId
            : null;
    final newSortOrderId = _priorityBetween(before, after);
    final previousSortOrderId = moved.sortOrderId;
    moved.sortOrderId = newSortOrderId;
    setState(() {});

    final success = await _controller.updateSortOrder(moved.id, newSortOrderId);
    if (!success && mounted) {
      moved.sortOrderId = previousSortOrderId;
      setState(() => _orders = previous);
    }
  }

  /// A priority number for the dropped position, fit between its new
  /// neighbours' own numbers rather than renumbering the whole list.
  int _priorityBetween(int? before, int? after) {
    if (before == null && after == null) return 1;
    if (before == null) return after! - 1; // dropped above everything
    if (after == null) return before + 1; // dropped below everything
    if (after - before > 1) return (before + after) ~/ 2; // room in the gap
    return before + 1; // no gap left — slot in right after `before`
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Color(0xFF111827),
            size: 18,
          ),
        ),
        title: Text(
          "${widget.partnerName}'s Orders",
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFEEEEF0)),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<DeliveriesController>(
          builder: (ctrl) {
            if (ctrl.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (_orders.isEmpty) {
              return Center(
                child: Text(
                  'No orders assigned to this partner yet.',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              );
            }

            return ReorderableListView.builder(
              // Delayed (press-and-hold) drag start on the whole card —
              // a quick touch-and-move just scrolls the list normally;
              // holding in place for a moment picks the card up to drag.
              buildDefaultDragHandles: false,
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 16.h),
              itemCount: _orders.length,
              onReorder: _onReorder,
              itemBuilder:
                  (context, index) => ReorderableDelayedDragStartListener(
                    key: ValueKey(_orders[index].id),
                    index: index,
                    child: _buildCard(_orders[index], index),
                  ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(Delivery delivery, int rank) {
    final customerName = delivery.customer?.user?.name ?? 'Unknown customer';
    String formattedDate;
    try {
      formattedDate = DateFormat(
        'dd MMM',
      ).format(DateTime.parse(delivery.date));
    } catch (_) {
      formattedDate = delivery.date;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFEEEEF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 26.w),
            height: 26.w,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13.r),
            ),
            // The order's own permanent label — stays with this specific
            // order wherever it's dragged, never recalculated.
            child: Text(
              '${_displayNumber[delivery.id] ?? delivery.sortOrderId ?? '-'}',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    if ((delivery.plan?.planName ?? '').isNotEmpty) ...[
                      Flexible(
                        child: Text(
                          delivery.plan!.planName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _statusChip(delivery.status),
          SizedBox(width: 6.w),
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            child: Icon(
              Icons.drag_handle_rounded,
              size: 22.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final meta = _statusMeta(status.toUpperCase());
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: meta.light,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        meta.label,
        style: GoogleFonts.poppins(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w600,
          color: meta.color,
        ),
      ),
    );
  }

  _StatusMeta _statusMeta(String status) {
    switch (status) {
      case 'DELIVERED':
      case 'COMPLETED':
        return _StatusMeta(
          status == 'DELIVERED' ? 'Delivered' : 'Completed',
          const Color(0xFF3B6D11),
          const Color(0xFFEAF3DE),
        );
      case 'CANCELLED':
        return _StatusMeta(
          'Cancelled',
          const Color(0xFFA32D2D),
          const Color(0xFFFCEBEB),
        );
      case 'PENDING':
      default:
        return _StatusMeta(
          'Pending',
          const Color(0xFF854F0B),
          const Color(0xFFFAEEDA),
        );
    }
  }
}

class _StatusMeta {
  final String label;
  final Color color;
  final Color light;
  const _StatusMeta(this.label, this.color, this.light);
}
