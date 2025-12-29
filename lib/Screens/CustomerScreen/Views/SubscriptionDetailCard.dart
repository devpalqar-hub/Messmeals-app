import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionDetailsCard extends StatelessWidget {
  final String currentPlan;
  final String planPrice;
  final String startDate;
  final String endDate;
  final String? endNote; 
  final List<String> variationTitles;
  final VoidCallback onRenew;
  final VoidCallback onCancel;
  final VoidCallback onPause;
  final String activeSubscriptionId;
  final String customerProfileId;

   SubscriptionDetailsCard({
    super.key,
    required this.currentPlan,
    required this.planPrice,
    required this.startDate,
    required this.endDate,
    this.endNote,
    required this.variationTitles,
    required this.onRenew,
    required this.onCancel,
    required this.onPause, 
    required this.activeSubscriptionId,
    required this.customerProfileId,
  });

  @override
  Widget build(BuildContext context) {
    const captionStyle = TextStyle(
      color: Color(0xFF717182),
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: 12,
      letterSpacing: 0.4,
    );

    const valueStyle = TextStyle(
      color: Colors.black,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.2,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Subscription Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),

           SizedBox(height: 18.h),

          // Row 1: Current plan | Plan price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledValue(
                  caption: 'CURRENT PLAN',
                  value: currentPlan,
                  captionStyle: captionStyle,
                  valueStyle: valueStyle,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _LabeledValue(
                  caption: 'PLAN PRICE',
                  value: planPrice,
                  captionStyle: captionStyle,
                  valueStyle: valueStyle,
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // Row 2: Start date | End date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledValue(
                  caption: 'START DATE',
                  value: startDate,
                  captionStyle: captionStyle,
                  valueStyle: valueStyle,
                ),
              ),
               SizedBox(width: 16.w),
              Expanded(
                child: _LabeledValue(
                  caption: 'END DATE',
                  value: endDate,
                  subtitle: endNote,
                  captionStyle: captionStyle,
                  valueStyle: valueStyle,
                  subtitleStyle:  TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),

           Divider(height: 28.h, color: Color(0xFFE5E5EA)),

           Text('PLAN VARIATIONS', style: captionStyle),
           SizedBox(height: 10.h),

          if (variationTitles.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: variationTitles
                  .map(
                    (title) => Container(
                      padding:  EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        title,
                        style:  TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            const Text(
              'No variations found',
              style: TextStyle(color: Colors.grey),
            ),

           SizedBox(height: 18.h),

          // ✅ Renew Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: onRenew,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0474B9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                textStyle:  TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              child: const Text('Renew Subscription'),
            ),
          ),

           SizedBox(height: 12.h),

          // ✅ Pause Button (new)
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: onPause,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0474B9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                foregroundColor: const Color(0xFF0474B9),
                backgroundColor: const Color(0xFFE9F6FF),
                textStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              child: const Text('Pause Subscription'),
            ),
          ),

          SizedBox(height: 12.h),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE8E8EE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                foregroundColor: const Color(0xFFDF3B2F),
                textStyle:  TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text('Cancel Subscription'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  final String caption;
  final String value;
  final String? subtitle;
  final TextStyle captionStyle;
  final TextStyle valueStyle;
  final TextStyle? subtitleStyle;

  const _LabeledValue({
    required this.caption,
    required this.value,
    this.subtitle,
    required this.captionStyle,
    required this.valueStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: captionStyle),
         SizedBox(height: 6.h),
        Text(value, style: valueStyle),
        if (subtitle != null) ...[
         SizedBox(height: 4.h),
          Text(subtitle!, style: subtitleStyle),
        ],
      ],
    );
  }
}
