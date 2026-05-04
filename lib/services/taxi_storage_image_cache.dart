import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Loads `assets/taxi/bank/images/...` from Firebase Storage via the SDK (not
/// HTTP), so **Auth + App Check** are sent per your Storage rules.
///
/// Objects must live under `taxi/bank/images/<filename>` (see
/// [scripts/upload_taxi_bank_images_to_storage.sh]). Falls back to bundled
/// assets when Storage has no object or Firebase is unavailable.
///
/// **Why not `getDownloadURL` + `CachedNetworkImage`?** Plain GETs to download
/// URLs do not carry Firebase credentials; rules like `request.auth != null`
/// then deny the image load.
class TaxiStorageImageCache {
  TaxiStorageImageCache._();
  static final TaxiStorageImageCache instance = TaxiStorageImageCache._();

  static const _bankPrefix = 'assets/taxi/bank/images/';
  static const _storageRoot = 'taxi/bank/images';
  static const _maxImageBytes = 15 * 1024 * 1024;

  final Map<String, Future<Uint8List?>> _bytesCache = {};

  /// Storage path (e.g. `taxi/bank/images/foo.png`) or null if [assetPath] is not a bank image.
  String? storagePathForAsset(String assetPath) {
    if (!assetPath.startsWith(_bankPrefix)) return null;
    final name = assetPath.substring(_bankPrefix.length);
    if (name.isEmpty || name.contains('..')) return null;
    return '$_storageRoot/$name';
  }

  /// Cached image bytes for a bank [assetPath], or null to use local asset / HTTPS URL.
  Future<Uint8List?> getBankImageBytesForAssetPath(String assetPath) {
    final sp = storagePathForAsset(assetPath);
    if (sp == null) return Future.value(null);

    return _bytesCache.putIfAbsent(sp, () async {
      try {
        if (Firebase.apps.isEmpty) return null;
        final ref = FirebaseStorage.instance.ref(sp);
        return await ref.getData(_maxImageBytes);
      } on FirebaseException catch (e) {
        if (e.code != 'object-not-found') {
          debugPrint('TaxiStorageImageCache: $sp — ${e.code} ${e.message}');
        }
        return null;
      } catch (e, st) {
        debugPrint('TaxiStorageImageCache: $sp — $e\n$st');
        return null;
      }
    });
  }
}
