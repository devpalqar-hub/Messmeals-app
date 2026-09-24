import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the guided app tour (a single Showcase sequence run on
/// the Home dashboard — see HomeScreen.dart) has already been shown, so
/// it only auto-starts once per install.
class AppTourController {
  AppTourController._();
  static final AppTourController instance = AppTourController._();

  static const String _seenKey = 'hasSeenAppTour';

  Future<bool> hasSeenTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }
}
