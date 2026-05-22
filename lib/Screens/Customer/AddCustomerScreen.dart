import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mess/Screens/Customer/Views/Basicinfowiget.dart';
import 'package:mess/Screens/Customer/Views/PlanWalletwidget.dart';
import 'package:mess/Screens/Customer/Views/Reviewwidget.dart';
import 'package:mess/Screens/Customer/Views/ScheduleDelivery.dart';
import 'package:mess/Screens/Utils/AppBar.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/step.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}
class _AddCustomerScreenState
    extends State<AddCustomerScreen> {

  int currentStep = 1;

   final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController locationController =
      TextEditingController();




   @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [

              SizedBox(height: 10.h),

              const CustomAppBar(
                title: "Add Customer",
              ),

              SizedBox(height: 28.h),

              /// STEP INDICATOR (fixed)
              Row(
                children: [
                  StepWidget(
                    number: "1",
                    title: "Basic Info",
                    active: currentStep >= 1,
                  ),

                  StepLine(
                    active: currentStep > 1,
                  ),

                  StepWidget(
                    number: "2",
                    title: "Plan & Wallet",
                    active: currentStep >= 2,
                  ),

                  StepLine(
                    active: currentStep > 2,
                  ),

                  StepWidget(
                    number: "3",
                    title: "Schedule",
                    active: currentStep >= 3,
                  ),

                  StepLine(
                    active: currentStep > 3,
                  ),

                  StepWidget(
                    number: "4",
                    title: "Review",
                    active: currentStep >= 4,
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              /// ONLY THIS CHANGES
              Expanded(
                child: IndexedStack(
                  index: currentStep - 1,
                  children: [
                     BasicInfoWidget(
                      nameController:
                          nameController,

                      phoneController:
                          phoneController,

                      emailController:
                          emailController,

                      addressController:
                          addressController,

                      locationController:
                          locationController,
                    ),
                    PlanWalletWidget(),
                    ScheduleDeliveryWidget(),
                    ReviewWidget(),
                  ],
                ),
              ),

              Container(
  width: double.infinity,
  height: 50.h,
  margin: EdgeInsets.only(bottom: 14.h),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14.r),
      ),
    ),

    onPressed: () {

      if (currentStep < 4) {
        setState(() {
          currentStep++;
        });
      } else {

        /// Add customer API call here
        print("Add Customer clicked");
      }
    },

    child: Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [

        Text(
          currentStep == 4
              ? "Add Customer"
              : "Continue",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(width: 8.w),

        Icon(
          currentStep == 4
              ? Icons.check
              : Icons.arrow_forward,
          color: Colors.white,
          size: 20.sp,
        ),
      ],
    ),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}