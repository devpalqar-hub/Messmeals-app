import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';

class MealChartCard extends StatefulWidget {
  const MealChartCard({super.key});

  @override
  State<MealChartCard> createState() => _MealChartCardState();
}

class _MealChartCardState extends State<MealChartCard> {
  final DashboardController controller = Get.put(DashboardController());

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff00BFA5),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.updateDate(picked); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final variation = controller.variationData.value;
      final isLoading = controller.isVariationLoading.value;

      final formattedDate =
          DateFormat('MMM d, yyyy').format(controller.selectedDate.value);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
       
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Meal Type Breakdown",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xffF4F6F8),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            if (isLoading)
              SizedBox(
                height: 120.h,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (variation == null || variation.data.isEmpty)
              SizedBox(
                height: 120.h,
                child: const Center(
                  child: Text("No data available for this date"),
                ),
              )
            else
              SizedBox(
                height: 140.h,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 6,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    sections: variation.data.map((item) {
                      final color = _getColorForTitle(item.title);
                      return PieChartSectionData(
                        color: color,
                        value: item.count.toDouble(),
                        showTitle: false,
                        radius: 25.w,
                      );
                    }).toList(),
                  ),
                ),
              ),

            SizedBox(height: 12.h),

            /// 🔹 Legend / Labels
            if (variation != null && variation.data.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20.w,
                children: variation.data.map((item) {
                  final color = _getColorForTitle(item.title);
                  return _MealTypeStat(
                    color: color,
                    title: item.title,
                    value: item.count.toString(),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }

  Color _getColorForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'breakfast':
        return const Color(0xff00E5FF);
      case 'lunch':
        return const Color(0xff00BFA5);
      case 'dinner':
        return const Color(0xff4DB6AC);
      default:
        return Colors.grey.shade400;
    }
  }
}

class _MealTypeStat extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const _MealTypeStat({
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
