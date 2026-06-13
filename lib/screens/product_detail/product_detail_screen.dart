import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:avighn_medicare/blocs/products/products_cubit.dart';
import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imgIdx = 0;

  @override
  Widget build(BuildContext context) => BlocBuilder<ProductsCubit, ProductsState>(
    builder: (ctx, s) {
      if (s is! ProductsLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final matches = s.products.where((p) => p.id == widget.productId).toList();
      if (matches.isEmpty) return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.medication_outlined, size: 56.sp, color: AppColors.textTertiary),
        SizedBox(height: 16.h),
        Text('Product not found', style: Theme.of(ctx).textTheme.headlineSmall),
        SizedBox(height: 16.h),
        ElevatedButton(onPressed: () => ctx.go('/products'), child: const Text('Back to Products')),
      ])));
      final p = matches.first;
      final wide = MediaQuery.of(context).size.width > 900;
      return Scaffold(backgroundColor: AppColors.background, body: SingleChildScrollView(padding: EdgeInsets.all(24.w),
        child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 360.w, child: _images(p)), SizedBox(width: 24.w), Expanded(child: _details(ctx, p))])
          : Column(children: [_images(p), SizedBox(height: 20.h), _details(ctx, p)])));
    });

  Widget _images(Product p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: double.infinity, height: 300.h, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppColors.border)), clipBehavior: Clip.antiAlias,
      child: p.imageUrls.isNotEmpty && _imgIdx < p.imageUrls.length
        ? CachedNetworkImage(imageUrl: p.imageUrls[_imgIdx], fit: BoxFit.contain, placeholder: (_, __) => Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)), errorWidget: (_, __, ___) => Center(child: Icon(Icons.broken_image_outlined, size: 56.sp, color: AppColors.textTertiary)))
        : Center(child: Icon(Icons.medication_outlined, size: 80.sp, color: AppColors.textTertiary)))
      .animate().fadeIn().scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
    if (p.imageUrls.length > 1) ...[
      SizedBox(height: 12.h),
      SizedBox(height: 64.h, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: p.imageUrls.length, separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) => GestureDetector(onTap: () => setState(() => _imgIdx = i), child: AnimatedContainer(duration: const Duration(milliseconds: 150),
          width: 64.w, height: 64.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: i == _imgIdx ? AppColors.primary : AppColors.border, width: i == _imgIdx ? 2 : 1)), clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(imageUrl: p.imageUrls[i], fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: AppColors.surfaceVariant, child: Icon(Icons.image_outlined, size: 20.sp, color: AppColors.textTertiary)))))),
      ),
    ],
  ]);

  Widget _details(BuildContext ctx, Product p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (p.category.isNotEmpty) Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6.r)), child: Text(p.category, style: TextStyle(fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.w600))),
        SizedBox(height: 8.h),
        Text(p.name, style: Theme.of(ctx).textTheme.headlineMedium),
        if (p.brand.isNotEmpty) ...[SizedBox(height: 4.h), Text(p.brand, style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary))],
      ])),
      SizedBox(width: 16.w),
      Row(children: [
        OutlinedButton.icon(onPressed: () => ctx.go('/products/${p.id}/edit'), icon: Icon(Icons.edit_outlined, size: 16.sp), label: const Text('Edit')),
        SizedBox(width: 8.w),
        ElevatedButton.icon(
          onPressed: () => ctx.read<ProductsCubit>().toggleStock(p.id, !p.inStock),
          style: ElevatedButton.styleFrom(backgroundColor: p.inStock ? AppColors.error : AppColors.success),
          icon: Icon(p.inStock ? Icons.remove_circle_outline : Icons.add_circle_outline, size: 16.sp),
          label: Text(p.inStock ? 'Mark Out' : 'Mark In')),
      ]),
    ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
    SizedBox(height: 20.h),
    Wrap(spacing: 8.w, runSpacing: 8.h, children: [
      _badge(label: p.inStock ? 'In Stock' : 'Out of Stock', color: p.inStock ? AppColors.success : AppColors.error, bg: p.inStock ? AppColors.successLight : AppColors.errorLight, icon: p.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded),
      if (p.prescriptionRequired) _badge(label: 'Prescription Required', color: AppColors.warning, bg: AppColors.warningLight, icon: Icons.assignment_outlined),
    ]).animate().fadeIn(delay: 150.ms),
    SizedBox(height: 20.h),
    _infoCard(child: Row(children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('₹${p.discountedPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      if (p.discountPercentage > 0) Row(children: [
        Text('₹${p.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary, decoration: TextDecoration.lineThrough)), SizedBox(width: 8.w),
        Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h), decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6.r)), child: Text('${p.discountPercentage.toStringAsFixed(0)}% OFF', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.success))),
      ]),
    ])])).animate().fadeIn(delay: 200.ms),
    SizedBox(height: 16.h),
    if (p.description.isNotEmpty) ...[_infoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Description', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), SizedBox(height: 8.h), Text(p.description, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.6))])).animate().fadeIn(delay: 250.ms), SizedBox(height: 16.h)],
    if (p.dosage.isNotEmpty || p.uses.isNotEmpty) ...[_infoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Medical Details', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), SizedBox(height: 12.h), if (p.dosage.isNotEmpty) _row('Dosage', p.dosage), if (p.uses.isNotEmpty) _row('Uses', p.uses)])).animate().fadeIn(delay: 300.ms), SizedBox(height: 16.h)],
    _infoCard(child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Product ID', style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary)), Text(p.id, style: TextStyle(fontSize: 12.sp, fontFamily: 'monospace', color: AppColors.textSecondary))])),
      IconButton(icon: Icon(Icons.copy_rounded, size: 16.sp, color: AppColors.textTertiary), tooltip: 'Copy ID', onPressed: () { Clipboard.setData(ClipboardData(text: p.id)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product ID copied'), duration: Duration(seconds: 1))); }),
    ])).animate().fadeIn(delay: 350.ms),
  ]);

  Widget _badge({required String label, required Color color, required Color bg, required IconData icon}) =>
    Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14.sp, color: color), SizedBox(width: 6.w), Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: color))]));

  Widget _infoCard({required Widget child}) => Container(width: double.infinity, padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)), child: child);

  Widget _row(String label, String value) => Padding(padding: EdgeInsets.only(bottom: 10.h), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 80.w, child: Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary, fontWeight: FontWeight.w500))),
    SizedBox(width: 12.w), Expanded(child: Text(value, style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary))),
  ]));
}
