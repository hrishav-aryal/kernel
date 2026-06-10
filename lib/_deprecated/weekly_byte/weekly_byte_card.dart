import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kernel/theme/app_theme.dart';
import '../../screens/reader/lesson_reader_screen.dart';
import '../../models/models.dart';
import '../../screens/utils/byte_thumbnail_widget.dart';

class WeeklyByteCard extends StatelessWidget {
  final Byte byte;

  const WeeklyByteCard({super.key, required this.byte});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outline?.withOpacity(0.3) ??
              Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image Section with premium overlay (optimized for 4:3 aspect ratio)
          AspectRatio(
            aspectRatio: 4 / 3, // Perfect for your 400x300px images
            child: Stack(
              children: [
                // Clipped container for image to respect border radius
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: ByteThumbnailWidget(
                    byte: byte,
                    useNetworkImage:
                        true, // Use network images for weekly byte card
                  ),
                ),
                // Premium icon overlay
                if (byte.isPremium)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              Theme.of(context).colorScheme.outline ??
                              Colors.grey,
                          width: 0.3,
                        ),
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Section - Title, Reading Time, and Button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                children: [
                  // Title and Reading Time - Centered in available space
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          byte.title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(letterSpacing: -0.2),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Reading time
                        Text(
                          '${byte.readingTimeMinutes}m read',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Button - Always at bottom
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LessonReaderScreen(byte: byte),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        child: Center(
                          child: Text(
                            'Start Reading',
                            style: GoogleFonts.nunito(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
        ],
      ),
    );
  }
}
