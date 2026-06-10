import 'package:flutter/material.dart';
import '../models/models.dart';
import 'progress_service.dart';

class ByteProgressProvider extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();

  // Cache bytes with progress for jump back section (single source of truth)
  final Map<String, List<ByteWithProgress>> _jumpBackCache = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get progress for a specific byte (from jump back cache only)
  ByteProgress? getProgress(String byteId, String userId) {
    // Check if we have jump back data loaded
    final jumpBackData = _jumpBackCache[userId];
    if (jumpBackData != null) {
      // Find the byte in jump back cache
      for (final item in jumpBackData) {
        if (item.byte.id == byteId) {
          return item.progress;
        }
      }
    }

    // If not found in jump back cache or cache not loaded, return null (start fresh)
    return null;
  }

  // Load progress for a specific byte (simplified - no-op if jump back cache loaded)
  Future<void> loadProgressForByte(String userId, String byteId) async {
    // If jump back cache is loaded, we already have all in-progress bytes
    final jumpBackData = _jumpBackCache[userId];
    if (jumpBackData != null) {
      debugPrint(
        'Jump back cache loaded - no individual progress loading needed',
      );
      return; // All in-progress data already available
    }

    // If jump back cache not loaded, just start fresh
    debugPrint('Jump back cache not loaded - byte $byteId will start fresh');
    return;
  }

  // Get jump back bytes (OPTIMIZED - single query with JOIN)
  Future<List<ByteWithProgress>> getJumpBackBytes(
    String userId, {
    int limit = 10,
  }) async {
    // Check cache first
    if (_jumpBackCache.containsKey(userId)) {
      return _jumpBackCache[userId]!;
    }

    try {
      final bytesWithProgress = await _progressService
          .getInProgressBytesWithDetails(userId, limit: limit);

      // Cache the result (single source of truth)
      _jumpBackCache[userId] = bytesWithProgress;

      debugPrint(
        'Loaded ${bytesWithProgress.length} bytes with progress in single optimized query',
      );

      return bytesWithProgress;
    } catch (e) {
      debugPrint('Error loading jump back bytes: $e');
      return [];
    }
  }

  // Update progress for a byte
  Future<void> updateProgress(
    String userId,
    String byteId,
    int currentBlockIndex,
  ) async {
    try {
      // Update jump back cache immediately for optimistic UI
      final jumpBackData = _jumpBackCache[userId];
      if (jumpBackData != null) {
        for (int i = 0; i < jumpBackData.length; i++) {
          if (jumpBackData[i].byte.id == byteId) {
            final existingProgress = jumpBackData[i].progress;
            final now = DateTime.now();
            final updatedProgress = ByteProgress(
              id: existingProgress.id,
              userId: userId,
              byteId: byteId,
              currentBlockIndex: currentBlockIndex,
              isCompleted: existingProgress.isCompleted,
              completedAt: existingProgress.completedAt,
              lastAccessedAt: now,
              createdAt: existingProgress.createdAt,
            );

            // Update the cache with new progress
            jumpBackData[i] = ByteWithProgress(
              byte: jumpBackData[i].byte,
              progress: updatedProgress,
            );
            break;
          }
        }
      }
      notifyListeners();

      // Update backend
      await _progressService.updateProgress(
        userId: userId,
        byteId: byteId,
        currentBlockIndex: currentBlockIndex,
      );
    } catch (e) {
      // On error, clear jump back cache to force reload
      debugPrint('Error updating progress: $e');
      _jumpBackCache.remove(userId);
      notifyListeners();
    }
  }

  // Mark byte as completed
  Future<void> markAsCompleted(String userId, String byteId) async {
    try {
      // Remove from jump back cache (completed bytes don't appear in jump back)
      final jumpBackData = _jumpBackCache[userId];
      if (jumpBackData != null) {
        jumpBackData.removeWhere((item) => item.byte.id == byteId);
        notifyListeners();
      }

      // Update backend
      await _progressService.completeByteProgress(userId, byteId);
    } catch (e) {
      // On error, clear jump back cache to force reload
      debugPrint('Error marking byte as completed: $e');
      _jumpBackCache.remove(userId);
      notifyListeners();
    }
  }

  // Clear progress cache (useful when logging out)
  void clearCache() {
    _jumpBackCache.clear();
    _error = null;
    notifyListeners();
  }
}
