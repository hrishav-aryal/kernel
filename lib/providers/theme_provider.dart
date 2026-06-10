import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/preferences_service.dart';
import '../models/models.dart';

/// Provider for managing app-wide theme state
/// Handles light/dark mode switching and persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  final PreferencesService _preferencesService = PreferencesService();

  ThemeMode _themeMode = ThemeMode.light; // Default to light theme
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemeFromLocal();
  }

  /// Load theme immediately from shared_preferences for instant visual
  Future<void> _loadThemeFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey);

      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      } else {
        // First time - default to light theme
        _themeMode = ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Error loading theme from local: $e');
      _themeMode = ThemeMode.light;
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Initialize theme from user preferences (syncs with Supabase)
  Future<void> initializeTheme(User? user) async {
    if (user == null) {
      // No user - keep current theme or use light as default
      if (!_isInitialized) {
        await _loadThemeFromLocal();
      }
      return;
    }

    try {
      // Check if user has a theme preference in Supabase
      final userPreferences = user.preferences ?? {};

      if (userPreferences.containsKey('isDarkMode')) {
        final isDarkMode = _preferencesService.getIsDarkMode(user);
        final newThemeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

        // Only update if different from current
        if (newThemeMode != _themeMode) {
          _themeMode = newThemeMode;
          // Save to local for next time
          await _saveThemeToLocal(isDarkMode);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error syncing theme from Supabase: $e');
      // Keep current theme from local storage
    }
  }

  /// Save theme to local storage
  Future<void> _saveThemeToLocal(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      debugPrint('Error saving theme to local: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final isDark = _themeMode != ThemeMode.dark;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Save to local immediately
    await _saveThemeToLocal(isDark);
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveThemeToLocal(mode == ThemeMode.dark);
    notifyListeners();
  }

  /// Set theme mode and save to both local and Supabase
  Future<void> setThemeModeAndSave(ThemeMode mode, User user) async {
    final isDark = mode == ThemeMode.dark;
    _themeMode = mode;

    // Save to local immediately for instant feedback
    await _saveThemeToLocal(isDark);
    notifyListeners();

    // Save to Supabase in background
    try {
      await _preferencesService.updatePreferencesWithoutContext(user, {
        'isDarkMode': isDark,
      });
    } catch (e) {
      debugPrint('Failed to save theme preference to Supabase: $e');
    }
  }
}
