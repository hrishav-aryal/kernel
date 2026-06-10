import '../models/models.dart';
import 'progress_repository.dart';
import 'package:uuid/uuid.dart';

/// Service for progress-related business logic
/// Handles user progress tracking and state management
class ProgressService {
  final ProgressRepository _repository = ProgressRepository();
  final Uuid _uuid = const Uuid();
  ByteProgress? _byteProgress;

  /// Get user's progress for a byte
  Future<ByteProgress?> getByteProgress(String userId, String byteId) async {
    _byteProgress = await _repository.getByteProgress(userId, byteId);
    return _byteProgress;
  }

  /// Update progress (e.g., when user advances through blocks)
  Future<ByteProgress> updateProgress({
    required String userId,
    required String byteId,
    required int currentBlockIndex,
  }) async {
    _byteProgress ??= await getByteProgress(userId, byteId);
    final now = DateTime.now();

    final progress = ByteProgress(
      id: _byteProgress?.id ?? _uuid.v4(),
      userId: userId,
      byteId: byteId,
      currentBlockIndex: currentBlockIndex,
      isCompleted:
          _byteProgress?.isCompleted ??
          false, // Keep existing completion status
      completedAt: _byteProgress?.completedAt, // Keep existing completion time
      lastAccessedAt: now,
      createdAt: _byteProgress?.createdAt ?? now,
    );

    _byteProgress = await _repository.saveByteProgress(progress);

    return _byteProgress!;
  }

  /// Mark byte as completed
  Future<ByteProgress> completeByteProgress(
    String userId,
    String byteId,
  ) async {
    final existingProgress = await getByteProgress(userId, byteId);
    final now = DateTime.now();

    final progress = ByteProgress(
      id: existingProgress?.id ?? _uuid.v4(),
      userId: userId,
      byteId: byteId,
      currentBlockIndex: existingProgress?.currentBlockIndex ?? 0,
      isCompleted: true,
      completedAt: now,
      lastAccessedAt: now,
      createdAt: existingProgress?.createdAt ?? now,
    );

    return await _repository.saveByteProgress(progress);
  }

  /// Get in-progress bytes WITH byte details (OPTIMIZED - single query)
  Future<List<ByteWithProgress>> getInProgressBytesWithDetails(
    String userId, {
    int limit = 10,
  }) async {
    return await _repository.getInProgressBytesWithDetails(
      userId,
      limit: limit,
    );
  }
}
