import 'package:avighn_medicare/blocs/products/products_cubit.dart';
import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:avighn_medicare/utils/app_constants.dart';
import 'package:avighn_medicare/widgets/image_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;
  const AddEditProductScreen({super.key, this.productId});
  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false, _fetching = true;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _usesCtrl = TextEditingController();

  String _cat = AppConstants.productCategories.first;
  bool _rx = false, _inStock = true;
  List<String> _imageUrls = [];
  Product? _original;

  bool get isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    if (!isEdit) {
      setState(() => _fetching = false);
      return;
    }
    final s = context.read<ProductsCubit>().state;
    if (s is ProductsLoaded) {
      try {
        final p = s.products.firstWhere((p) => p.id == widget.productId);
        _original = p;
        _nameCtrl.text = p.name;
        _descCtrl.text = p.description;
        _priceCtrl.text = p.price > 0 ? p.price.toString() : '';
        _discountCtrl.text = p.discountPercentage > 0
            ? p.discountPercentage.toString()
            : '';
        _brandCtrl.text = p.brand;
        _dosageCtrl.text = p.dosage;
        _usesCtrl.text = p.uses;
        _cat = AppConstants.productCategories.contains(p.category)
            ? p.category
            : AppConstants.productCategories.first;
        _rx = p.prescriptionRequired;
        _inStock = p.inStock;
        _imageUrls = List.from(p.imageUrls);
      } catch (_) {}
    }
    setState(() => _fetching = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _brandCtrl.dispose();
    _dosageCtrl.dispose();
    _usesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final p = Product(
      id: isEdit
          ? _original!.id
          : 'product-${const Uuid().v4().substring(0, 8)}',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      discountPercentage: double.tryParse(_discountCtrl.text) ?? 0,
      brand: _brandCtrl.text.trim(),
      imageUrls: _imageUrls,
      category: _cat,
      dosage: _dosageCtrl.text.trim(),
      uses: _usesCtrl.text.trim(),
      prescriptionRequired: _rx,
      inStock: _inStock,
    );
    try {
      if (isEdit) {
        await context.read<ProductsCubit>().updateProduct(p);
      } else {
        await context.read<ProductsCubit>().addProduct(p);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Product updated!' : 'Product added!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final wide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _basicCard(),
                          SizedBox(height: 16.h),
                          _pricingCard(),
                          SizedBox(height: 16.h),
                          _detailsCard(),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _imagesCard(),
                          SizedBox(height: 16.h),
                          _settingsCard(),
                          SizedBox(height: 16.h),
                          _actions(),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _basicCard(),
                    SizedBox(height: 16.h),
                    _pricingCard(),
                    SizedBox(height: 16.h),
                    _detailsCard(),
                    SizedBox(height: 16.h),
                    _imagesCard(),
                    SizedBox(height: 16.h),
                    _settingsCard(),
                    SizedBox(height: 24.h),
                    _actions(),
                    SizedBox(height: 40.h),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _basicCard() => _Card(
    title: 'Basic Information',
    icon: Icons.info_outline_rounded,
    child: Column(
      children: [
        _field(
          ctrl: _nameCtrl,
          label: 'Product Name *',
          hint: 'e.g. Paracetamol 500mg',
          validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
        ),
        SizedBox(height: 14.h),
        _field(
          ctrl: _descCtrl,
          label: 'Description',
          hint: 'Brief description of the product',
          maxLines: 3,
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: _field(
                ctrl: _brandCtrl,
                label: 'Brand',
                hint: 'e.g. HealthCorp',
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(child: _catDropdown()),
          ],
        ),
      ],
    ),
  ).animate().fadeIn().slideY(begin: 0.05, end: 0);

  Widget _pricingCard() => _Card(
    title: 'Pricing',
    icon: Icons.currency_rupee_rounded,
    child: Row(
      children: [
        Expanded(
          child: _field(
            ctrl: _priceCtrl,
            label: 'Price (₹) *',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v?.trim().isEmpty ?? true) return 'Required';
              if (double.tryParse(v!.trim()) == null) return 'Invalid';
              return null;
            },
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: _field(
            ctrl: _discountCtrl,
            label: 'Discount %',
            hint: '0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v?.trim().isEmpty ?? true) return null;
              final d = double.tryParse(v!.trim());
              if (d == null || d < 0 || d > 100) return '0–100';
              return null;
            },
          ),
        ),
      ],
    ),
  ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05, end: 0);

  Widget _detailsCard() => _Card(
    title: 'Medical Details',
    icon: Icons.medical_information_outlined,
    child: Column(
      children: [
        _field(
          ctrl: _dosageCtrl,
          label: 'Dosage',
          hint: 'e.g. 500mg, After meals',
        ),
        SizedBox(height: 14.h),
        _field(
          ctrl: _usesCtrl,
          label: 'Uses / Indications',
          hint: 'e.g. Pain, fever, headache',
          maxLines: 2,
        ),
      ],
    ),
  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);

  Widget _imagesCard() => _Card(
    title: 'Product Images',
    icon: Icons.photo_library_outlined,
    subtitle:
        'Up to ${AppConstants.maxImagesPerProduct} images. First is primary.',
    child: ImageManager(
      productId: widget.productId ?? 'new',
      existingUrls: _imageUrls,
      onUrlsChanged: (u) => setState(() => _imageUrls = u),
    ),
  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0);

  Widget _settingsCard() => _Card(
    title: 'Settings',
    icon: Icons.settings_outlined,
    child: Column(
      children: [
        _toggle(
          value: _inStock,
          color: AppColors.success,
          bgColor: _inStock ? AppColors.successLight : AppColors.surfaceVariant,
          borderColor: _inStock
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border,
          icon: _inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
          iconColor: _inStock ? AppColors.success : AppColors.textTertiary,
          title: 'Stock Status',
          subtitle: _inStock ? 'Product is available' : 'Out of stock',
          subtitleColor: _inStock ? AppColors.success : AppColors.textTertiary,
          onChanged: (v) => setState(() => _inStock = v),
        ),
        SizedBox(height: 12.h),
        _toggle(
          value: _rx,
          color: AppColors.warning,
          bgColor: _rx ? AppColors.warningLight : AppColors.surfaceVariant,
          borderColor: _rx
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.border,
          icon: Icons.assignment_outlined,
          iconColor: _rx ? AppColors.warning : AppColors.textTertiary,
          title: 'Prescription Required',
          subtitle: _rx
              ? 'Rx required for purchase'
              : 'Available over the counter',
          subtitleColor: AppColors.textTertiary,
          onChanged: (v) => setState(() => _rx = v),
        ),
      ],
    ),
  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);

  Widget _toggle({
    required bool value,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required ValueChanged<bool> onChanged,
  }) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20.sp, color: iconColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11.sp, color: subtitleColor),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeThumbColor: color),
      ],
    ),
  );

  Widget _actions() => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: _saving ? null : () => context.go('/products'),
          child: const Text('Cancel'),
        ),
      ),
      SizedBox(width: 12.w),
      Expanded(
        flex: 2,
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isEdit ? 'Update Product' : 'Add Product'),
        ),
      ),
    ],
  );

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );

  Widget _catDropdown() => DropdownButtonFormField<String>(
    initialValue: _cat,
    decoration: const InputDecoration(labelText: 'Category'),
    items: AppConstants.productCategories
        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
        .toList(),
    onChanged: (v) => setState(() => _cat = v!),
  );
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;
  const _Card({
    required this.title,
    required this.icon,
    this.subtitle,
    required this.child,
  });
  @override
  Widget build(BuildContext ctx) => Container(
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 16.sp, color: AppColors.primary),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        child,
      ],
    ),
  );
}
