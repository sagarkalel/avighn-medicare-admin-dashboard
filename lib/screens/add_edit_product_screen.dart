import 'package:avighn_medicare/blocs/products/products_cubit.dart';
import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:avighn_medicare/utils/app_constants.dart';
import 'package:avighn_medicare/widgets/image_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          padding: const EdgeInsets.all(20),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _basicCard(),
                          const SizedBox(height: 16),
                          _pricingCard(),
                          const SizedBox(height: 16),
                          _detailsCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _imagesCard(),
                          const SizedBox(height: 16),
                          _settingsCard(),
                          const SizedBox(height: 16),
                          _actions(),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _basicCard(),
                    const SizedBox(height: 16),
                    _pricingCard(),
                    const SizedBox(height: 16),
                    _detailsCard(),
                    const SizedBox(height: 16),
                    _imagesCard(),
                    const SizedBox(height: 16),
                    _settingsCard(),
                    const SizedBox(height: 24),
                    _actions(),
                    const SizedBox(height: 40),
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
        const SizedBox(height: 14),
        _field(
          ctrl: _descCtrl,
          label: 'Description',
          hint: 'Brief description of the product',
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        // On very narrow screens stack these
        LayoutBuilder(
          builder: (ctx, c) => c.maxWidth < 300
              ? Column(
                  children: [
                    _field(
                      ctrl: _brandCtrl,
                      label: 'Brand',
                      hint: 'e.g. HealthCorp',
                    ),
                    const SizedBox(height: 14),
                    _catDropdown(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _field(
                        ctrl: _brandCtrl,
                        label: 'Brand',
                        hint: 'e.g. HealthCorp',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: _catDropdown()),
                  ],
                ),
        ),
      ],
    ),
  ).animate().fadeIn().slideY(begin: 0.05, end: 0);

  Widget _pricingCard() => _Card(
    title: 'Pricing',
    icon: Icons.currency_rupee_rounded,
    child: LayoutBuilder(
      builder: (ctx, c) => c.maxWidth < 280
          ? Column(
              children: [
                _field(
                  ctrl: _priceCtrl,
                  label: 'Price (₹) *',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Required';
                    if (double.tryParse(v!.trim()) == null) return 'Invalid';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _field(
                  ctrl: _discountCtrl,
                  label: 'Discount %',
                  hint: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return null;
                    final d = double.tryParse(v!.trim());
                    if (d == null || d < 0 || d > 100) return '0–100';
                    return null;
                  },
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _field(
                    ctrl: _priceCtrl,
                    label: 'Price (₹) *',
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Required';
                      if (double.tryParse(v!.trim()) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _field(
                    ctrl: _discountCtrl,
                    label: 'Discount %',
                    hint: '0',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
        const SizedBox(height: 14),
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
        const SizedBox(height: 12),
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
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: subtitleColor),
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
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
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
    isExpanded: true,
    items: AppConstants.productCategories
        .map(
          (c) => DropdownMenuItem(
            value: c,
            child: Text(c, overflow: TextOverflow.ellipsis),
          ),
        )
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
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}
