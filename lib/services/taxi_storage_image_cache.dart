import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Resolves `assets/taxi/bank/images/...` to Firebase Storage download URLs.
///
/// Objects live under `taxi/bank/images/<filename>`. Storage rules allow **public
/// read** for that prefix so images load without Auth/App Check (see [storage.rules]).
class TaxiStorageImageCache {
  TaxiStorageImageCache._();
  static final TaxiStorageImageCache instance = TaxiStorageImageCache._();

  static const _bankPrefix = 'assets/taxi/bank/images/';
  static const _storageRoot = 'taxi/bank/images';

  final Map<String, Future<String?>> _urlCache = {};

  /// Storage path (e.g. `taxi/bank/images/foo.png`) or null if [assetPath] is not a bank image.
  String? storagePathForAsset(String assetPath) {
    if (!assetPath.startsWith(_bankPrefix)) return null;
    final name = assetPath.substring(_bankPrefix.length);
    if (name.isEmpty || name.contains('..')) return null;
    return '$_storageRoot/$name';
  }

  /// Public download URL for a bank asset path, or null if unavailable / not a bank path.
  ///
  /// Failed lookups are **not** kept in cache so retries can succeed after network/auth blips.
  Future<String?> getDownloadUrlForAssetPath(String assetPath) {
    final sp = storagePathForAsset(assetPath);
    if (sp == null) return Future.value(null);

    return _urlCache.putIfAbsent(sp, () => _resolveUrlUncachedOnFailure(sp));
  }

  Future<String?> _resolveUrlUncachedOnFailure(String sp) async {
    try {
      if (Firebase.apps.isEmpty) return null;
      final ref = FirebaseStorage.instance.ref(sp);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        debugPrint('TaxiStorageImageCache: $sp — ${e.code} ${e.message}');
      }
    } catch (e, st) {
      debugPrint('TaxiStorageImageCache: $sp — $e\n$st');
    }
    _urlCache.remove(sp);
    return null;
  }
}
