import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avighn_medicare/blocs/products/products_cubit.dart';
import 'package:avighn_medicare/theme/app_theme.dart';

class SearchFilterBar extends StatefulWidget {
  final String viewMode;
  final ValueChanged<String> onViewModeChanged;
  final List<String> categories;
  const SearchFilterBar({super.key, required this.viewMode, required this.onViewModeChanged, required this.categories});
  @override State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _ctrl = TextEditingController();
  String _cat = '', _stock = '';
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: isMobile ? Column(children: [_search(), SizedBox(height: 10.h), Row(children: [Expanded(child: _catDrop()), SizedBox(width: 10.w), Expanded(child: _stockDrop()), if (_cat.isNotEmpty || _stock.isNotEmpty) ...[SizedBox(width: 10.w), _clearBtn()]])])
        : Container(padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)),
            child: Row(children: [Expanded(flex: 3, child: _search()), SizedBox(width: 12.w), Expanded(child: _catDrop()), SizedBox(width: 12.w), Expanded(child: _stockDrop()), if (_cat.isNotEmpty || _stock.isNotEmpty) ...[SizedBox(width: 12.w), _clearBtn()], SizedBox(width: 12.w), _viewToggle()])));
  }

  Widget _search() => SizedBox(height: 42.h, child: TextField(controller: _ctrl, onChanged: (q) => context.read<ProductsCubit>().search(q),
    decoration: InputDecoration(hintText: 'Search products, brands...', prefixIcon: Icon(Icons.search_rounded, size: 18.sp), contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      filled: true, fillColor: AppColors.surfaceVariant,
      suffixIcon: _ctrl.text.isNotEmpty ? IconButton(icon: Icon(Icons.close_rounded, size: 16.sp), onPressed: () { _ctrl.clear(); context.read<ProductsCubit>().search(''); setState(() {}); }) : null,
    )));

  Widget _catDrop() => SizedBox(height: 42.h, child: DropdownButtonFormField<String>(
    value: _cat.isEmpty ? null : _cat, hint: Text('Category', style: TextStyle(fontSize: 12.sp)),
    decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12.w), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.border)), filled: true, fillColor: AppColors.surfaceVariant),
    style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary), isExpanded: true,
    items: [const DropdownMenuItem(value: '', child: Text('All Categories')), ...widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
    onChanged: (v) { setState(() => _cat = v ?? ''); context.read<ProductsCubit>().filterByCategory(_cat); },
  ));

  Widget _stockDrop() => SizedBox(height: 42.h, child: DropdownButtonFormField<String>(
    value: _stock.isEmpty ? null : _stock, hint: Text('Stock', style: TextStyle(fontSize: 12.sp)),
    decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12.w), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.border)), filled: true, fillColor: AppColors.surfaceVariant),
    style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary), isExpanded: true,
    items: const [DropdownMenuItem(value: '', child: Text('All Stock')), DropdownMenuItem(value: 'inStock', child: Text('In Stock')), DropdownMenuItem(value: 'outOfStock', child: Text('Out of Stock'))],
    onChanged: (v) { setState(() => _stock = v ?? ''); context.read<ProductsCubit>().filterByStock(_stock); },
  ));

  Widget _clearBtn() => TextButton.icon(onPressed: () { setState(() { _cat = ''; _stock = ''; _ctrl.clear(); }); context.read<ProductsCubit>().clearFilters(); },
    icon: Icon(Icons.filter_alt_off_rounded, size: 14.sp), label: Text('Clear', style: TextStyle(fontSize: 12.sp)),
    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: EdgeInsets.symmetric(horizontal: 10.w)));

  Widget _viewToggle() => Container(decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: AppColors.border)), child: Row(mainAxisSize: MainAxisSize.min, children: [
    _VBtn(icon: Icons.grid_view_rounded, active: widget.viewMode == 'grid', onTap: () => widget.onViewModeChanged('grid')),
    _VBtn(icon: Icons.view_list_rounded, active: widget.viewMode == 'list', onTap: () => widget.onViewModeChanged('list')),
  ]));
}

class _VBtn extends StatelessWidget {
  final IconData icon; final bool active; final VoidCallback onTap;
  const _VBtn({required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext ctx) => GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: EdgeInsets.all(8.w),
    decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(7.r)),
    child: Icon(icon, size: 18.sp, color: active ? Colors.white : AppColors.textTertiary)));
}
