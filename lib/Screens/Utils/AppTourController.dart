import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:mess/Screens/Utils/TourKeys.dart';

/// Tracks the guided tours and hands the owner from one to the next.
///
/// There is one Home tour ([homeTour], see HomeScreen.dart) that points at
/// every feature once, then one walkthrough per feature that teaches that
/// feature's own flow ([featureTours], in the order they run). After the
/// Home tour's full circle, the tour comes back to the first feature and
/// asks the owner to tap it ("prompt"); tapping opens that feature and its
/// walkthrough runs; when it finishes, the tour moves on to the next
/// feature's prompt, and so on until the last one.
class AppTourController {
  AppTourController._();
  static final AppTourController instance = AppTourController._();

  static const String homeTour = 'home';
  static const String menuTour = 'menu';
  static const String plansTour = 'plans';
  static const String partnersTour = 'partners';
  static const String customersTour = 'customers';
  static const String deliveriesTour = 'deliveries';
  static const String expensesTour = 'expenses';
  static const String settingsTour = 'settings';

  /// Feature walkthroughs, in the order they run after the Home tour.
  static const List<String> featureTours = [
    menuTour,
    plansTour,
    partnersTour,
    customersTour,
    deliveriesTour,
    expensesTour,
    settingsTour,
  ];

  /// TESTING SWITCH — while true, every tour shows on every app launch
  /// (as if it was never seen), so tour changes can be checked without
  /// reinstalling. Set to false to go back to "show once per install".
  /// MUST be false in a release build.
  static const bool alwaysShowTours = true;

  /// The feature walkthrough the owner just asked for by tapping its
  /// prompt. The destination screen consumes it via [startIfRequested].
  String? requestedTour;

  /// Switches the dashboard's bottom-nav tab. Set by DashboardScreen so the
  /// tour can bring the owner back to Home between features.
  void Function(int index)? selectTab;

  // The home tour keeps its original key so existing installs that already
  // finished it don't see it again.
  String _key(String id) =>
      id == homeTour ? 'hasSeenAppTour' : 'hasSeenTour_$id';

  Future<bool> hasSeenTour([String id = homeTour]) async {
    if (alwaysShowTours) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(id)) ?? false;
  }

  Future<void> markSeen([String id = homeTour]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(id), true);
  }

  /// Called by a feature screen on every rebuild. If the owner asked for
  /// this screen's walkthrough, starts it with [keys] (post-frame, so the
  /// targets are laid out). The request is consumed synchronously first,
  /// since this runs on every rebuild and must only start once.
  Future<void> startIfRequested(
    BuildContext context,
    String id,
    List<GlobalKey> keys,
  ) async {
    if (requestedTour != id) return;
    requestedTour = null;

    if (await hasSeenTour(id)) return;
    await markSeen(id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) ShowCaseWidget.of(context).startShowCase(keys);
    });
  }

  /// Runs after a walkthrough's last stop: moves on to the next feature's
  /// prompt. Screens pushed on top of the dashboard (Expenses, Settings)
  /// are popped first so the prompt has its target on screen.
  ///
  /// [from] is the context the finished stop was built in. It's preferred
  /// over the app-wide navigator context because it is known to sit under
  /// the root ShowCaseWidget — the Home tour's hand-over to the Menu prompt
  /// works the same way. After popping a pushed screen it's unmounted, so
  /// the navigator context is the fallback.
  void advanceAfter(String id, [BuildContext? from]) {
    final i = featureTours.indexOf(id);
    if (i < 0) return;

    final pushedScreen = id == expensesTour || id == settingsTour;
    if (pushedScreen) Get.back();

    if (i + 1 >= featureTours.length) return; // last walkthrough — all done

    final next = featureTours[i + 1];
    // The Expenses and Settings prompts sit on the Home dashboard, so make
    // sure the Home tab is showing (the tab bar is on every tab; these two
    // targets are not).
    if (next == expensesTour) selectTab?.call(0);

    Future.delayed(const Duration(milliseconds: 900), () {
      final context = (from != null && from.mounted) ? from : Get.context;
      if (context == null || !context.mounted) {
        debugPrint('TOUR: no usable context to start the $next prompt');
        return;
      }
      try {
        ShowCaseWidget.of(context).startShowCase([TourKeys.promptFor(next)]);
      } catch (e) {
        debugPrint('TOUR: could not start the $next prompt: $e');
      }
    });
  }
}
