import 'package:flutter/material.dart';

import 'taxi_bank_image.dart';

/// Fullscreen viewer with pinch-zoom and pan (for förklaring / bank images).
Future<void> showTaxiBankImageLightbox(
  BuildContext context, {
  String? assetPath,
  String? httpsUrl,
  String? semanticLabel,
}) {
  final p = assetPath?.trim();
  final u = httpsUrl?.trim();
  if ((p == null || p.isEmpty) && (u == null || u.isEmpty)) {
    return Future.value();
  }
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.94),
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.35,
                    maxScale: 4.5,
                    boundaryMargin: const EdgeInsets.all(96),
                    child: Center(
                      child: TaxiBankImage(
                        assetPath: (p != null && p.isNotEmpty) ? p : null,
                        httpsUrl: (u != null && u.isNotEmpty) ? u : null,
                        fit: BoxFit.contain,
                        semanticLabel: semanticLabel,
                        width: size.width,
                        height: size.height - 56,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    tooltip: 'Stäng',
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
