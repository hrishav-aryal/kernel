import 'enums.dart';

// ================================
// USER MODEL
// ================================

class User {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final UserSubscriptionType subscriptionType;
  final DateTime createdAt;
  final DateTime? subscriptionExpiresAt;
  final Map<String, dynamic>? preferences;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.subscriptionType,
    required this.createdAt,
    this.subscriptionExpiresAt,
    this.preferences,
  });

  bool get isPremium => subscriptionType == UserSubscriptionType.premium;

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      profileImageUrl: map['profileImageUrl'],
      subscriptionType: UserSubscriptionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['subscriptionType'],
        orElse: () => UserSubscriptionType.free,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      subscriptionExpiresAt:
          map['subscriptionExpiresAt'] != null
              ? DateTime.parse(map['subscriptionExpiresAt'])
              : null,
      preferences: map['preferences'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'subscriptionType': subscriptionType.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'preferences': preferences,
    };
  }
}
