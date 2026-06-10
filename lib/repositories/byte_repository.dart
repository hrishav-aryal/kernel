import '../models/models.dart';
import '../config/supabase_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

/// Repository for byte data operations
/// Handles data fetching from Supabase with fallback to local data
class ByteRepository {
  /// Get Supabase client
  static get _supabase => SupabaseConfig.client;

  /// Get all bytes from Supabase
  Future<List<Byte>> getBytes() async {
    try {
      final response = await _supabase
          .from('byte')
          .select('*')
          .order('published_at', ascending: false);

      return (response as List)
          .map((byteData) => Byte.fromMap(byteData))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bytes from Supabase: $e');
    }
  }

  /// Load byte content from Supabase Storage or local assets
  Future<List<Block>> loadByteContent(String contentUrl) async {
    try {
      // Check if it's a Supabase Storage URL or just a filename
      final String finalUrl = SupabaseConfig.getContentUrl(contentUrl);

      print('Loading content from: $finalUrl');

      // Try loading from Supabase Storage first with cache control headers
      final response = await http.get(
        Uri.parse(finalUrl),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> blocksJson = jsonData['blocks'] ?? [];

        final blocks =
            blocksJson
                .map(
                  (blockJson) =>
                      Block.fromMap(blockJson as Map<String, dynamic>),
                )
                .toList();
        print('Blocks: ${blocks[0].elements[0].content}');
        return blocks;
      } else {
        throw Exception('Failed to load content: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load content: $e');
    }
  }

  /// Load byte content directly from local assets (e.g., 1.4.json)
  Future<List<Block>> loadByteContentFromAssets(String assetPath) async {
    try {
      print('Loading content from assets: $assetPath');

      // Force asset path for testing
      // assetPath = 'assets/courses/python/1/1.1.1.json';

      // Load JSON content from assets
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> blocksJson = jsonData['blocks'] ?? [];

      final blocks =
          blocksJson
              .map(
                (blockJson) => Block.fromMap(blockJson as Map<String, dynamic>),
              )
              .toList();

      print('Loaded ${blocks.length} blocks from assets');
      return blocks;
    } catch (e) {
      throw Exception('Failed to load content from assets: $e');
    }
  }

  /// Load course byte content - automatically chooses local or Supabase based on course metadata
  /// This is the recommended method for loading course content
  Future<List<Block>> loadCourseByteContent({
    required CourseByte courseByte,
    required Course course,
  }) async {
    try {
      // Check if course uses local content
      if (course.useLocalContent) {
        // Build local asset path
        final basePath = course.localContentPath ?? 'assets/courses/python';
        final fullPath = '$basePath/${courseByte.contentUrl}';

        print('Loading course byte from local assets: $fullPath');
        return await loadByteContentFromAssets(fullPath);
      } else {
        // Load from Supabase Storage
        print('Loading course byte from Supabase: ${courseByte.contentUrl}');
        return await loadByteContent(courseByte.contentUrl);
      }
    } catch (e) {
      throw Exception(
        'Failed to load course byte content for "${courseByte.title}": $e',
      );
    }
  }
}
