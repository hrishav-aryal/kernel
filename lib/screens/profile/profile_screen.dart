import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_byte_progress_provider.dart';
import '../../providers/course_data_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/auth_helper.dart';
import '../../utils/course_progress_calculator.dart';
import '../../utils/course_image_helper.dart';
import 'mixins/profile_logic_mixin.dart';
import 'widgets/user_info_section.dart';

// Privacy Policy URL - Update this with your GitHub Pages URL
const String _privacyPolicyUrl = 'https://hrishav-aryal.github.io/kernel/';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin, ProfileLogicMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Schedule load after first frame to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourseData();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );
    _animationController.forward();
  }

  Future<void> _loadCourseData() async {
    if (!mounted) return;
    // Load course data via provider (only loads once if already cached)
    final courseDataProvider = context.read<CourseDataProvider>();
    await courseDataProvider.loadCourseData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update status bar immediately when theme changes
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final isAuthenticated =
                  authProvider.isAuthenticated && authProvider.user != null;

              return Column(
                children: [
                  // App Bar - always shown
                  _buildAppBar(context, isAuthenticated: isAuthenticated),
                  // Content based on authentication state
                  Expanded(
                    child:
                        !isAuthenticated
                            ? _buildUnauthenticatedView(context)
                            : SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User Info Section
                                  UserInfoSection(user: authProvider.user!),
                                  const SizedBox(height: 32),

                                  // Current Course Section
                                  _buildCurrentCourseSection(context),
                                  const SizedBox(height: 32),

                                  // Completed Courses Section
                                  _buildCompletedCoursesSection(context),
                                  const SizedBox(height: 32),

                                  // Sign Out Button - Now in scrollable area
                                  _buildSignOutButton(),

                                  // Debug: Reset Onboarding Button
                                  if (kDebugMode) ...[
                                    const SizedBox(height: 12),
                                    _buildResetOnboardingButton(),
                                  ],
                                  const SizedBox(height: 32),

                                  // Minimal footer with Privacy Policy and Delete Account
                                  _buildFooterSection(context),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, {required bool isAuthenticated}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Profile',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // Only show dark mode toggle when authenticated
          if (isAuthenticated) ...[
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  onPressed: () {
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.user != null) {
                      final newMode =
                          themeProvider.isDarkMode
                              ? ThemeMode.light
                              : ThemeMode.dark;
                      themeProvider.setThemeModeAndSave(
                        newMode,
                        authProvider.user!,
                      );
                    }
                  },
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  tooltip:
                      themeProvider.isDarkMode
                          ? 'Switch to Light Mode'
                          : 'Switch to Dark Mode',
                );
              },
            ),
          ] else ...[
            // Invisible placeholder to maintain layout spacing
            IconButton(
              onPressed: null,
              icon: Icon(
                Icons.check_box_outline_blank,
                color: Colors.transparent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentCourseSection(BuildContext context) {
    return Consumer2<CourseDataProvider, CourseByteProgressProvider>(
      builder: (context, courseDataProvider, progressProvider, child) {
        final authProvider = context.watch<AuthProvider>();
        final userId = authProvider.user?.id;

        // Check for errors first
        if (courseDataProvider.error != null ||
            progressProvider.error != null) {
          return _buildErrorProgressSection(
            context,
            courseDataProvider.error ??
                progressProvider.error ??
                'Unknown error',
          );
        }

        // If no user or no course data, show empty state
        if (userId == null || courseDataProvider.courseData == null) {
          return _buildEmptyProgressSection(context);
        }

        // Show loading state
        if (courseDataProvider.isLoading || progressProvider.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        try {
          // Get user's progress data
          final userProgress = progressProvider.getAllProgressForUser(userId);

          // Calculate course progress
          final courseWithProgress = CourseWithProgress(
            course: courseDataProvider.courseData!.course,
            courseData: courseDataProvider.courseData!,
            progress: CourseProgressCalculator.calculateCourseProgress(
              courseDataProvider.courseData!,
              userProgress,
            ),
            completedBytes: CourseProgressCalculator.getCompletedByteCount(
              userProgress,
            ),
            totalBytes: courseDataProvider.courseData!.totalByteCount,
          );

          // Only show courses that are in progress (not completed)
          final coursesInProgress =
              courseWithProgress.isInProgress
                  ? [courseWithProgress]
                  : <CourseWithProgress>[];

          if (coursesInProgress.isEmpty) {
            return _buildEmptyProgressSection(context);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: coursesInProgress.length,
                itemBuilder: (context, index) {
                  final courseProgress = coursesInProgress[index];
                  return _buildCourseCard(
                    context,
                    courseWithProgress: courseProgress,
                  );
                },
              ),
            ],
          );
        } catch (e) {
          debugPrint('Error building current course section: $e');
          return _buildErrorProgressSection(context, 'Failed to load progress');
        }
      },
    );
  }

  Widget _buildEmptyProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.book_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'Start learning to track your progress',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorProgressSection(BuildContext context, String errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load progress',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(
    BuildContext context, {
    required CourseWithProgress courseWithProgress,
  }) {
    final imagePath = CourseImageHelper.getImageForCourse(
      courseWithProgress.course.title,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Icon centered in top space
            Expanded(
              child: Center(
                child: Image.asset(imagePath, width: 52, height: 52),
              ),
            ),
            // Title, progress bar, and percentage grouped at bottom
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseWithProgress.course.title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: courseWithProgress.progress,
                    minHeight: 4,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${courseWithProgress.progressPercentage}% complete',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCoursesSection(BuildContext context) {
    return Consumer2<CourseDataProvider, CourseByteProgressProvider>(
      builder: (context, courseDataProvider, progressProvider, child) {
        final authProvider = context.watch<AuthProvider>();
        final userId = authProvider.user?.id;

        // Check for errors first
        if (courseDataProvider.error != null ||
            progressProvider.error != null) {
          return _buildErrorCompletedSection(
            context,
            courseDataProvider.error ??
                progressProvider.error ??
                'Unknown error',
          );
        }

        // If no user or no course data, show empty state
        if (userId == null || courseDataProvider.courseData == null) {
          return _buildEmptyCompletedSection(context);
        }

        // Show loading state
        if (courseDataProvider.isLoading || progressProvider.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        try {
          // Get user's progress data
          final userProgress = progressProvider.getAllProgressForUser(userId);

          // Calculate course progress
          final courseWithProgress = CourseWithProgress(
            course: courseDataProvider.courseData!.course,
            courseData: courseDataProvider.courseData!,
            progress: CourseProgressCalculator.calculateCourseProgress(
              courseDataProvider.courseData!,
              userProgress,
            ),
            completedBytes: CourseProgressCalculator.getCompletedByteCount(
              userProgress,
            ),
            totalBytes: courseDataProvider.courseData!.totalByteCount,
          );

          // Only show completed courses
          final completedCourses =
              courseWithProgress.isCompleted
                  ? [courseWithProgress]
                  : <CourseWithProgress>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (completedCourses.isEmpty)
                _buildEmptyCompletedSection(context)
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: completedCourses.length,
                  itemBuilder: (context, index) {
                    final courseProgress = completedCourses[index];
                    return _buildCompletedCourseCard(
                      context,
                      courseWithProgress: courseProgress,
                    );
                  },
                ),
            ],
          );
        } catch (e) {
          debugPrint('Error building completed courses section: $e');
          return _buildErrorCompletedSection(
            context,
            'Failed to load completed courses',
          );
        }
      },
    );
  }

  Widget _buildEmptyCompletedSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'This space awaits your greatness.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCompletedSection(
    BuildContext context,
    String errorMessage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completed',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load completed courses',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedCourseCard(
    BuildContext context, {
    required CourseWithProgress courseWithProgress,
  }) {
    final imagePath = CourseImageHelper.getImageForCourse(
      courseWithProgress.course.title,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Icon centered in top space with completed badge
            Expanded(
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(imagePath, width: 52, height: 52),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Title and completed badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseWithProgress.course.title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Completed',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple icon
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),

            // Sarcastic message
            Text(
              'Nothing to see here',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to unlock your profile and actually see something useful.',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Sign In Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  bottom: BorderSide(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.black,
                    width: 4,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await AuthHelper.showLoginScreen(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 0.5,
        ),
        color: Theme.of(context).cardColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSigningOut ? null : signOut,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child:
                  isSigningOut
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                      : Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetOnboardingButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 0.5),
        color: Theme.of(context).cardColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Reset Onboarding'),
                    content: const Text(
                      'This will sign you out and show the onboarding screens again. Continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
            );

            if (confirmed == true && mounted) {
              final onboardingProvider = context.read<OnboardingProvider>();
              final authProvider = context.read<AuthProvider>();

              await onboardingProvider.resetOnboarding();
              await authProvider.signOut();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                '🔧 Reset Onboarding (Debug)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Privacy Policy Link
          TextButton(
            onPressed: () async {
              final uri = Uri.parse(_privacyPolicyUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open privacy policy'),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Privacy Policy',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Delete Account Button
          TextButton(
            onPressed: isDeletingAccount ? null : deleteAccount,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child:
                isDeletingAccount
                    ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.error.withOpacity(0.6),
                        ),
                      ),
                    )
                    : Text(
                      'Delete Account',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withOpacity(0.6),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
