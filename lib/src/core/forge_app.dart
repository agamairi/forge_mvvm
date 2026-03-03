import 'package:flutter/foundation.dart';
import 'forge_locator.dart';

/// Entry point for bootstrapping the forge_mvvm framework.
///
/// Call [ForgeApp.setUp] in your `main()` before [runApp]:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await ForgeApp.setUp(
///     services: [() => ApiService()],
///     repositories: [() => UserRepository(ForgeLocator.get<ApiService>())],
///   );
///   runApp(const MyApp());
/// }
/// ```
class ForgeApp {
  ForgeApp._();

  static bool _initialized = false;

  /// Bootstraps the DI container in the correct layer order:
  /// Services first (innermost), then Repositories.
  /// ViewModels are resolved per-screen via [ForgeView.createViewModel].
  static Future<void> setUp({
    List<Object Function()> services = const [],
    List<Object Function()> repositories = const [],
    bool resetForTesting = false,
  }) async {
    if (_initialized && !resetForTesting) {
      throw StateError(
        '[forge_mvvm] ForgeApp.setUp() was already called. '
        'Pass resetForTesting: true in test environments.',
      );
    }

    if (resetForTesting) {
      ForgeLocator.reset();
      _initialized = false;
    }

    for (final factory in services) {
      ForgeLocator.registerLazySingleton(factory);
    }

    for (final factory in repositories) {
      ForgeLocator.registerLazySingleton(factory);
    }

    _initialized = true;

    if (kDebugMode) {
      debugPrint('[forge_mvvm] ForgeApp initialised — '
          '\${services.length} service(s), '
          '\${repositories.length} repository(ies) registered.');
    }
  }

  static bool get isInitialized => _initialized;
}
