/// Base class for all domain-level exceptions in a forge_mvvm application.
class ForgeException implements Exception {
  const ForgeException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code != null
      ? 'ForgeException[$code]: $message'
      : 'ForgeException: $message';
}

class ForgeNetworkException extends ForgeException {
  const ForgeNetworkException(super.message, {super.code});
}

class ForgeServerException extends ForgeException {
  const ForgeServerException(super.message, {super.code});
}

class ForgeCacheException extends ForgeException {
  const ForgeCacheException(super.message, {super.code});
}

class ForgeValidationException extends ForgeException {
  const ForgeValidationException(super.message, {super.code});
}
