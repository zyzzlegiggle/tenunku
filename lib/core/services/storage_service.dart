import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Picks an image from the gallery
  Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress to save bandwidth
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// Uploads an image to the specified bucket and returns the public URL
  ///
  /// [bucketName] - Name of the bucket (products, avatars, shipping_evidence)
  /// [file] - The file to upload
  /// [path] - Optional specific path, otherwise generates one using UUID
  Future<String> uploadImage(
    String bucketName,
    File file, {
    String? path,
  }) async {
    final fileName = path ?? '${const Uuid().v4()}.jpg';
    final fileExt = file.path.split('.').last;

    // Ensure we are uploading to a unique path if not specified
    // For avatars, it might be 'userid/avatar.jpg' to overwrite
    // For products, just random uuid is fine

    final storagePath = path ?? '$fileName';

    try {
      await _supabase.storage
          .from(bucketName)
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
