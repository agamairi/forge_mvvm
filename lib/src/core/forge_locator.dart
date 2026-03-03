import 'package:get_it/get_it.dart';

/// Thin wrapper around [GetIt] that enforces clean architecture layer rules.
///
/// Never call [GetIt.instance] directly in your app code.
/// Always use [ForgeLocator] so layer boundaries are respected.
class ForgeLocator {
  ForgeLocator._();

  static final GetIt _sl = GetIt.instance;

  /// Retrieves a registered instance of type [T].
  ///
  /// Throws an assertion error if [T] was not registered in [ForgeApp.setUp].
  static T get<T extends Object>() {
    assert(
      _sl.isRegistered<T>(),
      '[forge_mvvm] \${T.toString()} is not registered. '
      'Did you add it to ForgeApp.setUp()?',
    );
    return _sl.get<T>();
  }

  /// Registers a lazy singleton — instance is created on first [get] call.
  /// Called by [ForgeApp.setUp]; also available for advanced use.
  static void registerLazySingleton<T extends Object>(T Function() factory) {
    if (!_sl.isRegistered<T>()) {
      _sl.registerLazySingleton<T>(factory);
    }
  }

  /// Registers a factory — a new instance is created on every [get] call.
  static void registerFactory<T extends Object>(T Function() factory) {
    _sl.registerFactory<T>(factory);
  }

  /// Registers an already-created singleton instance.
  static void registerSingleton<T extends Object>(T instance) {
    _sl.registerSingleton<T>(instance);
  }

  /// Resets all registrations.
  /// Only call this via [ForgeApp.setUp(resetForTesting: true)] in tests.
  static void reset() => _sl.reset();
}
