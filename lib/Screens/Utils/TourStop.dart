import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:mess/Screens/Utils/AppTourController.dart';
import 'package:mess/Screens/Utils/TourTooltipActions.dart';

/// One stop of a feature walkthrough: spotlights [child] with a
/// "Tap here to …" tooltip and the End Tour / step / Next row. The last stop
/// (`step == total`) hands over to the next feature's prompt.
///
/// Pass `enabled: false` to render [child] untouched (e.g. on every list card
/// except the first, since a GlobalKey can only sit on one widget).
Widget tourStop(
  BuildContext context, {
  required GlobalKey key,
  required String tourId,
  required int step,
  required int total,
  required String title,
  required String description,
  required Widget child,
  bool enabled = true,
}) {
  if (!enabled) return child;
  return Showcase(
    key: key,
    title: title,
    description: description,
    titleTextStyle: tourTitleStyle(),
    descTextStyle: tourDescStyle(),
    descriptionPadding: tourDescPadding(),
    tooltipBorderRadius: tourTooltipBorderRadius(),
    tooltipPadding: tourTooltipPadding(),
    targetBorderRadius: tourTargetBorderRadius(),
    targetPadding: tourTargetPadding(),
    overlayColor: tourOverlayColor(),
    overlayOpacity: tourOverlayOpacity(),
    blurValue: tourBlurValue(),
    scaleAnimationDuration: tourScaleAnimationDuration(),
    scaleAnimationCurve: tourScaleAnimationCurve(),
    movingAnimationDuration: tourMovingAnimationDuration(),
    tooltipActionConfig: const TooltipActionConfig(
      alignment: MainAxisAlignment.spaceBetween,
    ),
    tooltipActions: tourTooltipActions(
      context,
      step: step,
      total: total,
      tourId: tourId,
      onDone: () => AppTourController.instance.advanceAfter(tourId, context),
    ),
    child: child,
  );
}

/// The "Tap here to learn X" stop that opens a feature's walkthrough:
/// tapping the highlighted [child] requests [tourId]'s walkthrough and runs
/// [onOpen] (which should navigate to the feature). Tapping anywhere else
/// simply dismisses it.
Widget tourPrompt({
  required GlobalKey key,
  required String tourId,
  required String title,
  required String description,
  required VoidCallback onOpen,
  required Widget child,
}) {
  return Showcase(
    key: key,
    title: title,
    description: description,
    titleTextStyle: tourTitleStyle(),
    descTextStyle: tourDescStyle(),
    descriptionPadding: tourDescPadding(),
    tooltipBorderRadius: tourTooltipBorderRadius(),
    tooltipPadding: tourTooltipPadding(),
    targetBorderRadius: tourTargetBorderRadius(),
    targetPadding: tourTargetPadding(),
    overlayColor: tourOverlayColor(),
    overlayOpacity: tourOverlayOpacity(),
    blurValue: tourBlurValue(),
    scaleAnimationDuration: tourScaleAnimationDuration(),
    scaleAnimationCurve: tourScaleAnimationCurve(),
    movingAnimationDuration: tourMovingAnimationDuration(),
    disposeOnTap: true,
    onTargetClick: () {
      AppTourController.instance.requestedTour = tourId;
      onOpen();
    },
    child: child,
  );
}
