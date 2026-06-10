import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../config/supabase_config.dart';

/// Service for preloading images to ensure instant display
/// Follows Flutter best practices for image caching and memory management
class ImagePreloaderService {
  static final ImagePreloaderService _instance =
      ImagePreloaderService._internal();
  factory ImagePreloaderService() => _instance;
  ImagePreloaderService._internal();

  // Track preloaded images to avoid duplicate preloading
  final Set<String> _preloadedImages = <String>{};
  final Set<String> _failedImages = <String>{};
  final Map<String, NetworkImage> _imageProviders = <String, NetworkImage>{};
  final Map<String, Completer<void>> _preloadingImages =
      <String, Completer<void>>{};

  /// Extract all image URLs from a list of blocks
  List<String> extractImageUrls(List<Block> blocks) {
    final List<String> imageUrls = [];

    for (final block in blocks) {
      for (final element in block.elements) {
        if (element.type == ContentElementType.image &&
            element.imageUrl != null &&
            element.imageUrl!.isNotEmpty) {
          final fullUrl = SupabaseConfig.getContentUrl(element.imageUrl!);
          imageUrls.add(fullUrl);
        }
      }
    }

    return imageUrls;
  }

  /// Preload a single image with error handling and memory management
  Future<void> _preloadSingleImage(
    BuildContext context,
    String imageUrl,
  ) async {
    try {
      // Check if already preloaded
      if (_preloadedImages.contains(imageUrl)) {
        return;
      }

      // Check if currently being preloaded
      if (_preloadingImages.containsKey(imageUrl)) {
        await _preloadingImages[imageUrl]!.future;
        return;
      }

      // Start preloading
      final completer = Completer<void>();
      _preloadingImages[imageUrl] = completer;

      debugPrint('Preloading image: $imageUrl');

      final imageProvider = NetworkImage(imageUrl);
      await precacheImage(
        imageProvider,
        context,
        onError: (exception, stackTrace) {
          debugPrint('Failed to preload image $imageUrl: $exception');
          _failedImages.add(imageUrl);
        },
      );

      _preloadedImages.add(imageUrl);
      _imageProviders[imageUrl] = imageProvider;
      completer.complete();
      _preloadingImages.remove(imageUrl);

      debugPrint('Successfully preloaded image: $imageUrl');
    } catch (e) {
      debugPrint('Error preloading image $imageUrl: $e');
      _failedImages.add(imageUrl);
      _preloadingImages[imageUrl]?.completeError(e);
      _preloadingImages.remove(imageUrl);
      rethrow;
    }
  }

  /// Preload multiple images concurrently with progress tracking
  Future<ImagePreloadResult> preloadImages(
    BuildContext context,
    List<String> imageUrls, {
    Function(int loaded, int total)? onProgress,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (imageUrls.isEmpty) {
      return ImagePreloadResult(
        totalImages: 0,
        successfullyLoaded: 0,
        failedImages: [],
      );
    }

    final List<String> failedImages = [];
    int successCount = 0;

    // Use limited concurrency to avoid overwhelming the network
    const int concurrencyLimit = 3;
    final List<Future<void>> preloadFutures = [];

    for (int i = 0; i < imageUrls.length; i += concurrencyLimit) {
      final batch = imageUrls.skip(i).take(concurrencyLimit).toList();

      final batchFutures = batch.map((imageUrl) async {
        try {
          await _preloadSingleImage(context, imageUrl).timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException('Image preload timeout', timeout);
            },
          );
          successCount++;
        } catch (e) {
          failedImages.add(imageUrl);
          debugPrint('Failed to preload $imageUrl: $e');
        } finally {
          // Report progress
          onProgress?.call(
            successCount + failedImages.length,
            imageUrls.length,
          );
        }
      });

      preloadFutures.addAll(batchFutures);

      // Wait for current batch to complete before starting next batch
      await Future.wait(batchFutures);
    }

    return ImagePreloadResult(
      totalImages: imageUrls.length,
      successfullyLoaded: successCount,
      failedImages: failedImages,
    );
  }

  /// Preload images from blocks with progress tracking
  Future<ImagePreloadResult> preloadImagesFromBlocks(
    BuildContext context,
    List<Block> blocks, {
    Function(int loaded, int total)? onProgress,
  }) async {
    final imageUrls = extractImageUrls(blocks);
    return preloadImages(context, imageUrls, onProgress: onProgress);
  }

  /// Check if an image is already preloaded
  bool isImagePreloaded(String imageUrl) {
    final fullUrl =
        imageUrl.startsWith('http')
            ? imageUrl
            : SupabaseConfig.getContentUrl(imageUrl);
    return _preloadedImages.contains(fullUrl);
  }

  /// Check if an image failed to preload
  bool isImageFailed(String imageUrl) {
    final fullUrl =
        imageUrl.startsWith('http')
            ? imageUrl
            : SupabaseConfig.getContentUrl(imageUrl);
    return _failedImages.contains(fullUrl);
  }

  /// Get the preloaded image provider for an image URL
  NetworkImage? getImageProvider(String imageUrl) {
    final fullUrl =
        imageUrl.startsWith('http')
            ? imageUrl
            : SupabaseConfig.getContentUrl(imageUrl);
    return _imageProviders[fullUrl];
  }

  /// Clear preloaded images cache (useful for memory management)
  void clearCache() {
    _preloadedImages.clear();
    _failedImages.clear();
    _imageProviders.clear();
    _preloadingImages.clear();
    debugPrint('Image preloader cache cleared');
  }

  /// Get cache statistics
  ImageCacheStats getCacheStats() {
    return ImageCacheStats(
      preloadedCount: _preloadedImages.length,
      currentlyPreloadingCount: _preloadingImages.length,
    );
  }
}

/// Result of image preloading operation
class ImagePreloadResult {
  final int totalImages;
  final int successfullyLoaded;
  final List<String> failedImages;

  const ImagePreloadResult({
    required this.totalImages,
    required this.successfullyLoaded,
    required this.failedImages,
  });

  bool get hasFailures => failedImages.isNotEmpty;
  bool get allSuccessful => failedImages.isEmpty && totalImages > 0;
  double get successRate =>
      totalImages > 0 ? successfullyLoaded / totalImages : 0.0;
}

/// Cache statistics for monitoring
class ImageCacheStats {
  final int preloadedCount;
  final int currentlyPreloadingCount;

  const ImageCacheStats({
    required this.preloadedCount,
    required this.currentlyPreloadingCount,
  });
}
