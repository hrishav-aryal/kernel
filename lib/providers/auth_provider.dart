import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../utils/avatar_helper.dart';

/// Provider for managing authentication state
/// Handles user authentication and state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PreferencesService _preferencesService = PreferencesService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Callback to notify other providers when user is loaded
  Function(User?)? onUserChanged;
  Function(String userId)? onUserSignedIn; // Callback for progress loading

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state
  void _initializeAuth() async {
    try {
      // Immediately set user from current session if authenticated
      if (_authService.isAuthenticated) {
        _user = _authService.currentUser; // Set user immediately from session
        notifyListeners(); // Notify immediately so isAuthenticated works

        // Then load additional user data from database asynchronously
        _loadUserFromDatabase();
      } else {
        notifyListeners();
      }

      // Listen to auth state changes with error handling
      _authService.authStateChanges.listen(
        (data) async {
          try {
            final event = data.event;
            final session = data.session;

            if (event == AuthChangeEvent.signedIn && session != null) {
              _user =
                  _authService.currentUser; // Set user immediately from session
              _error = null;
              notifyListeners(); // Notify immediately

              // Then load additional user data from database asynchronously
              await _loadUserFromDatabase();

              // Trigger progress loading for signed-in user
              if (_user?.id != null) {
                onUserSignedIn?.call(_user!.id);
              }
            } else if (event == AuthChangeEvent.signedOut) {
              _user = null;
              _error = null;
              notifyListeners();
              // Notify providers to reset/clear data
              onUserChanged?.call(null);
              onUserSignedIn?.call(
                '',
              ); // Empty string signals sign out for progress clearing
            }
          } catch (e) {
            // Handle errors in auth state change handler
            debugPrint('Error handling auth state change: $e');
            // Don't crash the app - just log the error
          }
        },
        onError: (error) {
          // Handle errors from the auth state stream (e.g., network timeouts)
          debugPrint('Auth state stream error: $error');
          // If there's a network error, treat as signed out
          if (_user != null) {
            _user = null;
            _error = null;
            notifyListeners();
          }
        },
      );
    } catch (e) {
      // Handle initialization errors
      debugPrint('Error initializing auth: $e');
      notifyListeners();
    }
  }

  /// Load user data from database
  Future<void> _loadUserFromDatabase() async {
    try {
      final databaseUser = await _authService.getUserFromDatabase();
      if (databaseUser != null) {
        _user = databaseUser;

        // Ensure user has an avatar (assign random one on first sign-in)
        await _ensureUserHasAvatar();

        notifyListeners(); // Notify when we get enhanced user data from database
        // Notify ThemeProvider to initialize theme
        onUserChanged?.call(_user);
      }
      // If database user not found, keep the session user we already have
    } catch (e) {
      // If database query fails, keep the session user we already have
      print('Failed to load user from database: $e');
    }
  }

  /// Ensure user has an avatar assigned
  /// If user doesn't have an avatar, assign a random one
  Future<void> _ensureUserHasAvatar() async {
    if (_user == null) return;

    // Check if user already has an avatar
    final currentAvatar = _preferencesService.getAvatarFileName(_user!);

    if (currentAvatar == null) {
      // First time - assign random avatar
      try {
        final randomAvatar = AvatarHelper.getRandomAvatar();
        final updatedUser = await _preferencesService
            .updatePreferencesWithoutContext(_user!, {
              'avatarFileName': randomAvatar,
            });
        _user = updatedUser;
        debugPrint('Assigned random avatar: $randomAvatar');
      } catch (e) {
        debugPrint('Failed to assign avatar: $e');
        // Continue without avatar - UserInfoSection will use default
      }
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();

        // Trigger progress loading for signed-in user
        if (_user?.id != null) {
          onUserSignedIn?.call(_user!.id);
        }

        return true;
      } else {
        _error = 'Sign-in was cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signInWithApple();

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();

        // Trigger progress loading for signed-in user
        if (_user?.id != null) {
          onUserSignedIn?.call(_user!.id);
        }

        return true;
      } else {
        _error = 'Sign-in was cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
      // Notify ThemeProvider to reset theme
      onUserChanged?.call(null);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh user data from Supabase
  Future<void> refreshUser() async {
    if (_user == null) return;

    try {
      final updatedUser = await _authService.getUserFromDatabase();
      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail - user data will be refreshed on next auth state change
    }
  }

  /// Update user data (used after profile updates)
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
    // Notify ThemeProvider to update theme if preferences changed
    onUserChanged?.call(_user);
  }

  /// Delete user account and all associated data
  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.deleteAccount();

      // Clear local state
      _user = null;
      _error = null;
      _isLoading = false;
      notifyListeners();

      // Notify providers to reset/clear data
      onUserChanged?.call(null);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
