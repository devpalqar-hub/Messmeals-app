import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class WalletWidget extends StatelessWidget {
  final TextEditingController walletController;
  final TextEditingController discountController;

  const WalletWidget({
    super.key,
    required this.walletController,
    required this.discountController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                height: 45.h,
                width: 45.w,
                decoration: BoxDecoration(
                  color: const Color(0xffFFF3E0),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.orange,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wallet & Discounts",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    const Text(
                      "Manage initial wallet balance and discounts",
                      style: TextStyle(color: Color(0xff6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),

          /// WALLET SECTION
          Container(
            width: double.infinity,
            //   padding: EdgeInsets.all(18.w),
            // decoration: BoxDecoration(
            //   color: const Color(0xffF2F5F5),
            //   borderRadius: BorderRadius.circular(16.r),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Wallet Amount",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                amountField(walletController),

                SizedBox(height: 20.h),

                Text(
                  "Discount Amount",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                amountField(discountController),
              ],
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget amountField(TextEditingController controller) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            "₹",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "0.00",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
