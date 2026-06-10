import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Repository for saved bytes data operations
/// Handles all Supabase calls related to user's saved bytes
class SavedBytesRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Save a byte for a user
  Future<SavedByte> saveByte(String userId, String byteId) async {
    try {
      final response =
          await _client
              .from('saved_bytes')
              .insert({'user_id': userId, 'byte_id': byteId})
              .select()
              .single();

      return SavedByte.fromMap(_mapFromDatabase(response));
    } catch (e) {
      // Handle duplicate key error gracefully
      if (e.toString().contains('duplicate key')) {
        // Byte is already saved, fetch existing record
        final existing =
            await _client
                .from('saved_bytes')
                .select('*')
                .eq('user_id', userId)
                .eq('byte_id', byteId)
                .single();

        return SavedByte.fromMap(_mapFromDatabase(existing));
      }
      rethrow;
    }
  }

  /// Unsave a byte for a user
  Future<void> unsaveByte(String userId, String byteId) async {
    await _client
        .from('saved_bytes')
        .delete()
        .eq('user_id', userId)
        .eq('byte_id', byteId);
  }

  /// Get all saved bytes for a user
  Future<List<SavedByte>> getUserSavedBytes(String userId) async {
    final response = await _client
        .from('saved_bytes')
        .select('*')
        .eq('user_id', userId)
        .order('saved_at', ascending: false);

    return (response as List)
        .map((json) => SavedByte.fromMap(_mapFromDatabase(json)))
        .toList();
  }

  /// Get saved byte IDs for a user (optimized for checking save status)
  Future<Set<String>> getUserSavedByteIds(String userId) async {
    final response = await _client
        .from('saved_bytes')
        .select('byte_id')
        .eq('user_id', userId);

    return response.map((json) => json['byte_id'] as String).toSet();
  }

  /// Check if a specific byte is saved by a user
  Future<bool> isByteSaved(String userId, String byteId) async {
    try {
      await _client
          .from('saved_bytes')
          .select('id')
          .eq('user_id', userId)
          .eq('byte_id', byteId)
          .single();

      return true;
    } catch (e) {
      return false; // Not found
    }
  }

  /// Get saved bytes with byte details (joined query)
  Future<List<Map<String, dynamic>>> getUserSavedBytesWithDetails(
    String userId,
  ) async {
    final response = await _client
        .from('saved_bytes')
        .select('''
          *,
          byte:byte_id (
            id,
            slug,
            title,
            description,
            content_json_url,
            is_premium,
            tags,
            published_at,
            updated_at,
            thumbnail_url,
            reading_time_minutes,
            total_blocks
          )
        ''')
        .eq('user_id', userId)
        .order('saved_at', ascending: false);

    return response;
  }

  /// Helper to map from database fields (snake_case) to model fields (camelCase)
  Map<String, dynamic> _mapFromDatabase(Map<String, dynamic> dbData) {
    return {
      'id': dbData['id'],
      'userId': dbData['user_id'],
      'byteId': dbData['byte_id'],
      'savedAt': dbData['saved_at'],
    };
  }
}
