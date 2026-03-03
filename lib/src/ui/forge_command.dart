import 'package:flutter/foundation.dart';

/// Wraps an async action, tracking its running/error state.
/// Prevents double-submission automatically.
class ForgeCommand<T> extends ChangeNotifier {
  ForgeCommand(this._action);

  final Future<void> Function(T? param) _action;

  bool _isRunning = false;
  Exception? _lastException;

  bool get isRunning => _isRunning;
  Exception? get lastException => _lastException;
  bool get hasError => _lastException != null;

  Future<void> execute([T? param]) async {
    if (_isRunning) return;
    _isRunning = true;
    _lastException = null;
    notifyListeners();
    try {
      await _action(param);
    } on Exception catch (e) {
      _lastException = e;
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }
}
