import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';

  bool _hasCompletedOnboarding = false;
  bool _isLoading = true;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;

  OnboardingProvider() {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding =
          prefs.getBool(_hasCompletedOnboardingKey) ?? false;
    } catch (e) {
      debugPrint('Error loading onboarding status: $e');
      _hasCompletedOnboarding = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasCompletedOnboardingKey, true);
      _hasCompletedOnboarding = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving onboarding status: $e');
    }
  }

  // For testing purposes - reset onboarding
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hasCompletedOnboardingKey);
      _hasCompletedOnboarding = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting onboarding: $e');
    }
  }
}
