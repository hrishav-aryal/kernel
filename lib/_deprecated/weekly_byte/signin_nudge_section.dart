import 'package:flutter/material.dart';
import 'package:kernel/theme/app_theme.dart';
import '../../utils/auth_helper.dart';

class SignInNudgeSection extends StatelessWidget {
  const SignInNudgeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Jump Back In',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(letterSpacing: -0.2),
          ),
        ),
        const SizedBox(height: 16),

        // Gentle sign-in nudge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () async {
              final result = await AuthHelper.showLoginScreen(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline?.withOpacity(0.2) ??
                      Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Compact content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sign in to save your progress',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Keep track of your learning journey',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subtle arrow
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.outline,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
