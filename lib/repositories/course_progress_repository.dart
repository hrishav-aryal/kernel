import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kernel/models/models.dart';

class CourseProgressRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all course byte progress for a user
  Future<List<CourseByteProgress>> getUserProgress(String userId) async {
    try {
      final response = await _supabase
          .from('course_byte_progress')
          .select()
          .eq('user_id', userId)
          .order('last_accessed_at', ascending: false);

      return (response as List<dynamic>)
          .map((progressMap) => CourseByteProgress.fromMap(progressMap))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user progress: $e');
    }
  }

  /// Save or update course byte progress (simplified upsert pattern like weekly bytes)
  Future<CourseByteProgress> saveCourseByteProgress(
    CourseByteProgress progress,
  ) async {
    try {
      final response =
          await _supabase
              .from('course_byte_progress')
              .upsert(progress.toMap())
              .select()
              .single();

      return CourseByteProgress.fromMap(response);
    } catch (e) {
      throw Exception('Failed to save course byte progress: $e');
    }
  }
}
