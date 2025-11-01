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
  final PartnerController controller = Get.put(PartnerController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchPartners();
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

            final partners = controller.partners;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- HEADER ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TittleText(text: "Partners"),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddPartnerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text("Add", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0474B9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 13.h),
                      ),
                    ),
                  ],
                ),

                Text(
                  "${controller.totalRecords} total",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),

                SizedBox(height: 16.h),

                /// ---------- SEARCH ----------
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search partners...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onChanged: (query) {
                    if (query.isNotEmpty) {
                      final filtered = controller.partners
                          .where((p) =>
                              p.name.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                      controller.partners.value = filtered;
                    } else {
                      controller.fetchPartners();
                    }
                  },
                ),

                SizedBox(height: 16.h),

                /// ---------- PARTNER LIST ----------
                Expanded(
  child: ListView.separated(
    itemCount: partners.length,
    separatorBuilder: (context, index) => SizedBox(height: 15.h),
    itemBuilder: (context, index) {
      final partner = partners[index];
      final stats = partner.stats;
      final profile = partner.deliveryPartnerProfile;

      return PartnerCard(
        id: partner.id,
        name: partner.name,
        phone: partner.phone,
        email: partner.email,
        totalOrders: stats?.totalDeliveries ?? 0,
        location: profile?.address?? "N/A",
        isActive: partner.isActive,
        onEdit: () async {},   // ✅ these are not used inside card, but required params
        onDelete: () async {},
        onTap: () {},
      );
    },
  ),
),

              ],
            );
          }),
        ),
      ),
    );
  }
}
