import 'package:flutter/material.dart';
import 'weekly_byte_card.dart';
import '../byte_service.dart';
import '../../models/models.dart';
import '../../utils/shimmer_loading.dart';

class FeaturedBytesSection extends StatefulWidget {
  const FeaturedBytesSection({super.key});

  @override
  State<FeaturedBytesSection> createState() => FeaturedBytesSectionState();
}

class FeaturedBytesSectionState extends State<FeaturedBytesSection> {
  final PageController _pageController = PageController();
  final ByteService _byteService = ByteService();

  int _currentPage = 0;
  List<Byte> _featuredBytes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeaturedBytes();
  }

  Future<void> _loadFeaturedBytes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final bytes = await _byteService.getBytes();

      if (mounted) {
        setState(() {
          _featuredBytes = bytes.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading featured bytes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load featured content.';
        });
      }
    }
  }

  /// Public refresh method for pull-to-refresh
  Future<void> refresh() async {
    await _loadFeaturedBytes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return SizedBox(
        height: 420,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadFeaturedBytes,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return SizedBox(
        height: 420,
        child: PageView.builder(
          itemCount: 3, // Show 3 shimmer placeholders
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: WeeklyByteCardShimmer(),
            );
          },
        ),
      );
    }

    if (_featuredBytes.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.library_books_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No featured bytes available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new content',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _featuredBytes.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: WeeklyByteCard(byte: _featuredBytes[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Pagination Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _featuredBytes.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    index == _currentPage
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
