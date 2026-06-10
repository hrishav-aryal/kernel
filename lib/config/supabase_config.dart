import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://hmavtewwpqzfsnhyvftr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhtYXZ0ZXd3cHF6ZnNuaHl2ZnRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4Njc5NzYsImV4cCI6MjA3MjQ0Mzk3Nn0.pNgbSz3iffSMAYiMCcCBPbMavBlSQelCnzmj3bxNKqY';

  // Storage bucket names
  static const String bytesBucket = 'kernel_bytes';

  static SupabaseClient get client => Supabase.instance.client;

  /// Get public URL for a file in Supabase Storage
  static String getStorageUrl(String bucket, String filePath) {
    return client.storage.from(bucket).getPublicUrl(filePath);
  }

  /// Get public URL for byte content JSON with cache busting
  static String getContentUrl(String fileName) {
    final baseUrl = getStorageUrl(bytesBucket, "content/$fileName");
    // Add timestamp as cache busting parameter
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseUrl?t=$timestamp';
  }

  /// Get public URL for byte thumbnail image
  static String getThumbnailUrl(String fileName) {
    return getStorageUrl(bytesBucket, "images/thumbnails/$fileName");
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      // RLS policies protect all database access - anon key is safe to ship
      debug: false, // Set to false in production
    );
  }
}
