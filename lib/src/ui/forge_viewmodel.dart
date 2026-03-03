import 'package:flutter/foundation.dart';

/// Abstract base class for all ViewModels in a forge_mvvm application.
abstract class ForgeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDisposed => _isDisposed;

  void onInit() {}
  void onDispose() {}

  @protected
  void setLoading(bool value) {
    if (_isDisposed) return;
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  @protected
  void setError(String message) {
    if (_isDisposed) return;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  @protected
  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  Future<void> runBusyAction(Future<void> Function() action) async {
    setLoading(true);
    try {
      await action();
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      if (!_isDisposed) setLoading(false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    onDispose();
    super.dispose();
  }
}
