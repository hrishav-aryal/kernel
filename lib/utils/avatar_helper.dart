import 'dart:math';

/// Helper class for managing user avatar images
class AvatarHelper {
  // List of available avatar filenames
  // Update this list as you add more avatars to assets/avatars/
  static const List<String> availableAvatars = [
    'bottts-1.png',
    'bottts-2.png',
    'bottts-3.png',
    'bottts-4.png',
    'bottts-5.png',
    'bottts-6.png',
    'bottts-7.png',
    'bottts-8.png',
    'bottts-9.png',
    'bottts-10.png',
    'bottts-11.png',
    'bottts-12.png',
    'bottts-13.png',
    'bottts-14.png',
    'bottts-15.png',
    'bottts-16.png',
    'bottts-17.png',
    'bottts-18.png',
    'bottts-19.png',
    'bottts-20.png',
    // Add more avatar filenames here as you add them to assets/avatars/
    // e.g., 'bottts-2.png', 'bottts-3.png', etc.
  ];

  /// Get a random avatar filename from the available avatars
  static String getRandomAvatar() {
    final random = Random();
    final randomIndex = random.nextInt(availableAvatars.length);
    return availableAvatars[randomIndex];
  }

  /// Get the full asset path for an avatar filename
  static String getAvatarPath(String? avatarFileName) {
    // If no avatar filename provided, use the first one as default
    final fileName = avatarFileName ?? availableAvatars.first;
    return 'assets/avatars/$fileName';
  }

  /// Check if an avatar filename is valid
  static bool isValidAvatar(String? avatarFileName) {
    if (avatarFileName == null) return false;
    return availableAvatars.contains(avatarFileName);
  }

  /// Get default avatar filename
  static String get defaultAvatar => availableAvatars.first;
}
