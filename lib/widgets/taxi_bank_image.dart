import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/taxi_storage_image_cache.dart';
import '../theme/app_colors.dart';

/// Question-bank image: optional direct HTTPS, else Firebase Storage from [assetPath], else local asset.
class TaxiBankImage extends StatelessWidget {
  const TaxiBankImage({
    super.key,
    this.assetPath,
    this.httpsUrl,
    required this.fit,
    this.semanticLabel,
    this.width,
    this.height,
  });

  final String? assetPath;
  final String? httpsUrl;
  final BoxFit fit;
  final String? semanticLabel;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final direct = httpsUrl?.trim();
    if (direct != null && direct.isNotEmpty) {
      return _cachedNetwork(direct);
    }

    final path = assetPath?.trim();
    if (path == null || path.isEmpty) {
      return _placeholder();
    }

    final future = TaxiStorageImageCache.instance.getBankImageBytesForAssetPath(path);

    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            fit: fit,
            width: width,
            height: height,
            semanticLabel: _label,
          );
        }
        return Image.asset(
          path,
          fit: fit,
          width: width,
          height: height,
          semanticLabel: _label,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      },
    );
  }

  String? get _label {
    final s = semanticLabel?.trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  Widget _cachedNetwork(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, _) => _loading(),
      errorWidget: (context, u, error) {
        final path = assetPath?.trim();
        if (path != null && path.isNotEmpty) {
          return Image.asset(
            path,
            fit: fit,
            width: width,
            height: height,
            semanticLabel: _label,
            errorBuilder: (c, e, s) => _placeholder(),
          );
        }
        return _placeholder();
      },
    );
  }

  Widget _loading() {
    final w = width;
    final h = height ?? 160.0;
    return SizedBox(
      width: w,
      height: h,
      child: ColoredBox(
        color: AppColors.surfaceContainerHigh,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.image_not_supported_outlined, color: AppColors.outline, size: 40),
      ),
    );
  }
}
