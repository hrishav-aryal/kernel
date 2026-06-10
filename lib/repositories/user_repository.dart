import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../config/supabase_config.dart';
import '../models/models.dart' as models;

/// Repository for user data operations
/// Handles all Supabase calls related to users
class UserRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get user by ID
  Future<models.User?> getUserById(String userId) async {
    try {
      final response =
          await _client.from('users').select('*').eq('id', userId).single();

      return models.User.fromMap(_mapFromDatabase(response));
    } catch (e) {
      return null;
    }
  }

  /// Save or update user
  Future<models.User> saveUser(models.User user) async {
    final response =
        await _client
            .from('users')
            .upsert(_mapToDatabase(user.toMap()))
            .select()
            .single();

    return models.User.fromMap(_mapFromDatabase(response));
  }

  /// Helper to map from database fields
  Map<String, dynamic> _mapFromDatabase(Map<String, dynamic> dbData) {
    return {
      'id': dbData['id'],
      'email': dbData['email'],
      'displayName': dbData['display_name'],
      'profileImageUrl': dbData['profile_image_url'],
      'subscriptionType': dbData['subscription_type'],
      'createdAt': dbData['created_at'],
      'subscriptionExpiresAt': dbData['subscription_expires_at'],
      'preferences': dbData['preferences'],
    };
  }

  /// Helper to map to database fields
  Map<String, dynamic> _mapToDatabase(Map<String, dynamic> modelData) {
    return {
      'id': modelData['id'],
      'email': modelData['email'],
      'display_name': modelData['displayName'],
      'profile_image_url': modelData['profileImageUrl'],
      'subscription_type': modelData['subscriptionType'],
      'created_at': modelData['createdAt'],
      'subscription_expires_at': modelData['subscriptionExpiresAt'],
      'preferences': modelData['preferences'],
    };
  }
}
