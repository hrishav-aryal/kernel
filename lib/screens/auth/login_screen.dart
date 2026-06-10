import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Full-screen login with Google Sign-In
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Close Button at top
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).iconTheme.color,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),

            // Login Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo/Icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/icon/kernel.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.school,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Title
                    Text(
                      'Oh look, a login screen appeared!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Access lessons and track your progress',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                        letterSpacing: -0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 80),

                    // Google Sign-In Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                authProvider.isLoading
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                    : isDark
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    authProvider.isLoading
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.3)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.4),
                                width: 5,
                              ),
                              top: BorderSide(
                                color:
                                    authProvider.isLoading
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.3)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                              left: BorderSide(
                                color:
                                    authProvider.isLoading
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.3)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                              right: BorderSide(
                                color:
                                    authProvider.isLoading
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.3)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  authProvider.isLoading
                                      ? null
                                      : () => _handleGoogleSignIn(
                                        context,
                                        authProvider,
                                      ),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (authProvider.isLoading)
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.login,
                                        size: 20,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    const SizedBox(width: 12),
                                    Text(
                                      authProvider.isLoading
                                          ? 'Signing in...'
                                          : 'Continue with Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Apple Sign-In Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                authProvider.isLoading
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                    : isDark
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    authProvider.isLoading
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.3)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.4),
                                width: 5,
                              ),
                              top: BorderSide(
                                color:
                                    authProvider.isLoading
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.3)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                              left: BorderSide(
                                color:
                                    authProvider.isLoading
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.3)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                              right: BorderSide(
                                color:
                                    authProvider.isLoading
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.3)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  authProvider.isLoading
                                      ? null
                                      : () => _handleAppleSignIn(
                                        context,
                                        authProvider,
                                      ),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (authProvider.isLoading)
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.apple,
                                        size: 20,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    const SizedBox(width: 12),
                                    Text(
                                      authProvider.isLoading
                                          ? 'Signing in...'
                                          : 'Continue with Apple',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final success = await authProvider.signInWithGoogle();

    if (!context.mounted) return;

    if (success) {
      // Close the login screen and show success message
      Navigator.of(context).pop(true);
    } else {
      // Show snackbar with generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sign in failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// Handle Apple Sign-In
  Future<void> _handleAppleSignIn(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final success = await authProvider.signInWithApple();

    if (!context.mounted) return;

    if (success) {
      // Close the login screen and show success message
      Navigator.of(context).pop(true);
    } else {
      // Show snackbar with generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sign in failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}
