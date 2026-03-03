import '../core/forge_app.dart';
import '../ui/forge_viewmodel.dart';

/// Test utility that manages DI reset and ViewModel lifecycle.
///
/// Usage in tests:
/// ```dart
/// final harness = ForgeTestHarness();
/// setUp(() => harness.setUp());
/// tearDown(() => harness.tearDown());
/// ```
class ForgeTestHarness {
  /// Resets DI registrations so each test starts with a clean slate.
  Future<void> setUp() async {
    await ForgeApp.setUp(resetForTesting: true);
  }

  /// Resets DI registrations on tear-down.
  Future<void> tearDown() async {
    await ForgeApp.setUp(resetForTesting: true);
  }

  /// Calls [ForgeViewModel.onInit] the same way [ForgeView] does on mount.
  void initViewModel(ForgeViewModel vm) => vm.onInit();
}
