import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Resolves `assets/taxi/bank/images/...` to Firebase Storage download URLs.
///
/// Objects must be uploaded under `taxi/bank/images/<filename>` (see
/// [scripts/upload_taxi_bank_images_to_storage.sh]). Falls back to bundled
/// assets when Storage has no object or Firebase is unavailable.
class TaxiStorageImageCache {
  TaxiStorageImageCache._();
  static final TaxiStorageImageCache instance = TaxiStorageImageCache._();

  static const _bankPrefix = 'assets/taxi/bank/images/';
  static const _storageRoot = 'taxi/bank/images';

  final Map<String, Future<String?>> _cache = {};

  /// Storage path (e.g. `taxi/bank/images/foo.png`) or null if [assetPath] is not a bank image.
  String? storagePathForAsset(String assetPath) {
    if (!assetPath.startsWith(_bankPrefix)) return null;
    final name = assetPath.substring(_bankPrefix.length);
    if (name.isEmpty || name.contains('..')) return null;
    return '$_storageRoot/$name';
  }

  /// Cached download URL for a bundled bank-asset path, or null to use local asset / HTTPS.
  Future<String?> getDownloadUrlForAssetPath(String assetPath) {
    final sp = storagePathForAsset(assetPath);
    if (sp == null) return Future.value(null);

    return _cache.putIfAbsent(sp, () async {
      try {
        if (Firebase.apps.isEmpty) return null;
        final ref = FirebaseStorage.instance.ref(sp);
        return await ref.getDownloadURL();
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
