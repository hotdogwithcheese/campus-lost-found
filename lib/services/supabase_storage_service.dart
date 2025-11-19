import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final _client = Supabase.instance.client;
  final String bucketName = 'items-images'; // your storage bucket name

  /// Uploads a file and returns the public URL
  Future<String?> uploadFile(File file, String fileName) async {
    try {
      final response = await _client.storage
          .from(bucketName)
          .upload('uploads/$fileName', file);

      if (response != null) {
        // Get public URL
        final publicUrl = _client.storage.from(bucketName).getPublicUrl('uploads/$fileName');
        return publicUrl;
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
    return null;
  }
}
