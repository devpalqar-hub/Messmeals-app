import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mess/Screens/MenuScreen/Models/MenuModel.dart';
import 'package:mess/Screens/PlanScreen/Models/VariationModel.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

const double _kLabelColWidth = 66;
const double _kDayColWidth = 108;
const double _kDayHeaderHeight = 30;
const double _kMealRowHeight = 72;

/// Full weekly timetable for one menu — sized to its own content so every
/// meal row is always fully visible (no clipping), with a share/edit/delete
/// toolbar and a horizontally-scrollable day grid frozen to the meal-type
/// label column.
class MenuTimetableCard extends StatefulWidget {
  final MenuModel menu;
  final List<VariationModel> variations;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuTimetableCard({
    super.key,
    required this.menu,
    required this.variations,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<MenuTimetableCard> createState() => _MenuTimetableCardState();
}

class _MenuTimetableCardState extends State<MenuTimetableCard> {
  bool _isSharing = false;

  IconData _iconForVariation(String title) {
    final t = title.toLowerCase();
    if (t.contains('break')) return Icons.free_breakfast_outlined;
    if (t.contains('lunch')) return Icons.lunch_dining_outlined;
    if (t.contains('dinner')) return Icons.dinner_dining_outlined;
    if (t.contains('snack')) return Icons.cookie_outlined;
    if (t.contains('tea') || t.contains('coffee')) {
      return Icons.emoji_food_beverage_outlined;
    }
    return Icons.restaurant_outlined;
  }

  MenuDayEntry? _entryFor(String day, String variationId) {
    final entries = widget.menu.schedule[day];
    if (entries == null) return null;
    for (final e in entries) {
      if (e.variationId == variationId) return e;
    }
    return null;
  }

  /// Captures a full-width, unclipped render of the timetable — mounted
  /// off-screen (not the on-screen scrollable one, which is clipped to the
  /// visible viewport and would only capture whatever portion was scrolled
  /// into view) — then shares it as a PNG.
  Future<void> _shareAsImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    final captureKey = GlobalKey();
    OverlayEntry? entry;

    try {
      final overlayState = Overlay.of(context, rootOverlay: true);

      entry = OverlayEntry(
        builder:
            (_) => Positioned(
              left: -10000,
              top: 0,
              child: Material(
                type: MaterialType.transparency,
                child: RepaintBoundary(
                  key: captureKey,
                  child: _buildTimetableContent(forCapture: true),
                ),
              ),
            ),
      );
      overlayState.insert(entry);

      // Let it lay out and paint before capturing.
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Nothing to capture');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/menu_${widget.menu.id}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: widget.menu.name);
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to share menu");
    } finally {
      entry?.remove();
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Widget _toolbarIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 15,
    bool loading = false,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child:
            loading
                ? SizedBox(
                  width: size.sp,
                  height: size.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
                : Icon(icon, size: size.sp, color: color),
      ),
    );
  }

  Widget _dayHeaderCell(String day, String todayKey) {
    final isToday = day == todayKey;
    return SizedBox(
      width: _kDayColWidth.w,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            kMenuWeekDayLabels[day]!.substring(0, 3),
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isToday ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayCell(String day, VariationModel variation, String todayKey, bool isEvenRow) {
    final isToday = day == todayKey;
    final entry = _entryFor(day, variation.id);
    return Container(
      width: _kDayColWidth.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color:
            isToday
                ? AppColors.primary.withOpacity(0.06)
                : (isEvenRow ? Colors.grey.shade50 : Colors.white),
        border: Border.all(color: Colors.grey.shade100),
      ),
      alignment: Alignment.center,
      child:
          entry == null || entry.items.isEmpty
              ? Text(
                "—",
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade300),
              )
              : Text(
                entry.items,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
    );
  }

  Widget _labelColumn() {
    return SizedBox(
      width: _kLabelColWidth.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: _kDayHeaderHeight.h),
          ...widget.variations.map((v) {
            return SizedBox(
              height: _kMealRowHeight.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_iconForVariation(v.title), size: 16.sp, color: AppColors.primary),
                  SizedBox(height: 3.h),
                  Text(
                    v.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// The day-header row + all meal rows, at their full natural width
  /// (label column width + one column per weekday).
  Widget _gridBody(String todayKey) {
    return SizedBox(
      width: _kDayColWidth.w * kMenuWeekDays.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _kDayHeaderHeight.h,
            child: Row(
              children:
                  kMenuWeekDays.map((day) => _dayHeaderCell(day, todayKey)).toList(),
            ),
          ),
          ...widget.variations.asMap().entries.map((mapEntry) {
            final rowIndex = mapEntry.key;
            final variation = mapEntry.value;
            final isEvenRow = rowIndex % 2 == 0;
            return SizedBox(
              height: _kMealRowHeight.h,
              child: Row(
                children:
                    kMenuWeekDays
                        .map((day) => _dayCell(day, variation, todayKey, isEvenRow))
                        .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// [forCapture] = true renders the grid at its full natural width with no
  /// scroll clipping (used only for the off-screen share capture);
  /// false renders the normal on-screen version, horizontally scrollable
  /// when it doesn't fit the card's width.
  Widget _buildTimetableContent({required bool forCapture}) {
    final todayKey = kMenuWeekDays[(DateTime.now().weekday - 1) % 7];
    final activeDays =
        kMenuWeekDays
            .where((d) => (widget.menu.schedule[d]?.isNotEmpty ?? false))
            .length;

    final grid = _gridBody(todayKey);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (forCapture) ...[
            Text(
              widget.menu.name,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 4.h),
          ],
          Text(
            "$activeDays day(s) · ${widget.menu.totalEntries} items",
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: forCapture ? MainAxisSize.min : MainAxisSize.max,
            children: [
              _labelColumn(),
              forCapture
                  ? grid
                  : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: grid,
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- TOOLBAR ----------
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 10.w, 6.h),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.menu.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      if (!widget.menu.isActive) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            "Inactive",
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _toolbarIcon(
                  icon: Icons.ios_share_rounded,
                  color: AppColors.primary,
                  size: 19,
                  onTap: _shareAsImage,
                  loading: _isSharing,
                ),
                SizedBox(width: 6.w),
                _toolbarIcon(
                  icon: Icons.edit_outlined,
                  color: Colors.grey.shade700,
                  onTap: widget.onEdit,
                ),
                SizedBox(width: 6.w),
                _toolbarIcon(
                  icon: Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 19,
                  onTap: widget.onDelete,
                ),
              ],
            ),
          ),

          /// ---------- TIMETABLE (on-screen, horizontally scrollable) ----------
          _buildTimetableContent(forCapture: false),
        ],
      ),
    );
  }
}
