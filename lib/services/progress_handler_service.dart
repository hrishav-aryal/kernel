import 'package:kernel/_deprecated/byte_progress_provider.dart';
import 'package:kernel/providers/course_byte_progress_provider.dart';
import 'package:kernel/models/models.dart';

/// Abstract progress handler for different types of bytes
abstract class ProgressHandler {
  Future<ProgressInfo?> loadProgress(String userId, String byteId);
  Future<void> markAsCompleted(String userId, String byteId);
}

/// Progress info wrapper
class ProgressInfo {
  final bool isCompleted;

  ProgressInfo({required this.isCompleted});
}

/// Handler for weekly bytes (existing logic)
class WeeklyByteProgressHandler implements ProgressHandler {
  final ByteProgressProvider _provider;

  WeeklyByteProgressHandler(this._provider);

  @override
  Future<ProgressInfo?> loadProgress(String userId, String byteId) async {
    try {
      // Check cache first
      ByteProgress? progress = _provider.getProgress(byteId, userId);

      // If not in cache, load it
      if (progress == null) {
        await _provider.loadProgressForByte(userId, byteId);
        progress = _provider.getProgress(byteId, userId);
      }

      if (progress != null) {
        return ProgressInfo(isCompleted: progress.isCompleted);
      }
    } catch (e) {
      // Ignore errors, return null
    }
    return null;
  }

  @override
  Future<void> markAsCompleted(String userId, String byteId) async {
    await _provider.markAsCompleted(userId, byteId);
  }
}

/// Handler for course bytes (using provider pattern)
class CourseByteProgressHandler implements ProgressHandler {
  final CourseByteProgressProvider _provider;

  CourseByteProgressHandler(this._provider);

  @override
  Future<ProgressInfo?> loadProgress(String userId, String byteId) async {
    try {
      // Load progress for user (will use cache if already loaded)
      await _provider.loadProgressForUser(userId);

      // Get specific progress from provider
      final progress = _provider.getProgress(byteId, userId);

      if (progress != null) {
        return ProgressInfo(isCompleted: progress.isCompleted);
      }
    } catch (e) {
      // Ignore errors, return null
    }
    return null;
  }

  @override
  Future<void> markAsCompleted(String userId, String byteId) async {
    await _provider.markAsCompleted(userId, byteId);
  }
}

// Factory removed - now using explicit type passing from callers
