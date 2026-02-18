import 'result.dart';

/// Captured error value and stack trace from a thrown exception/error.
final class CaughtError {
  /// Creates a captured error with its [stackTrace].
  const CaughtError(this.error, this.stackTrace);

  /// The thrown object.
  final Object error;

  /// The stack trace captured when [error] was thrown.
  final StackTrace stackTrace;

  @override
  bool operator ==(Object other) {
    return other is CaughtError && other.error == error;
  }

  @override
  int get hashCode => Object.hash(CaughtError, error);

  @override
  String toString() => 'CaughtError(error: $error, stackTrace: $stackTrace)';
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
