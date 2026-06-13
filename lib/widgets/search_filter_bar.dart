import 'package:avighn_medicare/blocs/products/products_cubit.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchFilterBar extends StatefulWidget {
  final String viewMode;
  final ValueChanged<String> onViewModeChanged;
  final List<String> categories;
  const SearchFilterBar({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.categories,
  });
  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _ctrl = TextEditingController();
  String _cat = '', _stock = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    final isNarrow = w < 400;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: isMobile
          ? Column(
              children: [
                _search(),
                const SizedBox(height: 10),
                isNarrow
                    ? Column(
                        children: [
                          _catDrop(),
                          const SizedBox(height: 8),
                          _stockDrop(),
                          if (_cat.isNotEmpty || _stock.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _clearBtn(),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _catDrop()),
                          const SizedBox(width: 10),
                          Expanded(child: _stockDrop()),
                          if (_cat.isNotEmpty || _stock.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _clearBtn(),
                          ],
                        ],
                      ),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _search()),
                  const SizedBox(width: 10),
                  Expanded(child: _catDrop()),
                  const SizedBox(width: 10),
                  Expanded(child: _stockDrop()),
                  if (_cat.isNotEmpty || _stock.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _clearBtn(),
                  ],
                  const SizedBox(width: 10),
                  _viewToggle(),
                ],
              ),
            ),
    );
  }

  Widget _search() => SizedBox(
    height: 42,
    child: TextField(
      controller: _ctrl,
      onChanged: (q) => context.read<ProductsCubit>().search(q),
      decoration: InputDecoration(
        hintText: 'Search products, brands...',
        prefixIcon: const Icon(Icons.search_rounded, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                onPressed: () {
                  _ctrl.clear();
                  context.read<ProductsCubit>().search('');
                  setState(() {});
                },
              )
            : null,
      ),
    ),
  );

  Widget _catDrop() => SizedBox(
    height: 42,
    child: DropdownButtonFormField<String>(
      initialValue: _cat.isEmpty ? null : _cat,
      hint: const Text('Category', style: TextStyle(fontSize: 12)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
      ),
      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
      isExpanded: true,
      items: [
        const DropdownMenuItem(value: '', child: Text('All Categories')),
        ...widget.categories.map(
          (c) => DropdownMenuItem(
            value: c,
            child: Text(c, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (v) {
        setState(() => _cat = v ?? '');
        context.read<ProductsCubit>().filterByCategory(_cat);
      },
    ),
  );

  Widget _stockDrop() => SizedBox(
    height: 42,
    child: DropdownButtonFormField<String>(
      initialValue: _stock.isEmpty ? null : _stock,
      hint: const Text('Stock', style: TextStyle(fontSize: 12)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
      ),
      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
      isExpanded: true,
      items: const [
        DropdownMenuItem(value: '', child: Text('All Stock')),
        DropdownMenuItem(value: 'inStock', child: Text('In Stock')),
        DropdownMenuItem(value: 'outOfStock', child: Text('Out of Stock')),
      ],
      onChanged: (v) {
        setState(() => _stock = v ?? '');
        context.read<ProductsCubit>().filterByStock(_stock);
      },
    ),
  );

  Widget _clearBtn() => TextButton.icon(
    onPressed: () {
      setState(() {
        _cat = '';
        _stock = '';
        _ctrl.clear();
      });
      context.read<ProductsCubit>().clearFilters();
    },
    icon: const Icon(Icons.filter_alt_off_rounded, size: 14),
    label: const Text('Clear', style: TextStyle(fontSize: 12)),
    style: TextButton.styleFrom(
      foregroundColor: AppColors.textSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 10),
    ),
  );

  Widget _viewToggle() => Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VBtn(
          icon: Icons.grid_view_rounded,
          active: widget.viewMode == 'grid',
          onTap: () => widget.onViewModeChanged('grid'),
        ),
        _VBtn(
          icon: Icons.view_list_rounded,
          active: widget.viewMode == 'list',
          onTap: () => widget.onViewModeChanged('list'),
        ),
      ],
    ),
  );
}

class _VBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _VBtn({required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(
        icon,
        size: 18,
        color: active ? Colors.white : AppColors.textTertiary,
      ),
    ),
  );
}
