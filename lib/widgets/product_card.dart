import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap, onEdit, onDelete;
  final ValueChanged<bool> onToggleStock;
  const ProductCard({super.key, required this.product, required this.onTap, required this.onEdit, required this.onDelete, required this.onToggleStock});

  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12.r), onTap: onTap,
    child: Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(11.r), topRight: Radius.circular(11.r)), child: AspectRatio(aspectRatio: 1.2, child: _img(product.primaryImageUrl))),
        Positioned(top: 8.h, left: 8.w, child: _stockBadge(product.inStock)),
        if (product.prescriptionRequired) Positioned(top: 8.h, right: 8.w, child: _rxBadge()),
        if (product.imageUrls.length > 1) Positioned(bottom: 6.h, right: 8.w, child: _photoBadge()),
      ]),
      Expanded(child: Padding(padding: EdgeInsets.all(12.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (product.category.isNotEmpty) Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4.r)), child: Text(product.category, style: TextStyle(fontSize: 10.sp, color: AppColors.primary, fontWeight: FontWeight.w600))),
        SizedBox(height: 6.h),
        Text(product.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
        if (product.brand.isNotEmpty) Text(product.brand, style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
        const Spacer(),
        Row(children: [
          Text('₹${product.discountedPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          if (product.discountPercentage > 0) ...[
            SizedBox(width: 6.w), Text('₹${product.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary, decoration: TextDecoration.lineThrough)),
            SizedBox(width: 4.w), Container(padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h), decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(3.r)), child: Text('-${product.discountPercentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 9.sp, color: AppColors.success, fontWeight: FontWeight.w700))),
          ],
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          GestureDetector(onTap: () => onToggleStock(!product.inStock), child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(color: product.inStock ? AppColors.successLight : AppColors.errorLight, borderRadius: BorderRadius.circular(6.r)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 12.sp, color: product.inStock ? AppColors.success : AppColors.error),
              SizedBox(width: 4.w), Text(product.inStock ? 'In Stock' : 'Out', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: product.inStock ? AppColors.success : AppColors.error)),
            ]))),
          const Spacer(),
          _iconBtn(icon: Icons.edit_outlined, color: AppColors.info, onTap: onEdit),
          SizedBox(width: 4.w),
          _iconBtn(icon: Icons.delete_outline_rounded, color: AppColors.error, onTap: onDelete),
        ]),
      ]))),
    ]))));

  Widget _img(String? url) => url != null
    ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, placeholder: (_, __) => _placeholder(), errorWidget: (_, __, ___) => _placeholder())
    : _placeholder();

  Widget _placeholder() => Container(color: AppColors.surfaceVariant, child: Center(child: Icon(Icons.medication_outlined, size: 40.sp, color: AppColors.textTertiary)));
  Widget _stockBadge(bool inStock) => Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: inStock ? AppColors.successLight : AppColors.errorLight, borderRadius: BorderRadius.circular(6.r)), child: Text(inStock ? 'In Stock' : 'Out of Stock', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: inStock ? AppColors.success : AppColors.error)));
  Widget _rxBadge() => Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: AppColors.warning.withOpacity(0.3))), child: Text('Rx', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.warning)));
  Widget _photoBadge() => Container(padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4.r)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.photo_library_rounded, size: 10.sp, color: Colors.white), SizedBox(width: 3.w), Text('${product.imageUrls.length}', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600))]));
  Widget _iconBtn({required IconData icon, required Color color, required VoidCallback onTap}) => Material(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6.r), child: InkWell(borderRadius: BorderRadius.circular(6.r), onTap: onTap, child: Padding(padding: EdgeInsets.all(6.w), child: Icon(icon, size: 16.sp, color: color))));
}

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap, onEdit, onDelete;
  final ValueChanged<bool> onToggleStock;
  const ProductListTile({super.key, required this.product, required this.onTap, required this.onEdit, required this.onDelete, required this.onToggleStock});

  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12.r), onTap: onTap,
    child: Container(padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(8.r), child: SizedBox(width: 64.w, height: 64.w, child: product.primaryImageUrl != null
          ? CachedNetworkImage(imageUrl: product.primaryImageUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => _imgPlaceholder())
          : _imgPlaceholder())),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(product.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
            Container(padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h), decoration: BoxDecoration(color: product.inStock ? AppColors.successLight : AppColors.errorLight, borderRadius: BorderRadius.circular(6.r)), child: Text(product.inStock ? 'In Stock' : 'Out', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600, color: product.inStock ? AppColors.success : AppColors.error))),
          ]),
          SizedBox(height: 4.h),
          Text('${product.brand} • ${product.category}', style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary), overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Text('₹${product.discountedPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ])),
        SizedBox(width: 10.w),
        Column(children: [
          _iconBtn(icon: Icons.edit_outlined, color: AppColors.info, onTap: onEdit),
          SizedBox(height: 6.h),
          _iconBtn(icon: Icons.delete_outline_rounded, color: AppColors.error, onTap: onDelete),
        ]),
      ]))));

  Widget _imgPlaceholder() => Container(color: AppColors.surfaceVariant, child: Icon(Icons.medication_outlined, color: AppColors.textTertiary, size: 28.sp));
  Widget _iconBtn({required IconData icon, required Color color, required VoidCallback onTap}) => Material(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6.r), child: InkWell(borderRadius: BorderRadius.circular(6.r), onTap: onTap, child: Padding(padding: EdgeInsets.all(6.w), child: Icon(icon, size: 16.sp, color: color))));
}
