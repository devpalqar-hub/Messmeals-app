import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletStatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? actionText;
  final String? preButtonText;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool isPrimary;

  const WalletStatusCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.actionText,
    this.preButtonText,
    this.onAction,
    this.padding = const EdgeInsets.all(14),
    this.radius = 14,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFF717182),
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 12,
      letterSpacing: 0.3,
      height: 1.1,
    );

    const valueStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontFamily: 'Inter',
      color: Colors.black,
      height: 1.1,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
            
              Container(
                padding:  EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              const SizedBox(width: 16),

           
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    ),

                    
                    if (isPrimary)
                      Text(
                        value,
                        style: valueStyle,
                        textAlign: TextAlign.right,
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (isPrimary && (preButtonText != null || actionText != null)) ...[
             SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (preButtonText != null)
                  Flexible(
                    child: Text(
                      preButtonText!.toUpperCase(),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                  ),
                 SizedBox(width: 10.w),
                if (actionText != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 34.h),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding:
                             EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: onAction,
                      child: Text(
                        actionText!,
                        style:  TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          if (!isPrimary) ...[
             SizedBox(height: 10.h),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          ],
        ],
      ),
    );
  }
}
