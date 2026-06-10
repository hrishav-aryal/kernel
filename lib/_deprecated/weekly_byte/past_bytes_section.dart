import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../byte_service.dart';
import '../saved_bytes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_helper.dart';
import '../../screens/reader/lesson_reader_screen.dart';
import '../../screens/utils/byte_thumbnail_widget.dart';
import '../../utils/shimmer_loading.dart';
import '../../utils/custom_snackbar.dart';

class PastBytesSection extends StatefulWidget {
  const PastBytesSection({super.key});

  @override
  State<PastBytesSection> createState() => PastBytesSectionState();
}

class PastBytesSectionState extends State<PastBytesSection> {
  final ByteService _byteService = ByteService();

  List<Byte> _pastBytes = [];
  bool _isLoading = true;
  bool _hasInitializedSavedBytes = false;

  @override
  void initState() {
    super.initState();
    _loadPastBytes();

    // Initialize saved bytes if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final savedBytesProvider = context.read<SavedBytesProvider>();

      if (authProvider.isAuthenticated &&
          authProvider.user != null &&
          !savedBytesProvider.hasInitialized) {
        savedBytesProvider.loadUserSavedBytes(authProvider.user!.id);
        _hasInitializedSavedBytes = true;
      }
    });
  }

  Future<void> _loadPastBytes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final bytes = await _byteService.getBytes();

      if (mounted) {
        setState(() {
          _pastBytes = bytes.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading past bytes: $e');
      if (mounted) {
        setState(() {
          _pastBytes = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Public refresh method for pull-to-refresh
  Future<void> refresh() async {
    await _loadPastBytes();
  }

  Future<void> _toggleSaveByte(Byte byte) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final savedBytesProvider = Provider.of<SavedBytesProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null) return;

    final success = await savedBytesProvider.toggleSaveByte(
      authProvider.user!.id,
      byte.id,
    );

    if (!success && mounted) {
      CustomSnackbar.showError(
        context,
        message: savedBytesProvider.error ?? 'Failed to save byte',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SavedBytesProvider>(
      builder: (context, authProvider, savedBytesProvider, child) {
        // Initialize saved bytes when user logs in
        if (authProvider.isAuthenticated &&
            authProvider.user != null &&
            !_hasInitializedSavedBytes &&
            !savedBytesProvider.hasInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            savedBytesProvider.loadUserSavedBytes(authProvider.user!.id);
            _hasInitializedSavedBytes = true;
          });
        }

        // Reset flag when user logs out
        if (!authProvider.isAuthenticated && _hasInitializedSavedBytes) {
          _hasInitializedSavedBytes = false;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explore', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),

              // Past Bytes Grid
              if (_isLoading)
                MasonryGridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  itemCount: 6, // Show 6 shimmer placeholders
                  itemBuilder: (context, index) {
                    return const PastByteCardShimmer();
                  },
                )
              else if (_pastBytes.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      Icon(
                        Icons.explore_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No bytes to explore yet',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'New content coming soon',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                )
              else
                MasonryGridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  itemCount: _pastBytes.length,
                  itemBuilder: (context, index) {
                    return _buildPastByteCard(
                      context,
                      _pastBytes[index],
                      savedBytesProvider.savedByteIds,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Format date to show 'X days ago' style
  String _formatDateAgo(DateTime publishedAt) {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else {
      return 'Today';
    }
  }

  Widget _buildPastByteCard(
    BuildContext context,
    Byte byte,
    Set<String> savedByteIds,
  ) {
    final isSaved = savedByteIds.contains(byte.id);

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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image/Thumbnail at top - optimized for 4:3 aspect ratio
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(
                      15,
                    ), // Slightly less to account for border
                    topRight: Radius.circular(15),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3, // Perfect for your 400x300px images
                    child: ByteThumbnailWidget(
                      byte: byte,
                      useNetworkImage:
                          true, // Use network images for past bytes section
                    ),
                  ),
                ),
                // Premium badge
                if (byte.isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 0.2,
                        ),
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),

            // Content at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium badge and title
                  // Title
                  Text(
                    byte.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),

                  // Date and Save Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date and Reading Time
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _formatDateAgo(byte.publishedAt),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            // Separator dot
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 2,
                              height: 2,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Reading time
                            Text(
                              '${byte.readingTimeMinutes}m read',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Save Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return GestureDetector(
                            onTap: () async {
                              if (authProvider.isAuthenticated) {
                                // User is authenticated, proceed with save/unsave
                                _toggleSaveByte(byte);
                              } else {
                                // User is not authenticated, show login screen
                                final result = await AuthHelper.showLoginScreen(
                                  context,
                                );
                                if (result == true) {
                                  // User successfully signed in, now save the byte
                                  _toggleSaveByte(byte);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                                size: 18,
                                color:
                                    isSaved
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).iconTheme.color,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
