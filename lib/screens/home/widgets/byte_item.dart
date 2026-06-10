import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kernel/models/models.dart';
import 'package:kernel/services/home_service.dart';
import 'byte_icon.dart';
import '../../../providers/course_byte_progress_provider.dart';
import '../../../providers/auth_provider.dart';
import '../home_screen.dart';

class ByteItem extends StatelessWidget {
  final CourseByte byte;
  final Color unitColor;
  final bool isLast;
  final int globalIndex;
  final HomeData homeData;
  final VoidCallback onTap;

  const ByteItem({
    super.key,
    required this.byte,
    required this.unitColor,
    required this.isLast,
    required this.globalIndex,
    required this.homeData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double horizontalOffset = _calculateHorizontalOffset(globalIndex);

    return Consumer2<CourseByteProgressProvider, AuthProvider>(
      builder: (context, courseProgressProvider, authProvider, child) {
        final status = _getByteStatus(
          courseProgressProvider,
          authProvider.user?.id,
        );

        return Container(
          margin: EdgeInsets.only(
            bottom: isLast ? 0 : 50,
            left: horizontalOffset > 0 ? horizontalOffset : 0,
            right: horizontalOffset < 0 ? horizontalOffset.abs() : 0,
          ),
          child: GestureDetector(
            onTap:
                status != ByteStatus.locked
                    ? onTap
                    : () {
                      // Show toast for locked bytes
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Complete previous lessons to unlock this lesson!',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          backgroundColor:
                              Theme.of(context).colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status Icon
                  ByteIcon(status: status, unitColor: unitColor),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                byte.title,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color:
                                      status == ByteStatus.current ||
                                              status == ByteStatus.completed
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Determine byte status based on progress
  ByteStatus _getByteStatus(
    CourseByteProgressProvider progressProvider,
    String? userId,
  ) {
    // Helper function to check completion using fresh provider data
    bool isCompleted(String byteId) {
      if (userId == null) return false;
      final progress = progressProvider.getProgress(byteId, userId);
      return progress?.isCompleted ?? false;
    }

    // Check if lesson is locked (handles authentication and sequential locking)
    if (homeData.isLessonLocked(byte, userId, isCompleted)) {
      return ByteStatus.locked;
    }

    // If not authenticated but unlocked (first lesson), show as current
    if (userId == null) {
      return ByteStatus.current;
    }

    // Get progress for this byte
    final progress = progressProvider.getProgress(byte.id, userId);

    // Check if this byte is completed
    if (progress != null && progress.isCompleted) {
      return ByteStatus.completed;
    }

    // Check if this byte has progress (current)
    if (progress != null && !progress.isCompleted) {
      return ByteStatus.current;
    }

    // No progress yet but unlocked - make it current if it's the first unlocked lesson
    // Otherwise it's available
    if (globalIndex == 0) {
      return ByteStatus.current;
    }

    // Check if this is the next available lesson (previous one is completed)
    final allBytes = homeData.courseData.getAllBytesOrdered();
    final currentIndex = allBytes.indexWhere((b) => b.id == byte.id);

    if (currentIndex > 0) {
      final previousByte = allBytes[currentIndex - 1];
      final isPreviousCompleted = isCompleted(previousByte.id);

      if (isPreviousCompleted) {
        return ByteStatus.current; // Next lesson to tackle
      }
    }

    return ByteStatus.locked;
  }

  double _calculateHorizontalOffset(int index) {
    switch (index % 4) {
      case 0:
        return 0;
      case 1:
        return 50;
      case 2:
        return 100;
      case 3:
        return 50;
      case 4:
        return 0;
      default:
        return 0;
    }
  }
}
