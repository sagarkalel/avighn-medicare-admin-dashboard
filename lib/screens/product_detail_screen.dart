import 'package:avighn_medicare/blocs/products/products_cubit.dart';
import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imgIdx = 0;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProductsCubit, ProductsState>(
        builder: (ctx, s) {
          if (s is! ProductsLoaded)
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          final matches = s.products
              .where((p) => p.id == widget.productId)
              .toList();
          if (matches.isEmpty)
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 56,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Product not found',
                      style: Theme.of(ctx).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ctx.go('/products'),
                      child: const Text('Back to Products'),
                    ),
                  ],
                ),
              ),
            );
          final p = matches.first;
          final wide = MediaQuery.of(context).size.width > 900;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 340, child: _images(p)),
                        const SizedBox(width: 20),
                        Expanded(child: _details(ctx, p)),
                      ],
                    )
                  : Column(
                      children: [
                        _images(p),
                        const SizedBox(height: 16),
                        _details(ctx, p),
                      ],
                    ),
            ),
          );
        },
      );

  Widget _images(Product p) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AspectRatio(
        aspectRatio: 1.1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: p.imageUrls.isNotEmpty && _imgIdx < p.imageUrls.length
              ? CachedNetworkImage(
                  imageUrl: p.imageUrls[_imgIdx],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 56,
                      color: AppColors.textTertiary,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.medication_outlined,
                    size: 80,
                    color: AppColors.textTertiary,
                  ),
                ),
        ),
      ).animate().fadeIn().scale(
        begin: const Offset(0.97, 0.97),
        end: const Offset(1, 1),
      ),
      if (p.imageUrls.length > 1) ...[
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: p.imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _imgIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: i == _imgIdx ? AppColors.primary : AppColors.border,
                    width: i == _imgIdx ? 2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: p.imageUrls[i],
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ],
  );

  Widget _details(BuildContext ctx, Product p) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Name + action buttons — wrap on narrow screens
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                p.category,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(p.name, style: Theme.of(ctx).textTheme.headlineMedium),
          if (p.brand.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              p.brand,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Action buttons as Wrap so they don't overflow
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => ctx.go('/products/${p.id}/edit'),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    ctx.read<ProductsCubit>().toggleStock(p.id, !p.inStock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.inStock
                      ? AppColors.error
                      : AppColors.success,
                ),
                icon: Icon(
                  p.inStock
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  size: 16,
                ),
                label: Text(p.inStock ? 'Mark Out' : 'Mark In'),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _badge(
            label: p.inStock ? 'In Stock' : 'Out of Stock',
            color: p.inStock ? AppColors.success : AppColors.error,
            bg: p.inStock ? AppColors.successLight : AppColors.errorLight,
            icon: p.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
          ),
          if (p.prescriptionRequired)
            _badge(
              label: 'Prescription Required',
              color: AppColors.warning,
              bg: AppColors.warningLight,
              icon: Icons.assignment_outlined,
            ),
        ],
      ).animate().fadeIn(delay: 150.ms),
      const SizedBox(height: 16),
      _infoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${p.discountedPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (p.discountPercentage > 0)
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '₹${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${p.discountPercentage.toStringAsFixed(0)}% OFF',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 16),
      if (p.description.isNotEmpty) ...[
        _infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 250.ms),
        const SizedBox(height: 16),
      ],
      if (p.dosage.isNotEmpty || p.uses.isNotEmpty) ...[
        _infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medical Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (p.dosage.isNotEmpty) _row('Dosage', p.dosage),
              if (p.uses.isNotEmpty) _row('Uses', p.uses),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 16),
      ],
      _infoCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product ID',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    p.id,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
              tooltip: 'Copy ID',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: p.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product ID copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ).animate().fadeIn(delay: 350.ms),
      const SizedBox(height: 24),
    ],
  );

  Widget _badge({
    required String label,
    required Color color,
    required Color bg,
    required IconData icon,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _infoCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    ),
  );
}
