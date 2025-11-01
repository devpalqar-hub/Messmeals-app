import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TittleText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const TittleText({
    super.key,
    required this.text,
    this.size,
    this.color,
    this.fontWeight,
    this.fontFamily,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = fontFamily != null
        ? TextStyle(
            fontFamily: 'Inter',
            fontSize: size ?? 20,
            color: color ?? Color(0XFF1A1D29),
            fontWeight: fontWeight ?? FontWeight.w700,
          )
        : GoogleFonts.inter(
            fontSize: size ?? 20,
            color: color ?? Color(0XFF1A1D29),
            fontWeight: fontWeight ?? FontWeight.w700,
          );

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign ?? TextAlign.start,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
