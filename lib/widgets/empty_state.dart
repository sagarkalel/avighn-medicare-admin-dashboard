import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:avighn_medicare/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext ctx) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 80.w, height: 80.w, decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle), child: Icon(icon, size: 36.sp, color: AppColors.textTertiary))
      .animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
    SizedBox(height: 20.h),
    Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)).animate().fadeIn(delay: 100.ms),
    SizedBox(height: 8.h),
    SizedBox(width: 320.w, child: Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary, height: 1.5))).animate().fadeIn(delay: 200.ms),
    if (actionLabel != null && onAction != null) ...[
      SizedBox(height: 24.h),
      ElevatedButton.icon(onPressed: onAction, icon: const Icon(Icons.add_rounded), label: Text(actionLabel!)).animate().fadeIn(delay: 300.ms),
    ],
  ]));
}

class LoadingGrid extends StatelessWidget {
  const LoadingGrid({super.key});
  @override
  Widget build(BuildContext ctx) => Padding(padding: EdgeInsets.all(20.w), child: Shimmer.fromColors(baseColor: AppColors.border, highlightColor: AppColors.surfaceVariant,
    child: LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      int cols = w > 1100 ? 4 : w > 700 ? 3 : 2;
      return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 16.h, crossAxisSpacing: 16.w, childAspectRatio: 0.78),
        itemCount: 8, itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r))));
    })));
}
