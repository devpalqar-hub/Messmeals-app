import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/MenuScreen/Models/MenuModel.dart';
import 'package:mess/Screens/PlanScreen/Models/VariationModel.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

const double _kLabelColWidth = 66;
const double _kDayColWidth = 108;
const double _kDayHeaderHeight = 30;
const double _kMealRowHeight = 72;

// Share-poster grid sizing. `Table` (used by `_shareGrid`) needs a *finite*
// incoming width to lay out at all — it can't size itself the way a Row/
// Column can under the unbounded constraints the off-screen capture overlay
// hands down. So the poster is wrapped in a SizedBox using exactly this
// width (see `_buildShareTemplate`), keeping the Table happy and making
// sure nothing is clipped.
const double _kShareLabelColWidth = 64;
const double _kShareDayColWidth = 90;
const double _kSharePosterHPadding = 14;

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

  /// A distinct accent color per meal type — gives the shared poster a
  /// colorful, "one glance tells you the meal" feel instead of one flat hue.
  Color _colorForVariation(String title) {
    final t = title.toLowerCase();
    if (t.contains('break')) return const Color(0xFFF59E0B); // amber
    if (t.contains('lunch')) return const Color(0xFF16A34A); // green
    if (t.contains('dinner')) return const Color(0xFF6366F1); // indigo
    if (t.contains('snack')) return const Color(0xFFEC4899); // pink
    if (t.contains('tea') || t.contains('coffee')) {
      return const Color(0xFF92400E); // brown
    }
    return AppColors.primaryDark;
  }

  /// Best-effort name of the currently selected mess, for branding the
  /// shared poster. Falls back gracefully if the controller/mess isn't
  /// available (e.g. HomeScreenController not yet registered).
  String get _messName {
    try {
      final home = Get.find<HomeScreenController>();
      final mess = home.messes.firstWhereOrNull(
        (m) => m.id == home.selectedMessId,
      );
      return (mess?.name?.trim().isNotEmpty ?? false) ? mess!.name! : 'Mess';
    } catch (_) {
      return 'Mess';
    }
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
                  child: _buildShareTemplate(),
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

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "${widget.menu.name} — $_messName\nPowered by MessMeals 🍽️",
      );
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

  /// The normal on-screen version — horizontally scrollable when the grid
  /// doesn't fit the card's width.
  Widget _buildTimetableContent() {
    final todayKey = kMenuWeekDays[(DateTime.now().weekday - 1) % 7];
    final activeDays =
        kMenuWeekDays
            .where((d) => (widget.menu.schedule[d]?.isNotEmpty ?? false))
            .length;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            children: [
              _labelColumn(),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _gridBody(todayKey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// A simple, fully-visible bordered grid for the shared poster — a real
  /// `Table` (not the fixed-height/ellipsis on-screen grid) so every row
  /// grows to fit its content instead of clipping or truncating long meal
  /// lists, and column widths are fixed so nothing needs horizontal
  /// scrolling to be seen.
  Widget _shareGrid(String todayKey) {
    final borderSide = BorderSide(color: Colors.grey.shade200);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Table(
        border: TableBorder(
          horizontalInside: borderSide,
          verticalInside: borderSide,
          top: borderSide,
          bottom: borderSide,
          left: borderSide,
          right: borderSide,
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FixedColumnWidth(_kShareLabelColWidth.w),
          for (var i = 0; i < kMenuWeekDays.length; i++)
            i + 1: FixedColumnWidth(_kShareDayColWidth.w),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
            children: [
              const SizedBox.shrink(),
              ...kMenuWeekDays.map((day) => _shareDayHeaderCell(day, todayKey)),
            ],
          ),
          ...widget.variations.asMap().entries.map((mapEntry) {
            final isEvenRow = mapEntry.key % 2 == 0;
            final variation = mapEntry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: isEvenRow ? Colors.grey.shade50 : Colors.white,
              ),
              children: [
                _shareMealLabelCell(variation),
                ...kMenuWeekDays.map(
                  (day) => _shareDayCell(day, variation, todayKey),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _shareDayHeaderCell(String day, String todayKey) {
    final isToday = day == todayKey;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      alignment: Alignment.center,
      color: isToday ? AppColors.primary : null,
      child: Text(
        kMenuWeekDayLabels[day]!.substring(0, 3),
        style: GoogleFonts.poppins(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: isToday ? Colors.white : const Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _shareMealLabelCell(VariationModel v) {
    final color = _colorForVariation(v.title);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconForVariation(v.title), size: 14.sp, color: color),
          SizedBox(height: 3.h),
          Text(
            v.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shareDayCell(String day, VariationModel variation, String todayKey) {
    final isToday = day == todayKey;
    final entry = _entryFor(day, variation.id);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      alignment: Alignment.center,
      color: isToday ? AppColors.primary.withOpacity(0.05) : null,
      child:
          entry == null || entry.items.isEmpty
              ? Text(
                "—",
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade300),
              )
              // No maxLines/ellipsis here — the row simply grows to fit the
              // full item list so nothing gets cut off in the shared image.
              : Text(
                entry.items,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
    );
  }

  /// The professional, colorful, MessMeals-branded poster captured for
  /// sharing — a gradient header with the mess's own branding, the weekly
  /// grid with color-coded meal types, and a "Powered by MessMeals" footer.
  Widget _buildShareTemplate() {
    final todayKey = kMenuWeekDays[(DateTime.now().weekday - 1) % 7];
    final activeDays =
        kMenuWeekDays
            .where((d) => (widget.menu.schedule[d]?.isNotEmpty ?? false))
            .length;

    // Explicit width, sized to fit the grid exactly (label column + 7 fixed
    // day columns + the grid's own horizontal padding). Two things depend on
    // this being a real, finite number rather than left unbounded:
    // • `Table` (inside `_shareGrid`) can't lay out at all under the
    //   unbounded width the off-screen capture overlay hands down otherwise.
    // • Matching it exactly to the grid's real width is what keeps the
    //   poster from clipping content on the right.
    final posterWidth =
        (_kShareLabelColWidth +
                _kShareDayColWidth * kMenuWeekDays.length +
                _kSharePosterHPadding * 2)
            .w;

    return Container(
      width: posterWidth,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// ---------- BRANDED HEADER ----------
          Container(
            padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // A neutral fork/knife badge — the bundled app logo carries an
                    // "Admin Portal" wordmark that isn't meant for this customer-
                    // facing shared poster.
                    Container(
                      height: 38.w,
                      width: 38.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.primaryDark,
                        size: 19.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _messName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Weekly Food Menu",
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    widget.menu.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "$activeDays day(s) scheduled · ${widget.menu.totalEntries} items",
                  style: GoogleFonts.poppins(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          /// ---------- GRID ----------
          Padding(
            padding: EdgeInsets.fromLTRB(
              _kSharePosterHPadding.w,
              14.h,
              _kSharePosterHPadding.w,
              10.h,
            ),
            child: _shareGrid(todayKey),
          ),

          /// ---------- MESSMEALS BRANDING FOOTER ----------
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  size: 13.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 6.w),
                Text(
                  "Powered by MessMeals",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
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
          _buildTimetableContent(),
        ],
      ),
    );
  }
}
