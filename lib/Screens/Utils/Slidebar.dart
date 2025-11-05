import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class VerticalSideSlider extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final Function(double) onChanged;

  const VerticalSideSlider({
    super.key,
    this.initialValue = 0,
    this.min = 0,
    this.max = 100,
    required this.onChanged,
  });

  @override
  State<VerticalSideSlider> createState() => _VerticalSideSliderState();
}

class _VerticalSideSliderState extends State<VerticalSideSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      height: double.infinity,
      width: 60.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          bottomLeft: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4.h,
                activeTrackColor: primaryColor,
                inactiveTrackColor: Colors.grey.shade300,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                valueIndicatorColor: primaryColor,
                valueIndicatorTextStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              ),
              child: Slider(
                min: widget.min,
                max: widget.max,
                value: _currentValue,
                divisions: (widget.max - widget.min).toInt(),
                label: _currentValue.toInt().toString(),
                onChanged: (val) {
                  setState(() => _currentValue = val);
                  widget.onChanged(val);
                },
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            _currentValue.toInt().toString(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
