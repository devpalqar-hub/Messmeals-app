// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/DeliveryPartner/Customers/Models/PartnerCustomerModel.dart';
import 'package:mess/Screens/DeliveryPartner/Customers/Service/PartnerCustomerController.dart';
import 'package:mess/Screens/DeliveryPartner/Customers/Views/CustomerDetailScreen.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Service/PartnerDeliveryController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class CustomersListScreen extends StatelessWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PartnerDeliveryController());
    final controller = Get.put(PartnerCustomerController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureLoaded();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<PartnerCustomerController>(
            builder: (ctrl) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customers",
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  /// ---------- SEARCH ----------
                  TextField(
                    onChanged: ctrl.updateSearch,
                    decoration: InputDecoration(
                      hintText: "Search by name or phone...",
                      hintStyle: TextStyle(fontSize: 13.sp),
                      prefixIcon: Icon(Icons.search, size: 20.sp),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      filled: true,
                      fillColor: Colors.white,
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
                        borderSide: BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  /// ---------- PLAN FILTER ----------
                  if (ctrl.availablePlans.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _planChip(ctrl, null, "All Plans"),
                          ...ctrl.availablePlans.map((p) => _planChip(ctrl, p, p)),
                        ],
                      ),
                    ),

                  SizedBox(height: 12.h),

                  Expanded(
                    child:
                        ctrl.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ctrl.filteredCustomers.isEmpty
                            ? Center(
                              child: Text(
                                "No customers found",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: ctrl.refresh,
                              child: ListView.separated(
                                itemCount: ctrl.filteredCustomers.length,
                                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                                itemBuilder: (context, index) {
                                  final c = ctrl.filteredCustomers[index];
                                  return _CustomerTile(customer: c);
                                },
                              ),
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _planChip(PartnerCustomerController ctrl, String? value, String label) {
    final isSelected = ctrl.planFilter == value;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () => ctrl.updatePlanFilter(value),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final PartnerCustomerModel customer;

  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => CustomerDetailScreen(customer: customer)),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  if (customer.phone.isNotEmpty)
                    Text(
                      customer.phone,
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                  if (customer.planName.isNotEmpty)
                    Text(
                      customer.planName,
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

*/
