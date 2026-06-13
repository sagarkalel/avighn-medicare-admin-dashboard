import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:avighn_medicare/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final double width;
  final String label, value;
  final IconData icon;
  final Color color, bgColor;
  final bool isLoading;

  const StatCard({super.key, required this.width, required this.label, required this.value, required this.icon, required this.color, required this.bgColor, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return SizedBox(width: width, child: Shimmer.fromColors(baseColor: AppColors.border, highlightColor: AppColors.surfaceVariant,
      child: Container(height: 90.h, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r)))));
    return Container(width: width, padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(width: 40.w, height: 40.w, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10.r)), child: Icon(icon, size: 20.sp, color: color)),
        SizedBox(width: 12.w),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary)),
        ]),
      ]),
    );
  }
}
