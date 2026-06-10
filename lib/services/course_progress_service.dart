import 'package:kernel/repositories/course_progress_repository.dart';
import 'package:kernel/models/models.dart';

class CourseProgressService {
  final CourseProgressRepository _repository = CourseProgressRepository();

  /// Get all course byte progress for a user
  Future<List<CourseByteProgress>> getUserProgress(String userId) async {
    return await _repository.getUserProgress(userId);
  }

  /// Save course byte progress (simplified - handles both update and insert)
  Future<CourseByteProgress> saveProgress(CourseByteProgress progress) async {
    return await _repository.saveCourseByteProgress(progress);
  }
}
