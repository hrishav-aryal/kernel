import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';

/// Utility class for showing the login screen
class AuthHelper {
  /// Show login screen as full screen with smooth slide-up animation
  static Future<bool?> showLoginScreen(BuildContext context) async {
    return await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LoginScreen(),
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide up animation
          const begin = Offset(0.0, 2.0);
          const end = Offset.zero;
          const curve = Curves.fastEaseInToSlowEaseOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
