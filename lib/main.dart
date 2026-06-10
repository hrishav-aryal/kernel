import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kernel/screens/core/main_navigation_screen.dart';
import 'package:kernel/screens/onboarding/onboarding_screen.dart';
import 'package:kernel/providers/auth_provider.dart';
import 'package:kernel/providers/course_data_provider.dart';
import 'package:kernel/providers/theme_provider.dart';
import 'package:kernel/providers/onboarding_provider.dart';
import 'package:kernel/theme/app_theme.dart';
import 'package:kernel/config/supabase_config.dart';
import 'package:kernel/_deprecated/saved_bytes_provider.dart';
import 'package:kernel/_deprecated/byte_progress_provider.dart';
import 'package:kernel/providers/course_byte_progress_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  runApp(const KernelApp());
}

class KernelApp extends StatefulWidget {
  const KernelApp({super.key});

  @override
  State<KernelApp> createState() => _KernelAppState();
}

class _KernelAppState extends State<KernelApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => CourseDataProvider()),
        ChangeNotifierProvider(create: (_) => SavedBytesProvider()),
        ChangeNotifierProvider(create: (_) => ByteProgressProvider()),
        ChangeNotifierProvider(create: (_) => CourseByteProgressProvider()),
      ],
      child: const _KernelAppContent(),
    );
  }
}

class _KernelAppContent extends StatefulWidget {
  const _KernelAppContent();

  @override
  State<_KernelAppContent> createState() => _KernelAppContentState();
}

class _KernelAppContentState extends State<_KernelAppContent> {
  @override
  void initState() {
    super.initState();
    // Set up the callback after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      final themeProvider = context.read<ThemeProvider>();
      final progressProvider = context.read<CourseByteProgressProvider>();

      // Set up callback to initialize theme when user changes
      authProvider.onUserChanged = (user) {
        themeProvider.initializeTheme(user);
      };

      // Set up callback to load progress when user signs in/out
      authProvider.onUserSignedIn = (userId) {
        if (userId.isEmpty) {
          // User signed out - clear progress cache
          progressProvider.clearAllProgress();
        } else {
          // User signed in - load their progress
          progressProvider.loadProgressForUser(userId);
        }
      };

      // Initialize theme with current user
      themeProvider.initializeTheme(authProvider.user);

      // Load progress for current user if authenticated
      if (authProvider.user?.id != null) {
        progressProvider.loadProgressForUser(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, OnboardingProvider, AuthProvider>(
      builder: (
        context,
        themeProvider,
        onboardingProvider,
        authProvider,
        child,
      ) {
        // Show loading screen while checking onboarding status or during auth transitions
        if (onboardingProvider.isLoading || authProvider.isLoading) {
          return MaterialApp(
            title: 'Kernel',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Safeguard: If user is authenticated but onboarding isn't marked complete,
        // auto-complete onboarding to prevent showing onboarding screen to logged-in users
        // This handles edge cases and race conditions
        if (authProvider.isAuthenticated && 
            authProvider.user != null && 
            !onboardingProvider.hasCompletedOnboarding) {
          // Schedule onboarding completion for next frame to avoid build-time side effects
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              onboardingProvider.completeOnboarding();
            }
          });
        }

        // Key based on auth state to force full app rebuild on auth change
        final appKey = Key(authProvider.user?.id ?? 'anonymous');

        return MaterialApp(
          key: appKey,
          title: 'Kernel',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home:
              onboardingProvider.hasCompletedOnboarding
                  ? const MainNavigationScreen()
                  : const OnboardingScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
