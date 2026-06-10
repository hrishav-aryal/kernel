import 'package:flutter/material.dart';
import 'package:kernel/utils/custom_snackbar.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../saved_bytes_provider.dart';
import '../../models/models.dart';
import '../../utils/auth_helper.dart';
import '../../screens/reader/lesson_reader_screen.dart';
import '../../screens/utils/byte_thumbnail_widget.dart';
import '../../utils/shimmer_loading.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<void> _refreshLibrary() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final savedBytesProvider = Provider.of<SavedBytesProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated && authProvider.user != null) {
      await savedBytesProvider.refreshSavedBytes(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header at the top
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Library',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Add library management functionality
                    },
                    icon: Icon(null, color: Theme.of(context).iconTheme.color),
                  ),
                ],
              ),
            ),

            // Expandable scrollable content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshLibrary,
                child: Consumer2<AuthProvider, SavedBytesProvider>(
                  builder: (context, authProvider, savedBytesProvider, child) {
                    if (!authProvider.isAuthenticated) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: _buildSignInNudge(context),
                        ),
                      );
                    }

                    if (savedBytesProvider.error != null) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: _buildErrorState(context, savedBytesProvider),
                        ),
                      );
                    }

                    if (savedBytesProvider.isLoading) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: _buildLoadingState(context),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: _buildSavedBytesList(
                        context,
                        authProvider,
                        savedBytesProvider,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_outline,
              size: 48,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No saved content yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save bytes to your library to read them later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to bytes screen
            },
            child: const Text('Explore Bytes'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInNudge(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 48,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign in to access your library',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save bytes to your personal library and access them anytime',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await AuthHelper.showLoginScreen(context);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      itemCount: 3, // Show 6 shimmer placeholders
      itemBuilder: (context, index) {
        return const LibraryByteCardShimmer();
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    SavedBytesProvider savedBytesProvider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sentiment_very_dissatisfied,
              size: 48,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            savedBytesProvider.error ?? 'Failed to load your library',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.user != null) {
                savedBytesProvider.clearError();
                await savedBytesProvider.refreshSavedBytes(
                  authProvider.user!.id,
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedBytesList(
    BuildContext context,
    AuthProvider authProvider,
    SavedBytesProvider savedBytesProvider,
  ) {
    // If no saved bytes, return empty state immediately without FutureBuilder
    if (savedBytesProvider.savedByteIds.isEmpty) {
      return _buildEmptyState(context);
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: savedBytesProvider.getSavedBytesWithDetails(
        authProvider.user!.id,
      ),
      key: ValueKey(
        savedBytesProvider.savedByteIds.join(','),
      ), // Stable key based on actual IDs
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, savedBytesProvider);
        }

        final savedBytesWithDetails = snapshot.data ?? [];

        if (savedBytesWithDetails.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          itemCount: savedBytesWithDetails.length,
          itemBuilder: (context, index) {
            final savedByteData = savedBytesWithDetails[index];
            final byteData = savedByteData['byte'];

            if (byteData == null) {
              return const SizedBox(); // Return empty widget if data is null
            }

            final byte = Byte.fromMap(byteData as Map<String, dynamic>);

            return _buildSavedByteListItem(
              context,
              byte,
              savedBytesProvider,
              authProvider,
            );
          },
        );
      },
    );
  }

  Widget _buildSavedByteListItem(
    BuildContext context,
    Byte byte,
    SavedBytesProvider savedBytesProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonReaderScreen(byte: byte),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: ByteThumbnailWidget(byte: byte, useNetworkImage: true),
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with premium badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            byte.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Reading time and date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${byte.readingTimeMinutes}m read',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(byte.publishedAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Unsave button
              GestureDetector(
                onTap: () async {
                  final success = await savedBytesProvider.unsaveByte(
                    authProvider.user!.id,
                    byte.id,
                  );

                  if (!success && mounted) {
                    CustomSnackbar.showError(
                      context,
                      message:
                          savedBytesProvider.error ?? 'Failed to unsave byte',
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bookmark,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}
