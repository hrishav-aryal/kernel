import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../utils/avatar_helper.dart';
import '../../../services/preferences_service.dart';
import 'avatar_picker_sheet.dart';

/// Widget that displays user information including profile picture, name, email, and subscription status
class UserInfoSection extends StatelessWidget {
  final User user;

  const UserInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Get user's avatar from preferences
    final preferencesService = PreferencesService();
    final avatarFileName = preferencesService.getAvatarFileName(user);
    final avatarPath = AvatarHelper.getAvatarPath(avatarFileName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Picture with Edit Button
          GestureDetector(
            onTap: () => showAvatarPicker(context, user),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(avatarPath),
                ),
                // The IconButton widget itself has a minimum size (48x48 by default),
                // regardless of the padding you specify. To make the clickable area smaller,
                // you need to set constraints and the visualDensity as well.
                Positioned(
                  top: -8,
                  right: -12,
                  child: Material(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => showAvatarPicker(context, user),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // User Name
          Text(
            user.displayName,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Email
          Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),

          // Subscription Badge
          _buildSubscriptionBadge(context),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            user.isPremium
                ? Colors.amber.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              user.isPremium
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Text(
        user.isPremium ? 'Premium' : 'Free',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color:
              user.isPremium
                  ? Colors.amber[700]
                  : Theme.of(context).textTheme.bodySmall?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
