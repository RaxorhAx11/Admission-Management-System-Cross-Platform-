import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:admission_management/core/constants/app_constants.dart';

/// Upload documents to Firebase Storage. Path: applications/{applicationId}/{photo|idProof|marksheet}
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file and return its download URL. Used for photo, ID proof, marksheet.
  Future<String> uploadDocument({
    required String applicationId,
    required String type, // photo, idProof, marksheet
    required Uint8List bytes,
  }) async {
    final ref = _storage
        .ref()
        .child(AppConstants.storageApplications)
        .child(applicationId)
        .child(type);

    // Helpful logging to debug Storage path and upload status.
    debugPrint('StorageService.uploadDocument → uploading to: ${ref.fullPath}');

    final uploadTask = ref.putData(bytes);
    final snapshot = await uploadTask;

    if (snapshot.state != TaskState.success) {
      debugPrint(
        'StorageService.uploadDocument → upload failed for ${ref.fullPath} '
        'with state: ${snapshot.state}',
      );
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'upload-failed',
        message: 'Failed to upload document to ${ref.fullPath}',
      );
    }

    final url = await ref.getDownloadURL();
    debugPrint('StorageService.uploadDocument → download URL: $url');
    return url;
  }

  /// Get download URL for a stored document (e.g. for admin viewing).
  Future<String> getDownloadUrl(String path) async {
    return await _storage.ref(path).getDownloadURL();
  }
}
