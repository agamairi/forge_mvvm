import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

// ── Navigation events ─────────────────────────────────────────────────────────

/// Base class for all navigation events emitted by ViewModels.
///
/// ViewModels NEVER hold a BuildContext. Instead they push a
/// [NavigationEvent] into a stream; the View layer listens and
/// calls [ForgeNavigator.handle].
///
/// This mirrors the iOS Coordinator / Router pattern.
sealed class NavigationEvent {
  const NavigationEvent();
}

/// Push a new route onto the stack (back button remains).
class PushRoute extends NavigationEvent {
  const PushRoute(this.location);
  final String location;
}

/// Replace the current stack with a new route (no back button).
class ReplaceRoute extends NavigationEvent {
  const ReplaceRoute(this.location);
  final String location;
}

/// Pop the top route off the stack.
class PopRoute extends NavigationEvent {
  const PopRoute();
}

// ── ForgeNavigator ────────────────────────────────────────────────────────────

/// Handles [NavigationEvent]s using [GoRouter].
///
/// Register via [ForgeLocator]:
/// ```dart
/// ForgeLocator.registerSingleton<ForgeNavigator>(ForgeNavigator(router));
/// ```
///
/// In a ForgeView, listen to the ViewModel stream:
/// ```dart
/// _viewModel.navigationEvents.listen((e) {
///   ForgeLocator.get<ForgeNavigator>().handle(e, context);
/// });
/// ```
class ForgeNavigator {
  ForgeNavigator(this._router);

  final GoRouter _router;

  void handle(NavigationEvent event, BuildContext context) {
    switch (event) {
      case PushRoute(:final location):
        _router.push(location);
      case ReplaceRoute(:final location):
        _router.go(location);
      case PopRoute():
        if (_router.canPop()) {
          _router.pop();
        } else {
          Navigator.of(context).maybePop();
        }
    }
  }
}
