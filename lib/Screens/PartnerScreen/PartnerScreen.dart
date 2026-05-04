import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/PartnerScreen/Views/PartnerCard.dart';
import 'package:mess/Screens/Utils/TitleText.dart';

class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  // Use Get.find if initialized in a parent, or keep Get.put if this is the first entry
  final PartnerController controller = Get.put(PartnerController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial fetch
    controller.fetchPartners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<PartnerController>( 
            builder: (controller) {
            
              if (controller.isLoading && controller.partners.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final partners = controller.partners;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TittleText(text: "Partners"),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Get.to(() => const AddPartnerScreen());
                          if (result == true) {
                            await controller.fetchPartners();
                          }
                        },
                        icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                        label: Text(
                          "Add",
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
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

                  SizedBox(height: 6.h),

                  Text(
                    "${controller.totalRecords} total",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  TextField(
                    controller: searchController,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: "Search partners...",
                      hintStyle: TextStyle(fontSize: 14.sp),
                      prefixIcon: Icon(Icons.search, size: 20.sp),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.5.w,
                        ),
                      ),
                    ),
                    onChanged: (query) {
                     
                      if (query.isEmpty) {
                        controller.fetchPartners();
                      } else {
                       
                        setState(() {}); 
                      }
                    },
                  ),

                  SizedBox(height: 16.h),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => controller.fetchPartners(),
                      child: partners.isEmpty && !controller.isLoading
                          ? const Center(child: Text("No partners found"))
                          : ListView.separated(
                              padding: EdgeInsets.only(bottom: 20.h),
                              // Filter logic applied during build
                              itemCount: partners.where((p) => p.name.toLowerCase().contains(searchController.text.toLowerCase())).length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 15.h),
                              itemBuilder: (context, index) {
                                final filteredList = partners.where((p) => p.name.toLowerCase().contains(searchController.text.toLowerCase())).toList();
                                final partner = filteredList[index];
                                final stats = partner.stats;
                                final profile = partner.deliveryPartnerProfile;

                                return PartnerCard(
                                  id: partner.id,
                                  name: partner.name,
                                  phone: partner.phone,
                                  email: partner.email,
                                  totalOrders: stats?.totalDeliveries ?? 0,
                                  location: profile?.address ?? "N/A",
                                  isActive: partner.isActive,
                                );
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
}