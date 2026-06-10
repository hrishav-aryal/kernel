import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kernel/repositories/course_repository.dart';

class CourseHeader extends StatelessWidget {
  final CourseData courseData;

  const CourseHeader({super.key, required this.courseData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Course Image
          Image.asset(
            'assets/images/python.png',
            fit: BoxFit.cover,
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 20),

          // Course Title
          Text(
            courseData.course.title,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Course Description
          Text(
            courseData.course.description,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                context,
                icon: Icons.school_outlined,
                label: '${_getLessonsCount()} Lessons',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                context,
                icon: Icons.star_outline,
                label: _getLevel(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Get lessons count from metadata or fall back to total byte count
  int _getLessonsCount() {
    return courseData.course.numberOfLessons ?? courseData.totalByteCount;
  }

  /// Get course level from metadata or fall back to 'Beginner'
  String _getLevel() {
    final level = courseData.course.level;
    if (level == null || level.isEmpty) {
      return 'Beginner';
    }
    // Capitalize first letter
    return level[0].toUpperCase() + level.substring(1);
  }
}
