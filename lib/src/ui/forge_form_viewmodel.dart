import 'forge_viewmodel.dart';

/// Base ViewModel for forms with per-field validation.
///
/// Usage:
/// ```dart
/// class LoginFormViewModel extends ForgeFormViewModel {
///   String email = '';
///   String password = '';
///
///   @override
///   bool validateAll() {
///     setFieldError('email', email.isEmpty ? 'Required' : null);
///     setFieldError('password', password.length < 6 ? 'Min 6 chars' : null);
///     return isValid;
///   }
/// }
/// ```
///
/// In your view:
/// ```dart
/// TextField(
///   decoration: InputDecoration(errorText: vm.errorFor('email')),
///   onChanged: (v) { vm.email = v; },
/// )
/// ElevatedButton(
///   onPressed: () { if (vm.validateAll()) vm.submit(); },
///   child: const Text('Submit'),
/// )
/// ```
abstract class ForgeFormViewModel extends ForgeViewModel {
  final Map<String, String?> _fieldErrors = <String, String?>{};

  /// Unmodifiable view of all field errors.
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);

  /// True when validateAll() has been called and no field has an error.
  bool get isValid =>
      _fieldErrors.isNotEmpty &&
      _fieldErrors.values.every((v) => v == null);

  /// Implement to validate all fields at once.
  bool validateAll();

  /// Set or clear the error for [key]. Pass null to clear.
  void setFieldError(String key, String? message) {
    _fieldErrors[key] = message;
    notifyListeners();
  }

  /// Returns the current error for [key], or null.
  String? errorFor(String key) => _fieldErrors[key];

  /// Clears all field errors.
  void clearFieldErrors() {
    _fieldErrors.clear();
    notifyListeners();
  }
}
