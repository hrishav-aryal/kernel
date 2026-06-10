import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _skipOnboarding() async {
    final provider = context.read<OnboardingProvider>();
    await provider.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2e3338),
          secondary: const Color.fromARGB(255, 119, 120, 231),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2e3338),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFE4E2DD),
        body: SafeArea(
          child: Column(
            children: [
              // Top bar with dots and skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 48,
                  child: Stack(
                    children: [
                      // Page indicators (centered)
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(4, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 32 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color:
                                    _currentPage == index
                                        ? const Color(0xFF2e3338)
                                        : const Color(
                                          0xFF2e3338,
                                        ).withOpacity(0.2),
                              ),
                            );
                          }),
                        ),
                      ),
                      // Skip button (right aligned)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content (slides)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: const [
                    _WelcomeContent(),
                    _LearnContent(),
                    _ProgressContent(),
                    _LoginContent(),
                  ],
                ),
              ),

              // Bottom button (fixed, changes based on page)
              if (_currentPage != 3)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        bottom: BorderSide(
                          color:
                              Color.lerp(
                                const Color.fromARGB(255, 0, 0, 0),
                                Colors.black,
                                0.3,
                              )!,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _nextPage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              _currentPage == 2 ? "Let's Go!" : 'Continue',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE4E2DD),
                              ),
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
      ),
    );
  }
}

// Page 1: Welcome Content
class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset('assets/icon/kernel.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Welcome to Kernel',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Master coding concepts through bite-sized lessons designed for deep understanding.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Page 2: Learn Content
class _LearnContent extends StatelessWidget {
  const _LearnContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: Color(0xFFE4E2DD),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Learn by Doing',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Interactive exercises and real code examples that make learning stick.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Page 3: Progress Content
class _ProgressContent extends StatelessWidget {
  const _ProgressContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1f1f1f),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch_outlined,
              size: 64,
              color: Color(0xFFE4E2DD),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Track Your Progress',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Build your knowledge library and watch your skills grow every day. Currently featuring Python (we\'re working very hard on the rest, promise).',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Page 4: Login Content
class _LoginContent extends StatelessWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App Logo/Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/icon/kernel.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Title
          Text(
            'Ready to Start?',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'Sign in to access lessons and save your progress, or feel free to just explore.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Google Sign-In Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      authProvider.isLoading
                          ? const Color(0xFFE4E2DD).withOpacity(0.7)
                          : const Color(0xFFE4E2DD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    bottom: BorderSide(
                      color:
                          authProvider.isLoading
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                      width: 5,
                    ),
                    top: BorderSide(
                      color:
                          authProvider.isLoading
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                      width: 1,
                    ),
                    left: BorderSide(
                      color:
                          authProvider.isLoading
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                      width: 1,
                    ),
                    right: BorderSide(
                      color:
                          authProvider.isLoading
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        authProvider.isLoading
                            ? null
                            : () async {
                              final authProvider = context.read<AuthProvider>();
                              final onboardingProvider =
                                  context.read<OnboardingProvider>();
                              await onboardingProvider.completeOnboarding();
                              await authProvider.signInWithGoogle();
                            },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (authProvider.isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.login,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          const SizedBox(width: 12),
                          Text(
                            authProvider.isLoading
                                ? 'Signing in...'
                                : 'Continue with Google',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Apple Sign-In Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      authProvider.isLoading
                          ? const Color(0xFFE4E2DD).withOpacity(0.7)
                          : const Color(0xFFE4E2DD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    bottom: BorderSide(
                      color:
                          authProvider.isLoading
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                      width: 5,
                    ),
                    top: BorderSide(
                      color:
                          authProvider.isLoading
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                      width: 1,
                    ),
                    left: BorderSide(
                      color:
                          authProvider.isLoading
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                      width: 1,
                    ),
                    right: BorderSide(
                      color:
                          authProvider.isLoading
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        authProvider.isLoading
                            ? null
                            : () async {
                              final authProvider = context.read<AuthProvider>();
                              final onboardingProvider =
                                  context.read<OnboardingProvider>();
                              await onboardingProvider.completeOnboarding();
                              await authProvider.signInWithApple();
                            },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (authProvider.isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.apple,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          const SizedBox(width: 12),
                          Text(
                            authProvider.isLoading
                                ? 'Signing in...'
                                : 'Continue with Apple',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Error message
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.error != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    authProvider.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
