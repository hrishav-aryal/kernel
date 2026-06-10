import 'package:flutter/material.dart';
import 'package:kernel/utils/custom_snackbar.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

/// Mixin that provides profile screen business logic
/// Handles sign out and account deletion functionality
mixin ProfileLogicMixin<T extends StatefulWidget> on State<T> {
  bool _isSigningOut = false;
  bool _isDeletingAccount = false;

  // Getters for state
  bool get isSigningOut => _isSigningOut;
  bool get isDeletingAccount => _isDeletingAccount;

  /// Sign out the user
  Future<void> signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      // No need to navigate - the UI will reactively update to show unauthenticated view
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
        CustomSnackbar.showError(context, message: 'Error signing out');
      }
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (_isDeletingAccount) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data, including progress and preferences.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.deleteAccount();

      // No need to navigate - the UI will reactively update to show unauthenticated view
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
        CustomSnackbar.showError(
          context,
          message: 'Error deleting account. Please try again.',
        );
      }
    }
  }
}
