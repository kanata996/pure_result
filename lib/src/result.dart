/// A lightweight `Result` type inspired by Kotlin and Swift.
///
/// Use `Result.success(value)` for success and `Result.failure(error)` for
/// failure, then compose with APIs like `map`, `flatMap`, `recover`, and
/// `fold`.
sealed class Result<T, E extends Object> {
  /// Base constructor for [Result] variants.
  const Result();

  /// Creates a successful [Result] containing [value].
  const factory Result.success(T value) = Success<T, E>;

  /// Creates a failed [Result] containing [error].
  const factory Result.failure(E error) = Failure<T, E>;

  /// Whether this instance is a [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Whether this instance is a [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// Returns the success value, or `null` when this is a failure.
  T? get valueOrNull => switch (this) {
    Success(value: final value) => value,
    Failure() => null,
  };

  /// Returns the failure error, or `null` when this is a success.
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };

  /// Maps this result to a single value by handling both cases.
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) {
    return switch (this) {
      Success(value: final value) => onSuccess(value),
      Failure(error: final error) => onFailure(error),
    };
  }

  /// Named-parameter variant of [fold] for improved readability.
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) {
    return fold(success, failure);
  }

  /// Returns the success value, or computes a fallback from the error.
  T getOrElse(T Function(E error) onFailure) {
    return fold((value) => value, onFailure);
  }

  /// Returns the success value, or throws the contained failure error.
  T getOrThrow() {
    return switch (this) {
      Success(value: final value) => value,
      Failure(error: final error) => throw error,
    };
  }

  /// Transforms the success value while preserving the error type.
  Result<R, E> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => Result.success(transform(value)),
      Failure(error: final error) => Result.failure(error),
    };
  }

  /// Chains another [Result]-producing transform on success.
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => transform(value),
      Failure(error: final error) => Result.failure(error),
    };
  }

  /// Transforms the failure error while preserving the success type.
  Result<T, F> mapError<F extends Object>(F Function(E error) transform) {
    return switch (this) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => Result.failure(transform(error)),
    };
  }

  /// Chains another [Result]-producing transform on failure.
  Result<T, F> flatMapError<F extends Object>(
    Result<T, F> Function(E error) transform,
  ) {
    return switch (this) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => transform(error),
    };
  }

  /// Converts a failure into success using [transform].
  Result<T, E> recover(T Function(E error) transform) {
    return switch (this) {
      Success() => this,
      Failure(error: final error) => Result.success(transform(error)),
    };
  }
}

/// Success variant of [Result] that stores a value.
final class Success<T, E extends Object> extends Result<T, E> {
  /// Creates a success value.
  const Success(this.value);

  /// The wrapped success value.
  final T value;

  @override
  bool operator ==(Object other) {
    return other is Success<T, E> && other.value == value;
  }

  @override
  int get hashCode => Object.hash(Success, value);

  @override
  String toString() => 'Success($value)';
}

/// Failure variant of [Result] that stores an error.
final class Failure<T, E extends Object> extends Result<T, E> {
  /// Creates a failure value.
  const Failure(this.error);

  /// The wrapped failure error.
  final E error;

  @override
  bool operator ==(Object other) {
    return other is Failure<T, E> && other.error == error;
  }

  @override
  int get hashCode => Object.hash(Failure, error);

  @override
  String toString() => 'Failure($error)';
}
