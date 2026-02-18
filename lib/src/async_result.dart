import 'dart:async';

import 'result.dart';

/// Async composition helpers for `Future<Result<T, E>>`.
extension AsyncResultOps<T, E extends Object> on Future<Result<T, E>> {
  /// Transforms a success value with a sync or async [transform].
  Future<Result<R, E>> map<R>(FutureOr<R> Function(T value) transform) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => Result.success(await transform(value)),
      Failure(error: final error) => Result.failure(error),
    };
  }

  /// Chains another `Result`-producing sync or async transform on success.
  Future<Result<R, E>> flatMap<R>(
    FutureOr<Result<R, E>> Function(T value) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => await transform(value),
      Failure(error: final error) => Result.failure(error),
    };
  }

  /// Transforms a failure error with a sync or async [transform].
  Future<Result<T, F>> mapError<F extends Object>(
    FutureOr<F> Function(E error) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => Result.failure(await transform(error)),
    };
  }

  /// Chains another `Result`-producing sync or async transform on failure.
  Future<Result<T, F>> flatMapError<F extends Object>(
    FutureOr<Result<T, F>> Function(E error) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => await transform(error),
    };
  }

  /// Converts a failure into success using a sync or async fallback.
  Future<Result<T, E>> recover(FutureOr<T> Function(E error) transform) async {
    final result = await this;
    return switch (result) {
      Success() => result,
      Failure(error: final error) => Result.success(await transform(error)),
    };
  }
}
