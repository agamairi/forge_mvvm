/// A type-safe wrapper for operation results that forces callers to handle
/// both success and failure paths — no more silent null returns.
sealed class ForgeResult<T> {
  const ForgeResult();

  factory ForgeResult.success(T data) = ForgeSuccess<T>;
  factory ForgeResult.failure(Exception exception) = ForgeFailure<T>;

  bool get isSuccess => this is ForgeSuccess<T>;
  bool get isFailure => this is ForgeFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Exception exception) failure,
  }) {
    return switch (this) {
      ForgeSuccess<T>(data: final d) => success(d),
      ForgeFailure<T>(exception: final e) => failure(e),
    };
  }

  T? get dataOrNull => switch (this) {
        ForgeSuccess<T>(data: final d) => d,
        ForgeFailure<T>() => null,
      };

  Exception? get exceptionOrNull => switch (this) {
        ForgeSuccess<T>() => null,
        ForgeFailure<T>(exception: final e) => e,
      };
}

final class ForgeSuccess<T> extends ForgeResult<T> {
  const ForgeSuccess(this.data);
  final T data;
}

final class ForgeFailure<T> extends ForgeResult<T> {
  const ForgeFailure(this.exception);
  final Exception exception;
}
