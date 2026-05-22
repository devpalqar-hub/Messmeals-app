
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/Customer/Views/customer_card.dart';
import 'package:mess/Screens/Utils/AppColors.dart';


class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  final List<Map<String, String>> customers = const [
    {
      "name": "test",
      "phone": "+91 98765 43210",
      "initials": "T",
    },
    {
      "name": "Ramesh Agarwal",
      "phone": "+91 91234 56789",
      "initials": "RA",
    },
    {
      "name": "Priya Sharma",
      "phone": "+91 99876 54321",
      "initials": "PS",
    },
    {
      "name": "Amit Kumar",
      "phone": "+91 95555 12345",
      "initials": "AK",
    },
    {
      "name": "Sneha Mehta",
      "phone": "+91 90909 87654",
      "initials": "SM",
    },
    {
      "name": "Vikram Singh",
      "phone": "+91 88888 11111",
      "initials": "VK",
    },
    {
      "name": "Anjali Sharma",
      "phone": "+91 77777 22222",
      "initials": "AS",
    },
    {
      "name": "Deepak Patel",
      "phone": "+91 66666 33333",
      "initials": "DP",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 18.h),

              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      Text(
                        "Customers",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "56 Total Customers",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff4b5563),
                        ),
                      ),
                    ],
                  ),

                 GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerScreen(),
      ),
    );
  },
  child: Container(
    height: 50.h,
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      children: [
        Icon(
          Icons.add,
          color: Colors.white,
          size: 20.sp,
        ),

        SizedBox(width: 4.w),

        Text(
          "Add Customer",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14.sp,
          ),
        ),
      ],
    ),
  ),
)
                ],
              ),

              const SizedBox(height: 28),

            Row(
  children: [
    Expanded(
      child: Container(
        height: 45.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xffe5e7eb),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Color(0xff6b7280),
              size: 20,
            ),

            SizedBox(width: 5.w),

            Expanded(
              child: TextField(
                style: TextStyle(
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: "Search by name, phone or email...",
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),

    SizedBox(width: 10.w),

    /// Filter Button
    Container(
      height: 45.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xffe5e7eb),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            size: 18,
            color: Color(0xff374151),
          ),

          SizedBox(width: 5.w),

          Text(
            "All Plans",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(width: 4.w),

          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    ),
  ],
),

              const SizedBox(height: 22),

              /// Customer List
              Expanded(
                child: ListView.separated(
                  itemCount: customers.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    if (index == customers.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            "You've reached the end of the list",
                            style: TextStyle(
                              color: Color(0xff6b7280),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }

                    final customer = customers[index];

                    return CustomerCard(
                      name: customer['name']!,
                      phone: customer['phone']!,
                      initials: customer['initials']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
