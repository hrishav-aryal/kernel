import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/models.dart';
import '../../config/supabase_config.dart';

class ByteThumbnailWidget extends StatelessWidget {
  final Byte byte;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool useNetworkImage;

  const ByteThumbnailWidget({
    super.key,
    required this.byte,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.useNetworkImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: _buildThumbnailImage(context),
    );
  }

  Widget _buildThumbnailImage(BuildContext context) {
    // Check if thumbnail URL exists
    if (byte.thumbnailUrl == null || byte.thumbnailUrl!.isEmpty) {
      return _buildDefaultThumbnail(context);
    }

    // Choose between network or asset image based on useNetworkImage flag
    if (useNetworkImage) {
      return _buildNetworkImage();
    } else {
      return _buildAssetImage(context);
    }
  }

  Widget _buildNetworkImage() {
    final String imageUrl = SupabaseConfig.getThumbnailUrl(byte.thumbnailUrl!);

    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // Image loaded successfully - fade it in
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 100),
            child: child,
          );
        }

        // Show shimmer loading placeholder
        return _buildShimmerPlaceholder(context);
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading thumbnail: $error');
        return _buildErrorThumbnail(context);
      },
    );
  }

  Widget _buildAssetImage(BuildContext context) {
    return Image.asset(
      byte.thumbnailUrl!,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultThumbnail(context);
      },
    );
  }

  Widget _buildDefaultThumbnail(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.6),
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorThumbnail(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}
