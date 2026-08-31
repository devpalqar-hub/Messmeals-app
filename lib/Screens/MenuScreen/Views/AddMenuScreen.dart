import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mess/Screens/MenuScreen/Models/MenuModel.dart';
import 'package:mess/Screens/MenuScreen/Service/MenuController.dart';
import 'package:mess/Screens/PlanScreen/Service/VariationController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class AddMenuScreen extends StatefulWidget {
  final bool isEdit;
  final String? menuId;
  final String? name;
  final bool isActive;
  final Map<String, List<MenuDayEntry>>? schedule;

  const AddMenuScreen({
    super.key,
    this.isEdit = false,
    this.menuId,
    this.name,
    this.isActive = true,
    this.schedule,
  });

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final MessMenuController controller = Get.put(MessMenuController());
  final VariationController variationController = Get.put(
    VariationController(),
  );

  final TextEditingController nameCtrl = TextEditingController();

  /// Keyed by lowercase weekday; each entry keeps its own items TextEditingController.
  final Map<String, List<_EntryFormRow>> daySchedule = {
    for (final day in kMenuWeekDays) day: <_EntryFormRow>[],
  };

  @override
  void initState() {
    super.initState();

    variationController.ensureLoaded();

    nameCtrl.text = widget.name ?? '';

    if (widget.schedule != null) {
      for (final entry in widget.schedule!.entries) {
        daySchedule[entry.key] =
            entry.value
                .map(
                  (e) => _EntryFormRow(
                    variationId: e.variationId,
                    itemsCtrl: TextEditingController(text: e.items),
                  ),
                )
                .toList();
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    for (final rows in daySchedule.values) {
      for (final row in rows) {
        row.itemsCtrl.dispose();
      }
    }
    super.dispose();
  }

  void _addEntry(String day) {
    if (variationController.variations.isEmpty) {
      Fluttertoast.showToast(
        msg: "No variations available. Add a variation first.",
      );
      return;
    }
    setState(() {
      daySchedule[day]!.add(
        _EntryFormRow(
          variationId: variationController.variations.first.id,
          itemsCtrl: TextEditingController(),
        ),
      );
    });
  }

  void _removeEntry(String day, int index) {
    setState(() {
      daySchedule[day]![index].itemsCtrl.dispose();
      daySchedule[day]!.removeAt(index);
    });
  }

  Map<String, List<MenuDayEntry>> _buildSchedulePayload() {
    final schedule = <String, List<MenuDayEntry>>{};
    for (final day in kMenuWeekDays) {
      final rows = daySchedule[day]!;
      schedule[day] =
          rows
              .map(
                (r) => MenuDayEntry(
                  variationId: r.variationId,
                  items: r.itemsCtrl.text.trim(),
                ),
              )
              .toList();
    }
    return schedule;
  }

  Future<void> _onSave() async {
    if (nameCtrl.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter menu name");
      return;
    }

    final hasAnyDay = daySchedule.values.any((rows) => rows.isNotEmpty);
    if (!hasAnyDay) {
      Fluttertoast.showToast(msg: "Add at least one item to any day");
      return;
    }

    for (final entry in daySchedule.entries) {
      for (final row in entry.value) {
        if (row.itemsCtrl.text.trim().isEmpty) {
          Fluttertoast.showToast(
            msg: "Please fill items for ${kMenuWeekDayLabels[entry.key]}",
          );
          return;
        }
      }
    }

    final success = await controller.saveMenu(
      id: widget.isEdit ? widget.menuId : null,
      name: nameCtrl.text.trim(),
      isActive: true,
      schedule: _buildSchedulePayload(),
    );

    if (success && mounted) {
      Get.back();
    }
  }

  Widget _title(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessMenuController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
              color: Colors.white,
              child: SizedBox(
                height: 45.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child:
                      controller.isLoading
                          ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            widget.isEdit ? "Update Menu" : "Create Menu",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 18.h,
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  size: 18.sp,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                widget.isEdit ? "Edit Menu" : "Create Menu",
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff111827),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Padding(
                            padding: EdgeInsets.only(left: 30.w),
                            child: Text(
                              widget.isEdit
                                  ? "Update the weekly menu schedule"
                                  : "Add a weekly menu schedule",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: 20.h,
                    ),
                    child: Column(
                      children: [
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title("Menu Name *"),
                              SizedBox(height: 10.h),
                              TextField(
                                controller: nameCtrl,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Normal Veg Menu",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 14.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        GetBuilder<VariationController>(
                          builder: (variationCtrl) {
                            return Column(
                              children:
                                  kMenuWeekDays.map((day) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 14.h),
                                      child: _daySection(day, variationCtrl),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _daySection(String day, VariationController variationCtrl) {
    final rows = daySchedule[day]!;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _title(kMenuWeekDayLabels[day]!),
              GestureDetector(
                onTap: () => _addEntry(day),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "Add item",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rows.isEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              "No items added",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            return Padding(
              key: ValueKey(row.rowId),
              padding: EdgeInsets.only(top: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value:
                              variationCtrl.variations.any(
                                    (v) => v.id == row.variationId,
                                  )
                                  ? row.variationId
                                  : null,
                          hint: Text(
                            "Variation",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                          items:
                              variationCtrl.variations
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v.id,
                                      child: Text(
                                        v.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => row.variationId = value);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: row.itemsCtrl,
                      style: GoogleFonts.poppins(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: "Rice, Dal, Sabzi, Roti",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.grey.shade400,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () => _removeEntry(day, index),
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: Colors.red.shade400,
                      ),
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
}

class _EntryFormRow {
  static int _counter = 0;

  /// Stable identity for this row (independent of the chosen variation), so Flutter
  /// never conflates two entries that happen to share the same variation on one day.
  final int rowId = _counter++;

  String variationId;
  final TextEditingController itemsCtrl;

  _EntryFormRow({required this.variationId, required this.itemsCtrl});
}
