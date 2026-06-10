import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/course_progress_service.dart';

class CourseByteProgressProvider extends ChangeNotifier {
  final CourseProgressService _progressService = CourseProgressService();

  // Cache course byte progress for the user
  final Map<String, List<CourseByteProgress>> _progressCache = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get progress for a specific course byte
  CourseByteProgress? getProgress(String courseByteId, String userId) {
    final userProgress = _progressCache[userId];
    if (userProgress != null) {
      return userProgress
          .where((p) => p.courseByteId == courseByteId)
          .firstOrNull;
    }
    return null;
  }

  // Get all progress for a user
  List<CourseByteProgress> getAllProgressForUser(String userId) {
    return _progressCache[userId] ?? [];
  }

  // Load progress for a specific user (loads all course byte progress)
  Future<void> loadProgressForUser(
    String userId, {
    bool forceRefresh = false,
  }) async {
    // If already cached and not forcing refresh, return
    if (_progressCache.containsKey(userId) && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final progressList = await _progressService.getUserProgress(userId);
      _progressCache[userId] = progressList;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading course byte progress: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark course byte as completed
  Future<void> markAsCompleted(String userId, String courseByteId) async {
    try {
      // Get existing progress from cache
      final existingProgress = getProgress(courseByteId, userId);

      // Create completed progress object to save
      final now = DateTime.now();
      final progressToSave = CourseByteProgress(
        id: existingProgress?.id ?? '', // Keep existing ID or empty for new
        userId: userId,
        courseByteId: courseByteId,
        isCompleted: true,
        completedAt: now,
        lastAccessedAt: now,
        createdAt: existingProgress?.createdAt ?? now,
      );

      // Save via service (upsert)
      final savedProgress = await _progressService.saveProgress(progressToSave);

      // Update local cache
      final userProgress = _progressCache[userId] ?? [];
      final existingIndex = userProgress.indexWhere(
        (p) => p.courseByteId == courseByteId,
      );

      if (existingIndex >= 0) {
        // Update existing
        userProgress[existingIndex] = savedProgress;
      } else {
        // Add new
        userProgress.add(savedProgress);
      }

      _progressCache[userId] = userProgress;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error marking course byte as completed: $e');
      notifyListeners();
      rethrow;
    }
  }

  // Clear cache for a user (useful for logout)
  void clearUserProgress(String userId) {
    _progressCache.remove(userId);
    notifyListeners();
  }

  // Clear all cache
  void clearAllProgress() {
    _progressCache.clear();
    notifyListeners();
  }
}
