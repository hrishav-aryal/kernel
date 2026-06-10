import '../models/models.dart';
import '../repositories/user_repository.dart';

/// Service for user-related business logic
/// Handles user profile, subscription, and preferences
class UserService {
  final UserRepository _repository = UserRepository();

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    return await _repository.getUserById(userId);
  }

  /// Save or update user
  Future<User> saveUser(User user) async {
    return await _repository.saveUser(user);
  }

  /// Check if user has premium access
  bool hasUserPremiumAccess(User? user) {
    if (user == null) return false;

    if (user.subscriptionType == UserSubscriptionType.free) {
      return false;
    }

    // Check if subscription is still valid
    if (user.subscriptionExpiresAt != null) {
      return DateTime.now().isBefore(user.subscriptionExpiresAt!);
    }

    return true;
  }

  /// Update user subscription
  Future<User> updateSubscription(
    User user,
    UserSubscriptionType subscriptionType, {
    DateTime? expiresAt,
  }) async {
    final updatedUser = User(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      profileImageUrl: user.profileImageUrl,
      subscriptionType: subscriptionType,
      createdAt: user.createdAt,
      subscriptionExpiresAt: expiresAt,
      preferences: user.preferences,
    );

    return await saveUser(updatedUser);
  }

  /// Update user profile
  Future<User> updateProfile(
    User user, {
    String? displayName,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) async {
    final updatedUser = User(
      id: user.id,
      email: user.email,
      displayName: displayName ?? user.displayName,
      profileImageUrl: profileImageUrl ?? user.profileImageUrl,
      subscriptionType: user.subscriptionType,
      createdAt: user.createdAt,
      subscriptionExpiresAt: user.subscriptionExpiresAt,
      preferences: preferences ?? user.preferences,
    );

    return await saveUser(updatedUser);
  }

  /// Get user preference
  T? getUserPreference<T>(User user, String key) {
    return user.preferences?[key] as T?;
  }

  /// Set user preference
  Future<User> setUserPreference(User user, String key, dynamic value) async {
    final preferences = Map<String, dynamic>.from(user.preferences ?? {});
    preferences[key] = value;

    return await updateProfile(user, preferences: preferences);
  }
}
