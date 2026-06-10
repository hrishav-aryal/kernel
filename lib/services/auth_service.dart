import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:async';
import '../config/supabase_config.dart';
import '../models/models.dart' as models;
import '../repositories/user_repository.dart';

/// Service for handling authentication operations
/// Manages Google OAuth, Apple Sign In, and Supabase authentication
class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Use Web client ID for Supabase compatibility
    clientId:
        '690226109047-5l8k0beio1ntkhm2fktdqu6t166etm4k.apps.googleusercontent.com',
    serverClientId:
        '690226109047-ekk4vk2mm9u9d7ol62ncdqrmrei1sagr.apps.googleusercontent.com',
  );
  final UserRepository _userRepository = UserRepository();

  /// Get current authenticated user
  models.User? get currentUser {
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      return models.User(
        id: session!.user.id,
        email: session.user.email ?? '',
        displayName:
            session.user.userMetadata?['full_name'] ??
            session.user.userMetadata?['name'] ??
            session.user.email?.split('@').first ??
            'User',
        profileImageUrl: session.user.userMetadata?['avatar_url'],
        subscriptionType: models.UserSubscriptionType.free,
        createdAt: DateTime.parse(session.user.createdAt),
      );
    }
    return null;
  }

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentSession != null;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign in with Google
  Future<models.User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Sign in to Supabase with the Google credential
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        // Create or update user in our database
        final user = await _createOrUpdateUser(response.user!);
        return user;
      }

      return null;
    } catch (error) {
      print('Error signing in with Google: $error');
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<models.User?> signInWithApple() async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Sign in to Supabase with the Apple credential
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
      );

      if (response.user != null) {
        // Update user metadata with name if available (only on first sign-in)
        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          final fullName = [
            appleCredential.givenName,
            appleCredential.familyName,
          ].where((n) => n != null).join(' ');

          if (fullName.isNotEmpty) {
            await _supabase.auth.updateUser(
              UserAttributes(data: {'full_name': fullName}),
            );
          }
        }

        // Create or update user in our database
        final user = await _createOrUpdateUser(response.user!);
        return user;
      }

      return null;
    } catch (error) {
      print('Error signing in with Apple: $error');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_supabase.auth.signOut(), _googleSignIn.signOut()]);
    } catch (error) {
      print('Error signing out: $error');
      rethrow;
    }
  }

  /// Create or update user in database
  Future<models.User> _createOrUpdateUser(supabase.User supabaseUser) async {
    // Check if user already exists to preserve their preferences
    final existingUser = await _userRepository.getUserById(supabaseUser.id);

    final user = models.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName:
          supabaseUser.userMetadata?['full_name'] ??
          supabaseUser.userMetadata?['name'] ??
          supabaseUser.email?.split('@').first ??
          'User',
      profileImageUrl: supabaseUser.userMetadata?['avatar_url'],
      subscriptionType:
          existingUser?.subscriptionType ?? models.UserSubscriptionType.free,
      createdAt:
          existingUser?.createdAt ?? DateTime.parse(supabaseUser.createdAt),
      subscriptionExpiresAt: existingUser?.subscriptionExpiresAt,
      // Preserve existing preferences if user already exists
      preferences: existingUser?.preferences,
    );

    // Save user to database
    return await _userRepository.saveUser(user);
  }

  /// Get user from database
  Future<models.User?> getUserFromDatabase() async {
    final currentUser = this.currentUser;
    if (currentUser == null) return null;

    return await _userRepository.getUserById(currentUser.id);
  }

  /// Delete user account and all associated data
  /// This will:
  /// 1. Delete user record from users table (cascades to progress, saved_bytes)
  /// 2. Sign out from Supabase and Google
  /// Note: Auth user deletion requires admin privileges and should be handled
  /// via a database function or edge function. For App Store compliance,
  /// deleting all user data is sufficient.
  Future<void> deleteAccount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No user to delete');
      }

      // Delete user record from database (cascades will handle related data:
      // saved_bytes, course_byte_progress, byte_progress)
      await _supabase.from('users').delete().eq('id', userId);

      // Sign out from Supabase and Google
      await Future.wait([_supabase.auth.signOut(), _googleSignIn.signOut()]);
    } catch (error) {
      print('Error deleting account: $error');
      rethrow;
    }
  }
}
