import '../models/models.dart';
import 'saved_bytes_repository.dart';

/// Service for saved bytes business logic
/// Pure business logic without state management
class SavedBytesService {
  final SavedBytesRepository _repository = SavedBytesRepository();

  /// Get user's saved byte IDs
  Future<Set<String>> getUserSavedByteIds(String userId) async {
    return await _repository.getUserSavedByteIds(userId);
  }

  /// Get user's saved bytes
  Future<List<SavedByte>> getUserSavedBytes(String userId) async {
    return await _repository.getUserSavedBytes(userId);
  }

  /// Save a byte
  Future<SavedByte> saveByte(String userId, String byteId) async {
    return await _repository.saveByte(userId, byteId);
  }

  /// Unsave a byte
  Future<void> unsaveByte(String userId, String byteId) async {
    await _repository.unsaveByte(userId, byteId);
  }

  /// Check if a byte is saved
  Future<bool> isByteSaved(String userId, String byteId) async {
    return await _repository.isByteSaved(userId, byteId);
  }

  /// Get saved bytes with full byte details (for library screen)
  Future<List<Map<String, dynamic>>> getUserSavedBytesWithDetails(
    String userId,
  ) async {
    return await _repository.getUserSavedBytesWithDetails(userId);
  }
}
