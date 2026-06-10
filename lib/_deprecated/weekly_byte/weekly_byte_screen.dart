import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'featured_bytes_section.dart';
import 'jump_back_section.dart';
import 'past_bytes_section.dart';
import '../../providers/auth_provider.dart';
import '../saved_bytes_provider.dart';
import '../../screens/utils/app_header.dart';

class WeeklyByteScreen extends StatefulWidget {
  const WeeklyByteScreen({super.key});

  @override
  State<WeeklyByteScreen> createState() => _WeeklyByteScreenState();
}

class _WeeklyByteScreenState extends State<WeeklyByteScreen> {
  // Global keys to access child components for refresh
  final GlobalKey<FeaturedBytesSectionState> _featuredSectionKey = GlobalKey();
  final GlobalKey<PastBytesSectionState> _pastSectionKey = GlobalKey();
  final GlobalKey<JumpBackSectionState> _jumpBackSectionKey = GlobalKey();

  /// Refresh all sections by calling their individual refresh methods
  Future<void> _onRefresh() async {
    final authProvider = context.read<AuthProvider>();

    // Create list of refresh futures
    final List<Future> refreshFutures = [];

    // 1. Refresh featured bytes section
    if (_featuredSectionKey.currentState != null) {
      refreshFutures.add(_featuredSectionKey.currentState!.refresh());
    }

    // 2. Refresh past bytes section
    if (_pastSectionKey.currentState != null) {
      refreshFutures.add(_pastSectionKey.currentState!.refresh());
    }

    // 3. Refresh jump back section (if authenticated)
    if (_jumpBackSectionKey.currentState != null) {
      refreshFutures.add(_jumpBackSectionKey.currentState!.refresh());
    }

    // 4. If user is authenticated, refresh saved bytes
    if (authProvider.isAuthenticated && authProvider.user != null) {
      final userId = authProvider.user!.id;

      // Refresh saved bytes
      final savedBytesProvider = context.read<SavedBytesProvider>();
      refreshFutures.add(savedBytesProvider.refreshSavedBytes(userId));
    }

    // Wait for all refreshes to complete
    await Future.wait(refreshFutures);
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
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
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
              child: const AppHeader(),
            ),

            // Expandable scrollable content with pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Bytes Section - loads independently
                      FeaturedBytesSection(key: _featuredSectionKey),

                      const SizedBox(height: 32),

                      // Jump Back In Section (handles all states internally)
                      JumpBackSection(key: _jumpBackSectionKey),

                      const SizedBox(height: 32),

                      // Past Bytes Section - loads independently
                      PastBytesSection(key: _pastSectionKey),
                    ],
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
