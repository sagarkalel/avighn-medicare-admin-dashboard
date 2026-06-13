import 'package:avighn_medicare/blocs/products/products_cubit.dart';
import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:avighn_medicare/widgets/empty_state.dart';
import 'package:avighn_medicare/widgets/product_card.dart';
import 'package:avighn_medicare/widgets/search_filter_bar.dart';
import 'package:avighn_medicare/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _view = 'grid';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProductsCubit>().loadProducts(),
    );
  }

  @override
  Widget build(BuildContext ctx) => BlocConsumer<ProductsCubit, ProductsState>(
    listener: (ctx, s) {
      if (s is ProductsError)
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(s.message), backgroundColor: AppColors.error),
        );
    },
    builder: (ctx, s) => Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ctx.read<ProductsCubit>().loadProducts(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _stats(s)),
            SliverToBoxAdapter(
              child: SearchFilterBar(
                viewMode: _view,
                onViewModeChanged: (m) => setState(() => _view = m),
                categories: s is ProductsLoaded ? s.categories : [],
              ),
            ),
            if (s is ProductsLoading)
              const SliverToBoxAdapter(child: LoadingGrid())
            else if (s is ProductsLoaded) ...[
              if (s.products.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.medication_outlined,
                    title: 'No products found',
                    subtitle:
                        'Try adjusting search/filters, or add your first product.',
                    actionLabel: 'Add Product',
                    onAction: () => ctx.go('/products/add'),
                  ),
                )
              else if (_view == 'grid')
                _grid(s.products)
              else
                _list(s.products),
            ] else if (s is ProductsError)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Failed to load products',
                  subtitle: s.message,
                  actionLabel: 'Retry',
                  onAction: () => ctx.read<ProductsCubit>().loadProducts(),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _stats(ProductsState s) {
    final total = s is ProductsLoaded ? s.total : 0;
    final inStock = s is ProductsLoaded ? s.inStockCount : 0;
    final outOfStock = s is ProductsLoaded ? s.outOfStockCount : 0;
    final loading = s is ProductsLoading;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: LayoutBuilder(
        builder: (ctx, c) {
          final gap = 12.0;
          final cw = (c.maxWidth - gap * 2) / 3;
          // On very narrow screens, show stacked cards
          if (cw < 80) {
            return Column(
              children: [
                StatCard(
                  width: c.maxWidth,
                  label: 'Total Products',
                  value: total.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.info,
                  bgColor: AppColors.infoLight,
                  isLoading: loading,
                ),
                SizedBox(height: gap),
                StatCard(
                  width: c.maxWidth,
                  label: 'In Stock',
                  value: inStock.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  bgColor: AppColors.successLight,
                  isLoading: loading,
                ),
                SizedBox(height: gap),
                StatCard(
                  width: c.maxWidth,
                  label: 'Out of Stock',
                  value: outOfStock.toString(),
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                  bgColor: AppColors.errorLight,
                  isLoading: loading,
                ),
              ],
            );
          }
          return Row(
            children: [
              StatCard(
                width: cw,
                label: 'Total Products',
                value: total.toString(),
                icon: Icons.inventory_2_outlined,
                color: AppColors.info,
                bgColor: AppColors.infoLight,
                isLoading: loading,
              ),
              SizedBox(width: gap),
              StatCard(
                width: cw,
                label: 'In Stock',
                value: inStock.toString(),
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                bgColor: AppColors.successLight,
                isLoading: loading,
              ),
              SizedBox(width: gap),
              StatCard(
                width: cw,
                label: 'Out of Stock',
                value: outOfStock.toString(),
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                bgColor: AppColors.errorLight,
                isLoading: loading,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _grid(List<Product> products) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
    sliver: SliverLayoutBuilder(
      builder: (ctx, c) {
        final width = c.crossAxisExtent;
        int cols = width > 1100
            ? 4
            : width > 700
            ? 3
            : width > 400
            ? 2
            : 1;
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          delegate: SliverChildBuilderDelegate(
            (ctx, i) =>
                ProductCard(
                      product: products[i],
                      onTap: () => ctx.go('/products/${products[i].id}'),
                      onEdit: () => ctx.go('/products/${products[i].id}/edit'),
                      onDelete: () => _confirmDelete(products[i]),
                      onToggleStock: (v) => ctx
                          .read<ProductsCubit>()
                          .toggleStock(products[i].id, v),
                    )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: (i * 40).clamp(0, 300)),
                    )
                    .slideY(begin: 0.05, end: 0),
            childCount: products.length,
          ),
        );
      },
    ),
  );

  Widget _list(List<Product> products) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:
              ProductListTile(
                product: products[i],
                onTap: () => ctx.go('/products/${products[i].id}'),
                onEdit: () => ctx.go('/products/${products[i].id}/edit'),
                onDelete: () => _confirmDelete(products[i]),
                onToggleStock: (v) =>
                    ctx.read<ProductsCubit>().toggleStock(products[i].id, v),
              ).animate().fadeIn(
                delay: Duration(milliseconds: (i * 30).clamp(0, 250)),
              ),
        ),
        childCount: products.length,
      ),
    ),
  );

  void _confirmDelete(Product p) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Product'),
      content: Text('Delete "${p.name}"? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.read<ProductsCubit>().deleteProduct(p.id);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
