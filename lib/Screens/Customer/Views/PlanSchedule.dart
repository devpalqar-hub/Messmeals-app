import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class PlanScheduleWidget extends StatefulWidget {
  final String? selectedPlanId;
  final String? selectedDeliveryPartnerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedDays;
  final String? deliveryType;
  final String? preferredTime;

  final Function(String?) onPlanChanged;
  final Function(String?) onPartnerChanged;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  final Function(List<String>) onDaysChanged;
  final Function(String?) onTypeChanged;
  final Function(String?) onTimeChanged;

  const PlanScheduleWidget({
    super.key,
    required this.selectedPlanId,
    required this.selectedDeliveryPartnerId,
    required this.startDate,
    required this.endDate,
    required this.selectedDays,
    required this.deliveryType,
    required this.preferredTime,
    required this.onPlanChanged,
    required this.onPartnerChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onDaysChanged,
    required this.onTypeChanged,
    required this.onTimeChanged,
  });

  @override
  State<PlanScheduleWidget> createState() => _PlanScheduleWidgetState();
}

class _PlanScheduleWidgetState extends State<PlanScheduleWidget> {
  final PlanController planController = Get.put(PlanController());
  final PartnerController partnerController = Get.put(PartnerController());

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int selectedMonths = 1; // Default duration for monthly plans

  final List<String> days = [
    "MONDAY",
    "TUESDAY",
    "WEDNESDAY",
    "THURSDAY",
    "FRIDAY",
    "SATURDAY",
    "SUNDAY",
  ];

  final List<String> deliveryTypes = ["Custom", "Everyday"];

  @override
  void initState() {
    super.initState();
    planController.ensureLoaded();
    partnerController.ensureLoaded();
    selectedStartDate = widget.startDate;
    selectedEndDate = widget.endDate;
  }

  void _updateMonthlyEndDate() {
    if (selectedStartDate != null) {
      setState(() {
        // Automatically calculate the end date based on selected months
        selectedEndDate = DateTime(
          selectedStartDate!.year,
          selectedStartDate!.month + selectedMonths,
          selectedStartDate!.day,
        ).subtract(Duration(days: 1));
        ;
      });
      // Send the calculated date back to the parent
      widget.onEndDateChanged(selectedEndDate!);
    }
  }

  Future<void> pickDate(bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? (selectedStartDate ?? DateTime.now())
              : (selectedEndDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          selectedStartDate = pickedDate;
          widget.onStartDateChanged(pickedDate);
        } else {
          selectedEndDate = pickedDate;
          widget.onEndDateChanged(pickedDate);
        }
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat("dd MMM yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isEveryday = widget.deliveryType == "Everyday";

    // Check if the currently selected plan is a monthly plan
    final isMonthly = planController.plans.any(
      (it) => it.id == widget.selectedPlanId && it.isMonthlyPlan,
    );

    return GetBuilder<PlanController>(
      builder: (_) {
        return GetBuilder<PartnerController>(
          builder: (_) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      Container(
                        height: 45.w,
                        width: 45.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Plan & Schedule",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Select plan and delivery schedule",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  /// MEAL PLAN
                  title("Meal Plan *"),
                  SizedBox(height: 8.h),
                  dropdownField(
                    hint: "Select Meal Plan",
                    selectedId: widget.selectedPlanId,
                    ids: planController.plans.map((e) => e.id).toList(),
                    names: planController.plans.map((e) => e.planName).toList(),
                    onChanged: (val) {
                      widget.onPlanChanged(val);

                      // Check if the newly selected plan is monthly
                      final newlySelectedIsMonthly = planController.plans.any(
                        (p) => p.id == val && p.isMonthlyPlan,
                      );

                      if (newlySelectedIsMonthly) {
                        _updateMonthlyEndDate();

                        // Automatically set to Everyday and select all days if Monthly
                        widget.onTypeChanged("Everyday");
                        widget.onDaysChanged(List.from(days));
                      }
                    },
                  ),
                  SizedBox(height: 16.h),

                  /// DATES & DURATION ROW
                  Row(
                    children: [
                      /// START DATE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            title("Start Date *"),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () async {
                                await pickDate(true);
                                if (isMonthly) {
                                  _updateMonthlyEndDate();
                                }
                              },
                              child: dateField(
                                hint:
                                    selectedStartDate == null
                                        ? "Select Start Date"
                                        : formatDate(selectedStartDate),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),

                      /// END DATE / DURATION DROPDOWN
                      if (isMonthly)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title("Duration *"),
                              SizedBox(height: 8.h),
                              Container(
                                height: 48.h,
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: selectedMonths,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey.shade600,
                                    ),
                                    items:
                                        List.generate(12, (index) => index + 1)
                                            .map(
                                              (month) => DropdownMenuItem(
                                                value: month,
                                                child: Text(
                                                  "$month Month${month > 1 ? 's' : ''}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14.sp,
                                                    color: const Color(
                                                      0xFF111827,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          selectedMonths = val;
                                        });
                                        _updateMonthlyEndDate();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title("End Date *"),
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () => pickDate(false),
                                child: dateField(
                                  hint:
                                      selectedEndDate == null
                                          ? "Select End Date"
                                          : formatDate(selectedEndDate),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  /// DELIVERY PARTNER
                  title("Delivery Partner *"),
                  SizedBox(height: 8.h),
                  dropdownField(
                    hint: "Select Delivery Partner",
                    selectedId: widget.selectedDeliveryPartnerId,
                    ids:
                        partnerController.partners
                            .map((e) => e.deliveryPartnerProfile?.id ?? "")
                            .toList(),
                    names:
                        partnerController.partners.map((e) => e.name).toList(),
                    onChanged: widget.onPartnerChanged,
                  ),
                  SizedBox(height: 24.h),

                  /// SCHEDULE SECTION
                  Container(
                    // padding: EdgeInsets.all(16.w),
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.circular(10.r),
                    //   border: Border.all(color: Colors.grey.shade200),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.black.withOpacity(0.02),
                    //       blurRadius: 8,
                    //       spreadRadius: 1,
                    //     ),
                    //   ],
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ONLY SHOW DELIVERY TYPE & DAYS IF NOT MONTHLY
                        if (!isMonthly) ...[
                          title("Scheduled Delivery Type"),
                          SizedBox(height: 10.h),
                          dropdownFieldStatic(
                            hint: "Select delivery type",
                            value: widget.deliveryType,
                            items: deliveryTypes,
                            onChanged: (value) {
                              widget.onTypeChanged(value);
                              if (value == "Everyday") {
                                widget.onDaysChanged(List.from(days));
                              } else {
                                widget.onDaysChanged([]);
                              }
                              setState(() {});
                            },
                          ),
                          SizedBox(height: 16.h),

                          /// DAYS (ONLY FOR CUSTOM)
                          if (!isEveryday) ...[
                            title("Select Delivery Days *"),
                            SizedBox(height: 10.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: days.map((e) => dayChip(e)).toList(),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ],

                        /// NOTE
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 18.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Note",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      isMonthly
                                          ? "Orders will be scheduled automatically for every day during the chosen duration."
                                          : "Orders will be scheduled on selected days between the start and end date.",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade700,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget title(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget dayChip(String day) {
    final selected = widget.selectedDays.contains(day);
    return GestureDetector(
      onTap: () {
        final updated = List<String>.from(widget.selectedDays);
        if (selected) {
          updated.remove(day);
        } else {
          updated.add(day);
        }
        widget.onDaysChanged(updated);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            day.substring(0, 3),
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget dropdownField({
    required String hint,
    required String? selectedId,
    required List<String> ids,
    required List<String> names,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: ids.contains(selectedId) ? selectedId : null,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14.sp,
            ),
          ),
          items: List.generate(ids.length, (index) {
            return DropdownMenuItem<String>(
              value: ids[index],
              child: Text(
                names[index],
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: const Color(0xFF111827),
                ),
              ),
            );
          }),
          onChanged: (value) {
            onChanged(value);
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget dropdownFieldStatic({
    required String hint,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14.sp,
            ),
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (val) {
            onChanged(val);
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget dateField({required String hint}) {
    return Container(
      height: 48.h,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color:
                  hint.contains("Select")
                      ? Colors.grey.shade400
                      : const Color(0xFF111827),
            ),
          ),
          Icon(
            Icons.calendar_today_outlined,
            size: 16.sp,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }
}
