import '../models/models.dart';
import '../repositories/course_repository.dart';

/// Helper class to calculate course-level progress from byte-level progress
class CourseProgressCalculator {
  /// Calculate progress percentage for a course
  /// Returns a value between 0.0 and 1.0
  static double calculateCourseProgress(
    CourseData courseData,
    List<CourseByteProgress> userProgress,
  ) {
    final totalBytes = courseData.totalByteCount;
    if (totalBytes == 0) return 0.0;

    final completedBytes = userProgress.where((p) => p.isCompleted).length;
    return completedBytes / totalBytes;
  }

  /// Check if a course is completed (all bytes completed)
  static bool isCourseCompleted(
    CourseData courseData,
    List<CourseByteProgress> userProgress,
  ) {
    final progress = calculateCourseProgress(courseData, userProgress);
    return progress >= 1.0;
  }

  /// Check if a course is in progress (at least one byte has progress)
  static bool isCourseInProgress(
    CourseData courseData,
    List<CourseByteProgress> userProgress,
  ) {
    final progress = calculateCourseProgress(courseData, userProgress);
    return progress > 0.0 && progress < 1.0;
  }

  /// Get completed byte count
  static int getCompletedByteCount(List<CourseByteProgress> userProgress) {
    return userProgress.where((p) => p.isCompleted).length;
  }
}

/// Data class to hold course with calculated progress
class CourseWithProgress {
  final Course course;
  final CourseData courseData;
  final double progress; // 0.0 to 1.0
  final int completedBytes;
  final int totalBytes;

  CourseWithProgress({
    required this.course,
    required this.courseData,
    required this.progress,
    required this.completedBytes,
    required this.totalBytes,
  });

  bool get isCompleted => progress >= 1.0;
  bool get isInProgress => progress > 0.0 && progress < 1.0;
  int get progressPercentage => (progress * 100).toInt();
}
