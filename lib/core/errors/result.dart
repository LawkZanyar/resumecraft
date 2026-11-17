import 'failure.dart';

/// The shared success-or-failure type used by every repository and service.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final failure) => failure,
      };

  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final failure) => err(failure),
      };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T>(:final value) => Result.ok(transform(value)),
        Err<T>(:final failure) => Result.err(failure),
      };

  /// Returns the value or throws the [Failure]; handy inside providers.
  T unwrap() => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>(:final failure) => throw failure,
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs [body] and converts any thrown error into an [Err].
Future<Result<T>> guard<T>(
  Future<T> Function() body, {
  Failure Function(Object error)? onError,
}) async {
  try {
    return Result.ok(await body());
  } on Failure catch (f) {
    return Result.err(f);
  } catch (e) {
    return Result.err(
      onError?.call(e) ?? Failure(FailureKind.unknown, 'Something went wrong.', cause: e),
    );
  }
}
