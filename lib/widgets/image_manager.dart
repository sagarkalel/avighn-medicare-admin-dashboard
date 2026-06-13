import 'dart:typed_data';

import 'package:avighn_medicare/services/image_upload_service.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:avighn_medicare/utils/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

/// Full image manager:
///  • Upload from device (file picker — desktop/web)
///  • Camera capture (mobile web)
///  • Paste / type a URL directly
///  • Drag-to-reorder existing images
///  • Set primary, delete
class ImageManager extends StatefulWidget {
  final String productId;
  final List<String> existingUrls;
  final ValueChanged<List<String>> onUrlsChanged;

  const ImageManager({
    super.key,
    required this.productId,
    required this.existingUrls,
    required this.onUrlsChanged,
  });

  @override
  State<ImageManager> createState() => _ImageManagerState();
}

class _ImageManagerState extends State<ImageManager> {
  late List<String> _urls;
  final _urlCtrl = TextEditingController();
  bool _showUrlInput = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _urls = List.from(widget.existingUrls);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  // ── Pickers ──────────────────────────────────────────────────

  Future<void> _pickFiles() async {
    if (_urls.length >= AppConstants.maxImagesPerProduct) {
      _snack('Maximum ${AppConstants.maxImagesPerProduct} images allowed');
      return;
    }
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final remaining = AppConstants.maxImagesPerProduct - _urls.length;
      final files = result.files.take(remaining).toList();
      await _uploadFiles(files.map((f) => (f.bytes!, f.name)).toList());
    } catch (e) {
      _snack('Failed to pick files: $e');
    }
  }

  Future<void> _pickCamera() async {
    if (_urls.length >= AppConstants.maxImagesPerProduct) {
      _snack('Maximum ${AppConstants.maxImagesPerProduct} images allowed');
      return;
    }
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await _uploadFiles([
        (
          bytes,
          picked.name.isNotEmpty
              ? picked.name
              : 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ]);
    } catch (e) {
      _snack('Camera not available: $e');
    }
  }

  Future<void> _pickGallery() async {
    if (_urls.length >= AppConstants.maxImagesPerProduct) {
      _snack('Maximum ${AppConstants.maxImagesPerProduct} images allowed');
      return;
    }
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked.isEmpty) return;
      final remaining = AppConstants.maxImagesPerProduct - _urls.length;
      final items = picked.take(remaining).toList();
      final pairs = await Future.wait(
        items.map(
          (f) async => (
            await f.readAsBytes(),
            f.name.isNotEmpty
                ? f.name
                : 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ),
      );
      await _uploadFiles(pairs);
    } catch (e) {
      _snack('Gallery not available: $e');
    }
  }

  Future<void> _uploadFiles(List<(Uint8List, String)> files) async {
    setState(() => _isUploading = true);
    for (final (bytes, name) in files) {
      try {
        final isPrimary = _urls.isEmpty;
        final sortOrder = _urls.length;
        final url = await ImageUploadService().uploadBytes(
          productId: widget.productId,
          bytes: bytes,
          fileName: name,
          isPrimary: isPrimary,
          sortOrder: sortOrder,
        );
        setState(() => _urls.add(url));
        widget.onUrlsChanged(List.from(_urls));
      } catch (e) {
        _snack('Upload failed: $e');
      }
    }
    setState(() => _isUploading = false);
  }

  void _addUrl() {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) {
      _snack('Enter a valid URL starting with http');
      return;
    }
    if (_urls.length >= AppConstants.maxImagesPerProduct) {
      _snack('Maximum ${AppConstants.maxImagesPerProduct} images');
      return;
    }
    setState(() {
      _urls.add(url);
      _urlCtrl.clear();
      _showUrlInput = false;
    });
    widget.onUrlsChanged(List.from(_urls));
  }

  void _remove(int index) {
    setState(() => _urls.removeAt(index));
    widget.onUrlsChanged(List.from(_urls));
  }

  void _reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final x = _urls.removeAt(oldIndex);
      _urls.insert(newIndex, x);
    });
    widget.onUrlsChanged(List.from(_urls));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final atMax = _urls.length >= AppConstants.maxImagesPerProduct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload buttons row
        if (!atMax) ...[
          _UploadButtonsRow(
            isMobile: isMobile,
            isUploading: _isUploading,
            onPickFiles: _pickFiles,
            onPickCamera: _pickCamera,
            onPickGallery: _pickGallery,
            onAddUrl: () => setState(() => _showUrlInput = !_showUrlInput),
          ),
          const SizedBox(height: 14),
        ],

        // Uploading progress
        if (_isUploading) ...[
          _UploadingIndicator(),
          const SizedBox(height: 14),
        ],

        // URL input
        if (_showUrlInput && !atMax) ...[
          _UrlInputRow(
            ctrl: _urlCtrl,
            onAdd: _addUrl,
            onCancel: () => setState(() {
              _showUrlInput = false;
              _urlCtrl.clear();
            }),
          ),
          const SizedBox(height: 14),
        ],

        // Image list
        if (_urls.isNotEmpty) ...[
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _reorder,
            itemCount: _urls.length,
            proxyDecorator: (child, index, animation) => Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              child: child,
            ),
            itemBuilder: (ctx, i) => _ImageTile(
              key: ValueKey('${_urls[i]}_$i'),
              url: _urls[i],
              index: i,
              isPrimary: i == 0,
              total: _urls.length,
              onRemove: () => _remove(i),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.drag_indicator_rounded,
                size: 13,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Drag to reorder · First image is primary · ${_urls.length}/${AppConstants.maxImagesPerProduct}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ] else if (!_isUploading) ...[
          _EmptyDropZone(onTap: _pickFiles),
        ],
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _UploadButtonsRow extends StatelessWidget {
  final bool isMobile, isUploading;
  final VoidCallback onPickFiles, onPickCamera, onPickGallery, onAddUrl;

  const _UploadButtonsRow({
    required this.isMobile,
    required this.isUploading,
    required this.onPickFiles,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onAddUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _UpBtn(
          icon: Icons.upload_file_rounded,
          label: 'Upload File',
          color: AppColors.primary,
          onTap: isUploading ? null : onPickFiles,
        ),
        _UpBtn(
          icon: Icons.camera_alt_rounded,
          label: 'Camera',
          color: const Color(0xFF6D28D9),
          onTap: isUploading ? null : onPickCamera,
        ),
        _UpBtn(
          icon: Icons.photo_library_rounded,
          label: 'Gallery',
          color: const Color(0xFF0891B2),
          onTap: isUploading ? null : onPickGallery,
        ),
        _UpBtn(
          icon: Icons.link_rounded,
          label: 'Paste URL',
          color: AppColors.textSecondary,
          outlined: true,
          onTap: isUploading ? null : onAddUrl,
        ),
      ],
    );
  }
}

class _UpBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool outlined;
  final VoidCallback? onTap;

  const _UpBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.outlined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );

    return outlined
        ? OutlinedButton(onPressed: onTap, style: style, child: child)
        : ElevatedButton(onPressed: onTap, style: style, child: child);
  }
}

class _UploadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Uploading to Google Drive…',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  ).animate().fadeIn();
}

class _UrlInputRow extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onAdd, onCancel;

  const _UrlInputRow({
    required this.ctrl,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextFormField(
        controller: ctrl,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'https://example.com/image.jpg',
          prefixIcon: const Icon(Icons.link_rounded, size: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onFieldSubmitted: (_) => onAdd(),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Add'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    ],
  ).animate().fadeIn();
}

class _EmptyDropZone extends StatefulWidget {
  final VoidCallback onTap;
  const _EmptyDropZone({required this.onTap});
  @override
  State<_EmptyDropZone> createState() => _EmptyDropZoneState();
}

class _EmptyDropZoneState extends State<_EmptyDropZone> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: _hover ? AppColors.primarySurface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hover
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 36,
              color: _hover ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 10),
            Text(
              'Click to upload or drag & drop',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _hover ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG, WEBP up to 5MB · Max ${AppConstants.maxImagesPerProduct} images',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  ).animate().fadeIn().slideY(begin: 0.05, end: 0);
}

class _ImageTile extends StatelessWidget {
  final String url;
  final int index, total;
  final bool isPrimary;
  final VoidCallback onRemove;

  const _ImageTile({
    super.key,
    required this.url,
    required this.index,
    required this.total,
    required this.isPrimary,
    required this.onRemove,
  });

  bool get _isNetworkUrl => url.startsWith('http');

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isPrimary
            ? AppColors.primary.withOpacity(0.5)
            : AppColors.border,
      ),
    ),
    child: Row(
      children: [
        // Drag handle
        const Icon(
          Icons.drag_indicator_rounded,
          size: 18,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 52,
            height: 52,
            child: _isNetworkUrl
                ? CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        _thumb(AppColors.border, Icons.image_outlined),
                    errorWidget: (_, __, ___) => _thumb(
                      AppColors.errorLight,
                      Icons.broken_image_outlined,
                      AppColors.error,
                    ),
                  )
                : _thumb(AppColors.surfaceVariant, Icons.image_outlined),
          ),
        ),
        const SizedBox(width: 10),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (isPrimary)
                    _Badge(
                      label: 'Primary',
                      color: AppColors.primary,
                      bg: AppColors.primarySurface,
                    ),
                  _Badge(
                    label: '#${index + 1}',
                    color: AppColors.textTertiary,
                    bg: AppColors.border,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _isNetworkUrl ? _shortened(url) : 'Local file',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Delete
        Material(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(7),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _thumb(Color bg, IconData icon, [Color? iconColor]) => Container(
    color: bg,
    child: Icon(icon, size: 22, color: iconColor ?? AppColors.textTertiary),
  );

  String _shortened(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.length <= 40) return '${uri.host}$path';
      return '${uri.host}${path.substring(0, 20)}…${path.substring(path.length - 15)}';
    } catch (_) {
      return url.length > 55 ? '${url.substring(0, 52)}…' : url;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Badge({required this.label, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
    ),
  );
}
