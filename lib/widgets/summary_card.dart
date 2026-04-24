import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;
  final Color? badgeColor;
  final bool isHighlight;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
    this.badgeColor,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBadgeColor = badgeColor ?? color;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isHighlight ? color : AppConstants.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32.r),
        border: isHighlight
            ? null
            : Border(bottom: BorderSide(color: color, width: 4.h)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F191B22),
            blurRadius: 48.r,
            offset: Offset(0, 24.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isHighlight
                      ? Colors.white.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon,
                    color: isHighlight ? Colors.white : color, size: 24.r),
              ),
              if (badge != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? Colors.white.withValues(alpha: 0.1)
                        : effectiveBadgeColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8.r),
                    border: isHighlight
                        ? null
                        : Border.all(
                            color: effectiveBadgeColor.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: isHighlight ? Colors.white : effectiveBadgeColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isHighlight
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppConstants.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color:
                        isHighlight ? Colors.white : AppConstants.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
