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

// On-screen grid: days run down the left (frozen) column, meal types run
// across the top, scrollable horizontally if there are more than fit.
const double _kDayLabelColWidth = 58;
const double _kMealColWidth = 110;
const double _kMealHeaderHeight = 46;
const double _kDayRowHeight = 76;

// Share-poster grid sizing. `Table` (used by `_shareGrid`) needs a *finite*
// incoming width to lay out at all — it can't size itself the way a Row/
// Column can under the unbounded constraints the off-screen capture overlay
// hands down. So the poster is wrapped in a SizedBox using exactly this
// width (see `_buildShareTemplate`), keeping the Table happy and making
// sure nothing is clipped.
const double _kShareDayLabelColWidth = 56;
const double _kShareMealColWidth = 118;
const double _kSharePosterHPadding = 14;

/// Full weekly timetable for one menu — days run down the left as rows,
/// meal types (Breakfast/Lunch/Dinner, from the mess's own Variations) run
/// across the top as columns — sized to its own content so every row is
/// always fully visible, with a share/edit/delete toolbar.
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

  /// A distinct accent color per meal type — gives the grid and poster a
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
      // Pre-load and decode the logo before capturing — otherwise the
      // asset is still mid-decode when the screenshot is taken and the
      // badge renders blank.
      if (mounted) {
        await precacheImage(
          const AssetImage('assets/app_launcher_icon.png'),
          context,
        );
      }

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

  // ================= ON-SCREEN GRID (days = rows, meals = columns) =================

  Widget _mealHeaderCell(VariationModel v) {
    final color = _colorForVariation(v.title);
    return SizedBox(
      width: _kMealColWidth.w,
      height: _kMealHeaderHeight.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(_iconForVariation(v.title), size: 13.sp, color: color),
          ),
          SizedBox(height: 3.h),
          Text(
            v.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayLabelCell(String day, bool isToday) {
    return SizedBox(
      height: _kDayRowHeight.h,
      width: _kDayLabelColWidth.w,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            kMenuWeekDayLabels[day]!.substring(0, 3),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: isToday ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(String day, VariationModel variation, bool isToday) {
    final entry = _entryFor(day, variation.id);
    final tint = _colorForVariation(variation.title);
    return Container(
      width: _kMealColWidth.w,
      height: _kDayRowHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primary.withOpacity(0.07) : tint.withOpacity(0.035),
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

  Widget _dayLabelColumn(String todayKey) {
    return SizedBox(
      width: _kDayLabelColWidth.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: _kMealHeaderHeight.h),
          ...kMenuWeekDays.map((day) => _dayLabelCell(day, day == todayKey)),
        ],
      ),
    );
  }

  /// The meal-header row + all day rows, at their full natural width
  /// (one column per variation).
  Widget _mealGridBody(String todayKey) {
    return SizedBox(
      width: _kMealColWidth.w * widget.variations.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _kMealHeaderHeight.h,
            child: Row(
              children: widget.variations.map(_mealHeaderCell).toList(),
            ),
          ),
          ...kMenuWeekDays.map((day) {
            final isToday = day == todayKey;
            return SizedBox(
              height: _kDayRowHeight.h,
              child: Row(
                children:
                    widget.variations
                        .map((v) => _cell(day, v, isToday))
                        .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// The normal on-screen version — horizontally scrollable if there are
  /// more meal-type columns than fit the card's width.
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
              _dayLabelColumn(todayKey),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _mealGridBody(todayKey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= SHARE POSTER (days = rows, meals = columns) =================

  Widget _shareMealHeaderCell(VariationModel v) {
    final color = _colorForVariation(v.title);
    return Container(
      color: color.withOpacity(0.12),
      padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(_iconForVariation(v.title), size: 13.sp, color: Colors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            v.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shareDayLabelCell(String day, bool isToday) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              kMenuWeekDayLabels[day]!.substring(0, 3),
              style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: isToday ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
          if (isToday) ...[
            SizedBox(height: 3.h),
            Text(
              "★ TODAY",
              style: GoogleFonts.poppins(
                fontSize: 6.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _shareCell(String day, VariationModel variation, bool isToday) {
    final entry = _entryFor(day, variation.id);
    final tint = _colorForVariation(variation.title);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      alignment: Alignment.center,
      color: isToday ? AppColors.primary.withOpacity(0.07) : tint.withOpacity(0.045),
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

  /// A colorful, fully-visible bordered grid for the shared poster — a real
  /// `Table` (not the fixed-height/ellipsis on-screen grid) so every row
  /// grows to fit its content instead of clipping or truncating long meal
  /// lists. Days run down the rows, meal types across the columns.
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
          0: FixedColumnWidth(_kShareDayLabelColWidth.w),
          for (var i = 0; i < widget.variations.length; i++)
            i + 1: FixedColumnWidth(_kShareMealColWidth.w),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade50),
            children: [
              const SizedBox.shrink(),
              ...widget.variations.map(_shareMealHeaderCell),
            ],
          ),
          ...kMenuWeekDays.map((day) {
            final isToday = day == todayKey;
            return TableRow(
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary.withOpacity(0.04) : Colors.white,
              ),
              children: [
                _shareDayLabelCell(day, isToday),
                ...widget.variations.map(
                  (v) => _shareCell(day, v, isToday),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// The professional, colorful, MessMeals-branded poster captured for
  /// sharing — a wavy gradient header with the mess's own branding, the
  /// weekly grid with color-coded meal columns, and a "Powered by
  /// MessMeals" footer.
  Widget _buildShareTemplate() {
    final todayKey = kMenuWeekDays[(DateTime.now().weekday - 1) % 7];
    final activeDays =
        kMenuWeekDays
            .where((d) => (widget.menu.schedule[d]?.isNotEmpty ?? false))
            .length;

    // Explicit width, sized to fit the grid exactly (day-label column + one
    // fixed column per variation + the grid's own horizontal padding). Two
    // things depend on this being a real, finite number rather than left
    // unbounded:
    // • `Table` (inside `_shareGrid`) can't lay out at all under the
    //   unbounded width the off-screen capture overlay hands down otherwise.
    // • Matching it exactly to the grid's real width is what keeps the
    //   poster from clipping content on the right.
    final posterWidth =
        (_kShareDayLabelColWidth +
                _kShareMealColWidth * widget.variations.length +
                _kSharePosterHPadding * 2)
            .w;

    return Container(
      width: posterWidth,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// ---------- BRANDED HEADER (wavy bottom edge) ----------
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 34.h),
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
                      // The real MessMeals app icon (not `appLogo.png`, which
                      // carries an "Admin Portal" wordmark not meant for this
                      // customer-facing shared poster).
                      Container(
                        height: 38.w,
                        width: 38.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/app_launcher_icon.png',
                            height: 38.w,
                            width: 38.w,
                            fit: BoxFit.cover,
                          ),
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
                              "🍽️ Weekly Food Menu",
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
          ),

          /// ---------- GRID ----------
          Padding(
            padding: EdgeInsets.fromLTRB(
              _kSharePosterHPadding.w,
              4.h,
              _kSharePosterHPadding.w,
              10.h,
            ),
            child: _shareGrid(todayKey),
          ),

          /// ---------- MESSMEALS BRANDING FOOTER ----------
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Book this through MessMeals App",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/app_launcher_icon.png',
                        height: 13.sp,
                        width: 13.sp,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Powered by MessMeals",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 0.3,
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

/// A single gentle S-wave cut across the bottom edge — used to give the
/// shared poster's header a "menu card" feel instead of a hard rectangle.
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 18);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 12);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 24);
    final secondEndPoint = Offset(size.width, size.height - 6);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
