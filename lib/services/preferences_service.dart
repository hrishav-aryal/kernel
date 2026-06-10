import '../models/models.dart';
import '../services/user_service.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Service for managing user preferences and settings
class PreferencesService {
  final UserService _userService = UserService();

  /// Default preferences
  /// Note: isDarkMode is intentionally not included - we want to detect when
  /// it's explicitly set vs using system theme
  static const Map<String, dynamic> defaultPreferences = {
    'dailyGoalMinutes': 10,
    'notificationsEnabled': true,
    'weeklyDigestEnabled': true,
  };

  /// Load user preferences
  Map<String, dynamic> loadPreferences(User user) {
    final preferences = user.preferences ?? {};

    // Merge with defaults to ensure all keys exist
    return {...defaultPreferences, ...preferences};
  }

  /// Get daily goal in minutes
  int getDailyGoalMinutes(User user) {
    return loadPreferences(user)['dailyGoalMinutes'] ??
        defaultPreferences['dailyGoalMinutes'];
  }

  /// Get dark mode setting
  /// Returns the user's preference if set, or false if not set
  /// (ThemeProvider will use system theme when preference is not set)
  bool getIsDarkMode(User user) {
    final preferences = user.preferences ?? {};
    return preferences['isDarkMode'] ?? false;
  }

  /// Get notifications setting
  bool getNotificationsEnabled(User user) {
    return loadPreferences(user)['notificationsEnabled'] ??
        defaultPreferences['notificationsEnabled'];
  }

  /// Get weekly digest setting
  bool getWeeklyDigestEnabled(User user) {
    return loadPreferences(user)['weeklyDigestEnabled'] ??
        defaultPreferences['weeklyDigestEnabled'];
  }

  /// Get user's avatar filename
  /// Returns null if not set (will trigger random assignment on first sign-in)
  String? getAvatarFileName(User user) {
    final preferences = user.preferences ?? {};
    return preferences['avatarFileName'];
  }

  /// Update daily goal minutes
  Future<User> updateDailyGoalMinutes(
    User user,
    int minutes,
    BuildContext context,
  ) async {
    final updatedUser = await _userService.setUserPreference(
      user,
      'dailyGoalMinutes',
      minutes,
    );

    // Refresh user in AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateUser(updatedUser);

    return updatedUser;
  }

  /// Update dark mode setting
  Future<User> updateDarkMode(
    User user,
    bool isDarkMode,
    BuildContext context,
  ) async {
    final updatedUser = await _userService.setUserPreference(
      user,
      'isDarkMode',
      isDarkMode,
    );

    // Refresh user in AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateUser(updatedUser);

    return updatedUser;
  }

  /// Update notifications setting
  Future<User> updateNotifications(
    User user,
    bool enabled,
    BuildContext context,
  ) async {
    final updatedUser = await _userService.setUserPreference(
      user,
      'notificationsEnabled',
      enabled,
    );

    // Refresh user in AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateUser(updatedUser);

    return updatedUser;
  }

  /// Update weekly digest setting
  Future<User> updateWeeklyDigest(
    User user,
    bool enabled,
    BuildContext context,
  ) async {
    final updatedUser = await _userService.setUserPreference(
      user,
      'weeklyDigestEnabled',
      enabled,
    );

    // Refresh user in AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateUser(updatedUser);

    return updatedUser;
  }

  /// Update user's avatar filename
  Future<User> updateAvatarFileName(
    User user,
    String avatarFileName,
    BuildContext context,
  ) async {
    final updatedUser = await _userService.setUserPreference(
      user,
      'avatarFileName',
      avatarFileName,
    );

    // Refresh user in AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateUser(updatedUser);

    return updatedUser;
  }

  /// Update multiple preferences at once
  Future<User> updatePreferences(
    User user,
    Map<String, dynamic> preferences,
    BuildContext context,
  ) async {
    final currentPreferences = Map<String, dynamic>.from(
      user.preferences ?? {},
    );
    currentPreferences.addAll(preferences);

    final updatedUser = await _userService.updateProfile(
      user,
      preferences: currentPreferences,
    );

    // Refresh user in AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateUser(updatedUser);

    return updatedUser;
  }

  /// Update preferences without context (for ThemeProvider)
  Future<User> updatePreferencesWithoutContext(
    User user,
    Map<String, dynamic> preferences,
  ) async {
    final currentPreferences = Map<String, dynamic>.from(
      user.preferences ?? {},
    );
    currentPreferences.addAll(preferences);

    return await _userService.updateProfile(
      user,
      preferences: currentPreferences,
    );
  }
}
