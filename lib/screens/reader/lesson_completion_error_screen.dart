import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_byte_progress_provider.dart';
import '../../services/progress_handler_service.dart';
import '../../utils/custom_snackbar.dart';
import 'lesson_completion_screen.dart';

/// Error screen shown when lesson completion save fails
class LessonCompletionErrorScreen extends StatefulWidget {
  final String lessonTitle;
  final String courseByteId;
  final VoidCallback onGoHome;

  const LessonCompletionErrorScreen({
    super.key,
    required this.lessonTitle,
    required this.courseByteId,
    required this.onGoHome,
  });

  @override
  State<LessonCompletionErrorScreen> createState() =>
      _LessonCompletionErrorScreenState();
}

class _LessonCompletionErrorScreenState
    extends State<LessonCompletionErrorScreen> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      if (!authProvider.isAuthenticated || authProvider.user == null) {
        if (mounted) {
          CustomSnackbar.showError(
            context,
            message: 'Please sign in to save progress',
          );
        }
        return;
      }

      // Get progress handler
      final courseByteProgressProvider =
          context.read<CourseByteProgressProvider>();
      final progressHandler = CourseByteProgressHandler(
        courseByteProgressProvider,
      );

      // Attempt to mark as completed
      await progressHandler.markAsCompleted(
        authProvider.user!.id,
        widget.courseByteId,
      );

      if (!mounted) return;

      // Success - navigate to completion screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => LessonCompletionScreen(
                lessonTitle: widget.lessonTitle,
                onContinue: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
        ),
      );
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        CustomSnackbar.showError(
          context,
          message: 'Failed to save progress. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

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
                    onPressed: _isRetrying ? null : widget.onGoHome,
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

            // Error Content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Error icon
                        Image.asset(
                          'assets/icon/error.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 32),

                        // Error message
                        Text(
                          'Apologies!',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We couldn\'t save your progress. Please try again.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Retry button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.secondary
                                        : Colors.black,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isRetrying ? null : _handleRetry,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Center(
                                  child:
                                      _isRetrying
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                                  ),
                                            ),
                                          )
                                          : Text(
                                            'Try Again',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
