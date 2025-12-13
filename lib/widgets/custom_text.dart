import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/theme.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? color;
  final double fontSize;
  final bool isBold;
  final bool isSemiBold;
  final bool isMedium;
  final bool isLight;
  final bool isItalic;
  final String fontFamily;
  final FontWeight? fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final EdgeInsetsGeometry? padding;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextStyle? style;
  final bool underline;
  final bool disabled;
  final double? lineHeight;

  const CustomText({
  super.key,
   this.text,
    this.onTap,
    this.width,
    this.height,
    this.color,
    this.fontSize = 14,
    this.isBold = false,
    this.isSemiBold = false,
    this.isMedium = false,
    this.isLight = false,
    this.isItalic = false,
    this.fontFamily = "Gilroy",
    this.fontWeight,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.padding,
    this.decoration,
    this.decorationColor,
    this.letterSpacing,
    this.wordSpacing,
    this.style,
    this.underline = false,
    this.disabled = false,
    this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    FontWeight resolvedWeight = fontWeight ??
        (isBold
            ? FontWeight.w700
            : isSemiBold
                ? FontWeight.w600
                : isMedium
                    ? FontWeight.w500
                    : isLight
                        ? FontWeight.w300
                        : FontWeight.w400);

    final textWidget = Text(
      text ?? "",
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style ??
          TextStyle(
            color: disabled ? AppColors.grayColor : color ?? AppColors.primary500,
            fontSize: ScallingConfig.moderateScale(fontSize),
            fontWeight: resolvedWeight,
            fontFamily: fontFamily,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: underline
                ? TextDecoration.underline
                : (decoration ?? TextDecoration.none),
            decorationColor: decorationColor ?? color,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            height: lineHeight,
          ),
    );

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: textWidget,
        ),
      ),
    );
  }
}
