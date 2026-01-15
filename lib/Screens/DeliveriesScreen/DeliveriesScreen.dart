import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/DeliveriesScreen/Services/DeliveriesController.dart';
import 'package:mess/Screens/DeliveriesScreen/Views/GenerateCard.dart';
import 'package:mess/Screens/DeliveriesScreen/Views/OrderCard.dart';
import 'package:mess/Screens/Utils/TitleText.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  final DeliveriesController controller = Get.put(DeliveriesController());

  String selectedStatus = "All Status";
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    controller.fetchDeliveries();
  }

  /// Open date picker and update deliveries list
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      controller.searchDeliveries(
        date: picked,
        status: _statusToApiValue(selectedStatus),
      );
    }
  }

 
  String? _statusToApiValue(String value) {
    switch (value) {
      case "Pending":
        return "PENDING";
      case "Progress":
        return "PROGRESS";
      case "Delivered":
        return "DELIVERED";
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final deliveries = controller.deliveries;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TittleText(text: "Deliveries"),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => GenerateDeliveriesDialog(),
                          );
                        },
                        icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                        label: Text(
                          "Generate",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0474B9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 25.w,
                            vertical: 13.h,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                  Text(
                    "${deliveries.length} total",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),

                
                  _buildFilterRow(context),

                  SizedBox(height: 16.h),

                  if (deliveries.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.h),
                        child: Text(
                          "No deliveries found",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    ...deliveries.map((delivery) {
                      final customer = delivery.customer;
                      final user = customer?.user;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: OrderCard(
                          delivery: delivery,
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Row(
      children: [

        Expanded(
          child: _dropdown(
            value: selectedStatus,
            items: ["All Status", "Pending", "Progress", "Delivered"],
            onChanged: (v) {
              setState(() {
                selectedStatus = v!;
              });
              controller.searchDeliveries(
                date: selectedDate,
                status: _statusToApiValue(v!),
              );
            },
          ),
        ),
        SizedBox(width: 10.w),

       
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null
                        ? "Select Date"
                        : DateFormat('dd MMM yyyy').format(selectedDate!),
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                  ),
                  Icon(Icons.calendar_today_rounded,
                      size: 18.sp, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 20.sp, color: Colors.grey),
          isExpanded: true,
          style: TextStyle(fontSize: 14.sp, color: Colors.black),
          onChanged: onChanged,
          items: items
              .map((v) => DropdownMenuItem<String>(
                    value: v,
                    child: Text(
                      v,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
