import 'package:kernel/services/course_service.dart';
import 'package:kernel/repositories/course_repository.dart';
import 'package:kernel/models/models.dart';

class HomeService {
  final CourseService _courseService = CourseService();

  /// Get complete home screen data (course content only)
  /// Progress is managed by CourseByteProgressProvider
  Future<HomeData?> getHomeData() async {
    try {
      // Get course content (single network call)
      final courseData = await _courseService.getCourseContent();
      if (courseData == null) return null;

      return HomeData(courseData: courseData);
    } catch (e) {
      throw Exception('Failed to load home data: $e');
    }
  }
}

// ================================
// HELPER CLASS
// ================================

class HomeData {
  final CourseData courseData;

  HomeData({required this.courseData});

  /// Check if a lesson is locked based on sequential completion
  /// Uses a completion checker function to get fresh data from provider
  bool isLessonLocked(
    CourseByte byte,
    String? userId,
    bool Function(String byteId) isCompleted,
  ) {
    // Get all bytes in order
    final allBytes = courseData.getAllBytesOrdered();

    // First lesson is always unlocked (even for non-authenticated users)
    if (allBytes.isEmpty || allBytes.first.id == byte.id) {
      return false;
    }

    // Not authenticated users see all lessons except the first as locked
    if (userId == null) {
      return true;
    }

    // Get previous byte
    final previousByte = courseData.getPreviousByte(byte);

    // If no previous byte found (shouldn't happen), unlock it
    if (previousByte == null) {
      return false;
    }

    // Check if previous byte is completed using the checker function
    return !isCompleted(previousByte.id);
  }
}
