import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/responsive.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 52,
    this.borderRadius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveHeight = ResponsiveHelper.getResponsiveHeight(context, height);
    final responsiveBorderRadius = ResponsiveHelper.getResponsiveRadius(context, borderRadius);
    final responsiveWidth = width != null 
        ? ResponsiveHelper.getResponsiveWidth(context, width!)
        : null;
    
    return SizedBox(
      width: responsiveWidth ?? double.infinity,
      height: responsiveHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor ?? AppColors.black,
                side: BorderSide(
                  color: backgroundColor ?? AppColors.black,
                  width: ResponsiveHelper.getResponsiveWidth(context, 2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsiveBorderRadius),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: ResponsiveHelper.getResponsiveIconSize(context, 20),
                      height: ResponsiveHelper.getResponsiveIconSize(context, 20),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      ),
                    ),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppColors.black,
                foregroundColor: textColor ?? AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsiveBorderRadius),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: ResponsiveHelper.getResponsiveIconSize(context, 20),
                      height: ResponsiveHelper.getResponsiveIconSize(context, 20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
    );
  }
}
