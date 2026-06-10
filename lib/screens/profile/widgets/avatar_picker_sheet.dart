import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/preferences_service.dart';
import '../../../utils/avatar_helper.dart';

/// Bottom sheet widget for selecting user avatar
class AvatarPickerSheet extends StatefulWidget {
  final User user;

  const AvatarPickerSheet({super.key, required this.user});

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  final PreferencesService _preferencesService = PreferencesService();
  String? _selectedAvatar;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Set initially selected avatar to user's current avatar
    _selectedAvatar = _preferencesService.getAvatarFileName(widget.user);
  }

  Future<void> _updateAvatar() async {
    if (_selectedAvatar == null || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedUser = await _preferencesService.updateAvatarFileName(
        widget.user,
        _selectedAvatar!,
        context,
      );

      // Update user in AuthProvider
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        authProvider.updateUser(updatedUser);

        // Close the sheet
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Avatar updated!',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update avatar',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,

            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAvatar = _preferencesService.getAvatarFileName(widget.user);
    final hasChanged = _selectedAvatar != currentAvatar;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Your Avatar',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Avatar Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: AvatarHelper.availableAvatars.length,
              itemBuilder: (context, index) {
                final avatarFileName = AvatarHelper.availableAvatars[index];
                final isSelected = avatarFileName == _selectedAvatar;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatarFileName;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3)
                                : Colors.transparent,
                        width: isSelected ? 3 : 0,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AvatarHelper.getAvatarPath(avatarFileName),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Update Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    hasChanged && !_isUpdating
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  bottom: BorderSide(
                    color:
                        hasChanged && !_isUpdating
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.black)
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.surfaceVariant
                                : Colors.grey[400]!),
                    width: 4,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: hasChanged && !_isUpdating ? _updateAvatar : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child:
                          _isUpdating
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                              : Text(
                                'Update Avatar',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      hasChanged && !_isUpdating
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                          : Theme.of(context).disabledColor,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the avatar picker sheet
void showAvatarPicker(BuildContext context, User user) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: AvatarPickerSheet(user: user),
        ),
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 150),
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ),
  );
}
