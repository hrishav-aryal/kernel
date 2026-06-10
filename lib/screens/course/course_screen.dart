import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _CourseData {
  final String title;
  final String imagePath;
  final bool isComingSoon;

  _CourseData({
    required this.title,
    required this.imagePath,
    required this.isComingSoon,
  });
}

class CourseScreen extends StatelessWidget {
  final VoidCallback onNavigateToHome;

  const CourseScreen({super.key, required this.onNavigateToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseSection(
                      context,
                      sectionTitle: 'Programming',
                      subtitle: 'Build strong foundations in code',
                      categoryImagePath: 'assets/images/code.png',
                      sectionColor: const Color(0xFF6366F1), // Indigo
                      courses: [
                        _CourseData(
                          title: 'Python',
                          imagePath: 'assets/images/python.png',
                          isComingSoon: false,
                        ),
                        _CourseData(
                          title: 'JavaScript',
                          imagePath: 'assets/images/js.png',
                          isComingSoon: true,
                        ),
                        _CourseData(
                          title: 'Java',
                          imagePath: 'assets/images/java.png',
                          isComingSoon: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildCourseSection(
                      context,
                      sectionTitle: 'Career Paths',
                      subtitle: 'Master specific career paths',
                      categoryImagePath: 'assets/images/path.png',
                      sectionColor: const Color(0xFF10B981), // Emerald
                      courses: [
                        _CourseData(
                          title: 'Full Stack Development',
                          imagePath: 'assets/images/layers.png',
                          isComingSoon: true,
                        ),
                        _CourseData(
                          title: 'Backend Development',
                          imagePath: 'assets/images/backend.png',
                          isComingSoon: true,
                        ),
                        _CourseData(
                          title: 'Frontend Development',
                          imagePath: 'assets/images/frontend.png',
                          isComingSoon: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildCourseSection(
                      context,
                      sectionTitle: 'Interviews',
                      subtitle: 'Ace your technical interviews',
                      categoryImagePath: 'assets/images/shapes.png',
                      sectionColor: const Color(0xFFF59E0B), // Amber
                      courses: [
                        _CourseData(
                          title: 'System Design Interview',
                          imagePath: 'assets/images/sysdesign.png',
                          isComingSoon: true,
                        ),
                        _CourseData(
                          title: 'Coding Interview',
                          imagePath: 'assets/images/terminal.png',
                          isComingSoon: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).shadowColor,
        //     blurRadius: 20,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Courses',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSection(
    BuildContext context, {
    required String sectionTitle,
    required String subtitle,
    required String categoryImagePath,
    required Color sectionColor,
    required List<_CourseData> courses,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sectionTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Container(
                width: 56,
                height: 56,
                // decoration: BoxDecoration(color: sectionColor.withOpacity(0.1)),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    sectionColor.withOpacity(0.7),
                    BlendMode.srcATop,
                  ),
                  child: Image.asset(
                    categoryImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.category,
                        size: 28,
                        color: sectionColor,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...courses.map(
          (course) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCourseItem(
              context,
              title: course.title,
              imagePath: course.imagePath,
              isComingSoon: course.isComingSoon,
              sectionColor: sectionColor,
              onNavigateToHome: onNavigateToHome,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseItem(
    BuildContext context, {
    required String title,
    required String imagePath,
    required bool isComingSoon,
    required Color sectionColor,
    required VoidCallback onNavigateToHome,
  }) {
    final opacity = isComingSoon ? 0.5 : 1.0;
    final borderOpacity = isComingSoon ? 0.4 : 0.8;
    final borderColor = Theme.of(
      context,
    ).colorScheme.outline.withOpacity(borderOpacity);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          if (isComingSoon) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'This course will be available soon! 🚀',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          } else {
            // Small delay to let tap ripple show
            await Future.delayed(const Duration(milliseconds: 80));
            if (context.mounted) {
              onNavigateToHome();
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
              right: BorderSide(color: borderColor, width: 1.5),
              bottom: BorderSide(color: borderColor, width: 6),
              left: BorderSide(color: borderColor, width: 1.5),
            ),
          ),
          child: Row(
            children: [
              Opacity(
                opacity: opacity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      // color: sectionColor.withOpacity(0.1),
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.school,
                          size: 32,
                          color: sectionColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(opacity),
                  ),
                ),
              ),
              if (isComingSoon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  child: Text(
                    'Soon',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
