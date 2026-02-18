import 'result.dart';

/// Captured error value and stack trace from a thrown exception/error.
final class CaughtError {
  const CaughtError(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => 'CaughtError(error: $error, stackTrace: $stackTrace)';
}

extension TryResultOps<T, E extends Object> on Result<T, E> {
  Result<R, Object> tryMapSync<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => tryRunSync(() => transform(value)),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<R, Object>> tryMap<R>(
    Future<R> Function(T value) transform,
  ) {
    return switch (this) {
      Success(value: final value) => tryRun(() => transform(value)),
      Failure(error: final error) =>
        Future.value(Result<R, Object>.failure(error)),
    };
  }

  Result<T, Object> tryRecoverSync(T Function(E error) transform) {
    return switch (this) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => tryRunSync(() => transform(error)),
    };
  }

  Future<Result<T, Object>> tryRecover(
    Future<T> Function(E error) transform,
  ) {
    return switch (this) {
      Success(value: final value) =>
        Future.value(Result<T, Object>.success(value)),
      Failure(error: final error) => tryRun(() => transform(error)),
    };
  }
}

/// Runs [action] and captures thrown exceptions/errors as [CaughtError].
Result<T, CaughtError> tryRunSync<T>(T Function() action) {
  try {
    return Result.success(action());
  } catch (error, stackTrace) {
    return Result.failure(CaughtError(error, stackTrace));
  }
}

/// Runs async [action] and captures thrown exceptions/errors as [CaughtError].
Future<Result<T, CaughtError>> tryRun<T>(Future<T> Function() action) async {
  try {
    return Result.success(await action());
  } catch (error, stackTrace) {
    return Result.failure(CaughtError(error, stackTrace));
  }
}
