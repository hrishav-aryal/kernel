import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Repository for progress data operations
/// Handles all Supabase calls related to user progress
class ProgressRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get user's progress for a specific byte
  Future<ByteProgress?> getByteProgress(String userId, String byteId) async {
    try {
      final response =
          await _client
              .from('byte_progress')
              .select('*')
              .eq('user_id', userId)
              .eq('byte_id', byteId)
              .single();

      return ByteProgress.fromMap(_mapFromDatabase(response));
    } catch (e) {
      return null; // No progress found
    }
  }

  /// Save or update byte progress
  Future<ByteProgress> saveByteProgress(ByteProgress progress) async {
    final response =
        await _client
            .from('byte_progress')
            .upsert(_mapToDatabase(progress.toMap()))
            .select()
            .single();

    return ByteProgress.fromMap(_mapFromDatabase(response));
  }

  /// Get in-progress bytes WITH byte details in single query (OPTIMIZED)
  Future<List<ByteWithProgress>> getInProgressBytesWithDetails(
    String userId, {
    int limit = 10,
  }) async {
    final response = await _client
        .from('byte_progress')
        .select('''
          id,
          user_id,
          byte_id,
          current_block_index,
          is_completed,
          completed_at,
          last_accessed_at,
          created_at,
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
        .eq('is_completed', false)
        .order('last_accessed_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) {
      final byteData = json['byte'];
      return ByteWithProgress.fromMap({
        // Byte fields
        'id': byteData['id'],
        'slug': byteData['slug'],
        'title': byteData['title'],
        'description': byteData['description'],
        'content_json_url': byteData['content_json_url'],
        'is_premium': byteData['is_premium'],
        'tags': byteData['tags'],
        'published_at': byteData['published_at'],
        'updated_at': byteData['updated_at'],
        'thumbnail_url': byteData['thumbnail_url'],
        'reading_time_minutes': byteData['reading_time_minutes'],
        'total_blocks': byteData['total_blocks'],
        // Progress fields
        'progress_id': json['id'],
        'progress_user_id': json['user_id'],
        'progress_byte_id': json['byte_id'],
        'current_block_index': json['current_block_index'],
        'is_completed': json['is_completed'],
        'completed_at': json['completed_at'],
        'last_accessed_at': json['last_accessed_at'],
        'progress_created_at': json['created_at'],
      });
    }).toList();
  }

  /// Helper to map from database fields
  Map<String, dynamic> _mapFromDatabase(Map<String, dynamic> dbData) {
    return {
      'id': dbData['id'],
      'userId': dbData['user_id'],
      'byteId': dbData['byte_id'],
      'currentBlockIndex': dbData['current_block_index'],
      'isCompleted': dbData['is_completed'],
      'completedAt': dbData['completed_at'],
      'lastAccessedAt': dbData['last_accessed_at'],
      'createdAt': dbData['created_at'],
    };
  }

  /// Helper to map to database fields
  Map<String, dynamic> _mapToDatabase(Map<String, dynamic> modelData) {
    return {
      'id': modelData['id'],
      'user_id': modelData['userId'],
      'byte_id': modelData['byteId'],
      'current_block_index': modelData['currentBlockIndex'],
      'is_completed': modelData['isCompleted'],
      'completed_at': modelData['completedAt'],
      'last_accessed_at': modelData['lastAccessedAt'],
      'created_at': modelData['createdAt'],
    };
  }
}
