import 'package:kernel/repositories/course_repository.dart';

class CourseService {
  final CourseRepository _repository = CourseRepository();

  /// Get complete course content in a single network call
  Future<CourseData?> getCourseContent() async {
    return await _repository.getCourseContent();
  }
}
