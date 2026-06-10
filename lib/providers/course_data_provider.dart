import 'package:flutter/material.dart';
import '../repositories/course_repository.dart';

/// Provider for managing course data
/// Caches course structure to avoid redundant network calls
class CourseDataProvider extends ChangeNotifier {
  final CourseRepository _courseRepository = CourseRepository();

  CourseData? _courseData;
  bool _isLoading = false;
  String? _error;

  // Getters
  CourseData? get courseData => _courseData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load course data (loads only once, then caches)
  Future<void> loadCourseData() async {
    // If already cached, return
    if (_courseData != null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final courseData = await _courseRepository.getCourseContent();
      _courseData = courseData;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading course data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force refresh course data
  Future<void> refreshCourseData() async {
    _courseData = null;
    await loadCourseData();
  }

  /// Clear cached data
  void clearCourseData() {
    _courseData = null;
    notifyListeners();
  }
}
