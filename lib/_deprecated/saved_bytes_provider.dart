import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'saved_bytes_service.dart';

/// Provider for saved bytes state management
/// Separates state management from business logic
class SavedBytesProvider extends ChangeNotifier {
  final SavedBytesService _service = SavedBytesService();

  // State
  Set<String> _savedByteIds = {};
  List<SavedByte> _savedBytes = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  // Getters
  Set<String> get savedByteIds => _savedByteIds;
  List<SavedByte> get savedBytes => _savedBytes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInitialized => _hasInitialized;

  /// Check if a byte is saved
  bool isByteSaved(String byteId) {
    return _savedByteIds.contains(byteId);
  }

  /// Load user's saved bytes from database
  Future<void> loadUserSavedBytes(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load saved byte IDs for quick lookup
      final savedIds = await _service.getUserSavedByteIds(userId);

      // Load full saved bytes data
      final savedBytes = await _service.getUserSavedBytes(userId);

      _savedByteIds = savedIds;
      _savedBytes = savedBytes;
      _isLoading = false;
      _hasInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load saved bytes';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Save a byte
  Future<bool> saveByte(String userId, String byteId) async {
    try {
      _error = null;

      // Optimistically update UI
      _savedByteIds.add(byteId);
      notifyListeners();

      // Save to database via service
      final savedByte = await _service.saveByte(userId, byteId);

      // Update local state with server data
      _savedBytes.insert(0, savedByte); // Add to beginning (most recent)
      notifyListeners();

      return true;
    } catch (e) {
      // Revert optimistic update on error
      _savedByteIds.remove(byteId);
      _error = 'Failed to save byte';
      notifyListeners();
      return false;
    }
  }

  /// Unsave a byte
  Future<bool> unsaveByte(String userId, String byteId) async {
    try {
      _error = null;

      // Optimistically update UI
      _savedByteIds.remove(byteId);
      _savedBytes.removeWhere((savedByte) => savedByte.byteId == byteId);
      notifyListeners();

      // Remove from database via service
      await _service.unsaveByte(userId, byteId);

      return true;
    } catch (e) {
      // Revert optimistic update on error
      _savedByteIds.add(byteId);
      _error = 'Failed to unsave byte';
      notifyListeners();
      return false;
    }
  }

  /// Toggle save status of a byte
  Future<bool> toggleSaveByte(String userId, String byteId) async {
    if (isByteSaved(byteId)) {
      return await unsaveByte(userId, byteId);
    } else {
      return await saveByte(userId, byteId);
    }
  }

  /// Get saved bytes with full byte details (for library screen)
  /// This method doesn't affect the provider's loading state to avoid infinite loops
  Future<List<Map<String, dynamic>>> getSavedBytesWithDetails(
    String userId,
  ) async {
    return await _service.getUserSavedBytesWithDetails(userId);
  }

  /// Clear all saved bytes (for logout)
  void clearSavedBytes() {
    _savedByteIds.clear();
    _savedBytes.clear();
    _error = null;
    _isLoading = false;
    _hasInitialized = false;
    notifyListeners();
  }

  /// Refresh saved bytes
  Future<void> refreshSavedBytes(String userId) async {
    await loadUserSavedBytes(userId);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
