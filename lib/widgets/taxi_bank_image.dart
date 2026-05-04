import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/taxi_storage_image_cache.dart';
import '../theme/app_colors.dart';

/// Fallback host for bank filenames (legacy export); used if Storage has no object.
const _kBankImageCdnBase = 'https://taxi-license-2c6b0.web.app/assets/';

/// Question-bank image: [httpsUrl] if set, else Storage (or CDN / bundled asset).
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
      return _cachedNetwork(
        direct,
        thenTryAssetPath: assetPath?.trim(),
      );
    }

    final path = assetPath?.trim();
    if (path == null || path.isEmpty) {
      return _placeholder();
    }

    final cdn = _cdnUrlForBankPath(path);
    final future = TaxiStorageImageCache.instance.getDownloadUrlForAssetPath(path);

    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }
        final storageUrl = snapshot.data?.trim();
        if (storageUrl != null && storageUrl.isNotEmpty) {
          return _cachedNetwork(
            storageUrl,
            thenTryAssetPath: path,
            thenTryCdnUrl: cdn,
          );
        }
        if (cdn != null && cdn.isNotEmpty) {
          return _cachedNetwork(
            cdn,
            thenTryAssetPath: path,
            thenTryCdnUrl: null,
          );
        }
        return _assetOnly(path);
      },
    );
  }

  String? get _label {
    final s = semanticLabel?.trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  String? _cdnUrlForBankPath(String assetPath) {
    const prefix = 'assets/taxi/bank/images/';
    if (!assetPath.startsWith(prefix)) return null;
    final name = assetPath.substring(prefix.length);
    if (name.isEmpty || name.contains('..')) return null;
    return '$_kBankImageCdnBase$name';
  }

  Widget _cachedNetwork(
    String url, {
    String? thenTryAssetPath,
    String? thenTryCdnUrl,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, _) => _loading(),
      errorWidget: (context, u, error) {
        if (thenTryCdnUrl != null && thenTryCdnUrl.isNotEmpty && thenTryCdnUrl != url) {
          return _cachedNetwork(
            thenTryCdnUrl,
            thenTryAssetPath: thenTryAssetPath,
            thenTryCdnUrl: null,
          );
        }
        if (thenTryAssetPath != null && thenTryAssetPath.isNotEmpty) {
          return _assetOnly(thenTryAssetPath);
        }
        return _placeholder();
      },
    );
  }

  Widget _assetOnly(String path) {
    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: _label,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
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
