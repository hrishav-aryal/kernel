import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../byte_progress_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/reader/lesson_reader_screen.dart';
import '../../screens/utils/byte_thumbnail_widget.dart';
import '../../utils/shimmer_loading.dart';
import '../../utils/auth_helper.dart';

class JumpBackSection extends StatefulWidget {
  const JumpBackSection({super.key});

  @override
  State<JumpBackSection> createState() => JumpBackSectionState();
}

class JumpBackSectionState extends State<JumpBackSection> {
  List<ByteWithProgress> _bytesWithProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Start initialization after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final authProvider = context.read<AuthProvider>();

    // // Brief delay to ensure shimmer is always visible (prevents flash)
    // await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      if (authProvider.isAuthenticated && authProvider.user != null) {
        // User is authenticated - load their progress data
        await _loadInProgressBytes(authProvider.user!.id);
      } else {
        // User is not authenticated - stop loading (will show sign-in nudge)
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadInProgressBytes(String userId) async {
    try {
      // OPTIMIZED: Single query with JOIN to get bytes WITH progress
      final progressProvider = context.read<ByteProgressProvider>();
      final bytesWithProgress = await progressProvider.getJumpBackBytes(userId);

      if (mounted) {
        setState(() {
          _bytesWithProgress = bytesWithProgress;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading in-progress bytes: $e');
      if (mounted) {
        setState(() {
          _bytesWithProgress = [];
          _isLoading = false;
        });
      }
    }
  }

  void _resetState() {
    setState(() {
      _bytesWithProgress = [];
      _isLoading = true; // Start loading again for refresh
    });
  }

  /// Public refresh method for pull-to-refresh
  Future<void> refresh() async {
    // Clear cache and reset state to show loading
    final progressProvider = context.read<ByteProgressProvider>();
    progressProvider.clearCache();
    _resetState();

    // Re-initialize (will determine auth state and load data appropriately)
    await _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
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

            // Simple state logic: Show shimmer while loading, otherwise show final state
            if (_isLoading)
              // Always show shimmer while loading (initialization or refresh)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  padding: const EdgeInsets.only(left: 20, right: 4),
                  itemBuilder: (context, index) {
                    return const JumpBackCardShimmer();
                  },
                ),
              )
            else if (!authProvider.isAuthenticated)
              // User not authenticated - show sign-in nudge
              _buildSignInNudge()
            else if (_bytesWithProgress.isEmpty)
              // User authenticated but no progress data - show empty state
              _buildEmptyState()
            else
              // User authenticated with progress data - show cards
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _bytesWithProgress.length,
                  padding: const EdgeInsets.only(left: 20, right: 4),
                  itemBuilder: (context, index) {
                    final item = _bytesWithProgress[index];
                    return _buildJumpBackCard(
                      context,
                      item.byte,
                      item.progress,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSignInNudge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          await AuthHelper.showLoginScreen(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Keep track of your learning journey',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_outline,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'No in-progress bytes yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start reading a byte to see it here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJumpBackCard(
    BuildContext context,
    Byte byte,
    ByteProgress? progress,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonReaderScreen(byte: byte),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Simple column layout: image on top, text below
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section (top) - no padding
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(
                      11,
                    ), // Slightly less to account for border
                    topRight: Radius.circular(11),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3, // Perfect for your 400x300px images
                    child: ByteThumbnailWidget(
                      byte: byte,
                      useNetworkImage:
                          true, // Use network images for jump back section
                    ),
                  ),
                ),

                // Text content section (bottom) - with padding
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          byte.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(),

                        // Progress indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:
                                progress?.getProgressPercentage(
                                  byte.totalBlocks,
                                ) ??
                                0.0,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
