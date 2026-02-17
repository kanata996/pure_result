/// A lightweight `Result` type inspired by Kotlin and Swift.
///
/// Use `Result.success(value)` for success and `Result.failure(error)` for
/// failure, then compose with APIs like `map`, `flatMap`, `recover`, and
/// `fold`.
sealed class Result<T, E extends Object> {
  const Result();

  const factory Result.success(T value) = Success<T, E>;

  const factory Result.failure(E error) = Failure<T, E>;

  bool get isSuccess => this is Success<T, E>;

  bool get isFailure => this is Failure<T, E>;

  T? get valueOrNull => switch (this) {
    Success(value: final value) => value,
    Failure() => null,
  };

  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };

  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) {
    return switch (this) {
      Success(value: final value) => onSuccess(value),
      Failure(error: final error) => onFailure(error),
    };
  }

  T getOrElse(T Function(E error) onFailure) {
    return fold((value) => value, onFailure);
  }

  T getOrDefault(T defaultValue) {
    return fold((value) => value, (_) => defaultValue);
  }

  T getOrThrow() {
    return switch (this) {
      Success(value: final value) => value,
      Failure(error: final error) => throw error,
    };
  }

  Result<R, E> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => Result.success(transform(value)),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => transform(value),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Result<T, F> mapError<F extends Object>(F Function(E error) transform) {
    return switch (this) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => Result.failure(transform(error)),
    };
  }

  Result<T, F> flatMapError<F extends Object>(
    Result<T, F> Function(E error) transform,
  ) {
    return switch (this) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => transform(error),
    };
  }

  Result<R, Object> mapCatching<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => runCatching(() => transform(value)),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Result<T, E> recover(T Function(E error) transform) {
    return switch (this) {
      Success() => this,
      Failure(error: final error) => Result.success(transform(error)),
    };
  }

  Result<T, Object> recoverCatching(T Function(E error) transform) {
    return switch (this) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => runCatching(() => transform(error)),
    };
  }

  Result<T, E> onSuccess(void Function(T value) action) {
    if (this case Success(value: final value)) {
      action(value);
    }
    return this;
  }

  Result<T, E> onFailure(void Function(E error) action) {
    if (this case Failure(error: final error)) {
      action(error);
    }
    return this;
  }
}

final class Success<T, E extends Object> extends Result<T, E> {
  const Success(this.value);

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

final class Failure<T, E extends Object> extends Result<T, E> {
  const Failure(this.error);

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

/// Runs [action] and captures thrown exceptions or errors as `Failure`.
Result<T, Object> runCatching<T>(T Function() action) {
  try {
    return Result.success(action());
  } catch (error) {
    return Result.failure(error);
  }
}
