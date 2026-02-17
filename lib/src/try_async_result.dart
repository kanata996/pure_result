import 'dart:async';

import 'result.dart';
import 'try_result.dart';

extension TryAsyncResultOps<T, E extends Object> on Future<Result<T, E>> {
  Future<Result<Result<T, E>, CaughtError>> _resolveResult() {
    return tryRun(() async => await this);
  }

  Future<Result<R, CaughtError>> _tryCall<R>(FutureOr<R> Function() action) {
    return tryRun(() async => await action());
  }

  Future<Result<R, Object>> tryMap<R>(
    FutureOr<R> Function(T value) transform,
  ) async {
    final resolved = await _resolveResult();
    return switch (resolved) {
      Success(value: final result) => result.tryMap(
        (value) async => await transform(value),
      ),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<R, Object>> tryFlatMap<R>(
    FutureOr<Result<R, E>> Function(T value) transform,
  ) async {
    final resolved = await _resolveResult();
    return switch (resolved) {
      Success(value: final result) => switch (result) {
        Success(value: final value) => switch (await _tryCall(
          () => transform(value),
        )) {
          Success(value: final transformed) => transformed,
          Failure(error: final error) => Result.failure(error),
        },
        Failure(error: final error) => Result.failure(error),
      },
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<T, Object>> tryMapError<F extends Object>(
    FutureOr<F> Function(E error) transform,
  ) async {
    final resolved = await _resolveResult();
    return switch (resolved) {
      Success(value: final result) => switch (result) {
        Success(value: final value) => Result.success(value),
        Failure(error: final error) => switch (await _tryCall(
          () => transform(error),
        )) {
          Success(value: final transformedError) => Result.failure(
            transformedError,
          ),
          Failure(error: final caught) => Result.failure(caught),
        },
      },
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<T, Object>> tryFlatMapError<F extends Object>(
    FutureOr<Result<T, F>> Function(E error) transform,
  ) async {
    final resolved = await _resolveResult();
    return switch (resolved) {
      Success(value: final result) => switch (result) {
        Success(value: final value) => Result.success(value),
        Failure(error: final error) => switch (await _tryCall(
          () => transform(error),
        )) {
          Success(value: final transformed) => transformed,
          Failure(error: final caught) => Result.failure(caught),
        },
      },
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<T, Object>> tryRecover(
    FutureOr<T> Function(E error) transform,
  ) async {
    final resolved = await _resolveResult();
    return switch (resolved) {
      Success(value: final result) => result.tryRecover(
        (error) async => await transform(error),
      ),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<T, Object>> tryOnSuccess(
    FutureOr<void> Function(T value) action,
  ) async {
    final resolved = await _resolveResult();
    return switch (resolved) {
      Success(value: final result) => switch (result) {
        Success(value: final value) => switch (await _tryCall(
          () => action(value),
        )) {
          Success() => Result.success(value),
          Failure(error: final error) => Result.failure(error),
        },
        Failure(error: final error) => Result.failure(error),
      },
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<T, Object>> tryOnFailure(
    FutureOr<void> Function(E error) action,
  ) async {
    final resolved = await _resolveResult();
    return switch (resolved) {
      Success(value: final result) => switch (result) {
        Success(value: final value) => Result.success(value),
        Failure(error: final error) => switch (await _tryCall(
          () => action(error),
        )) {
          Success() => Result.failure(error),
          Failure(error: final caught) => Result.failure(caught),
        },
      },
      Failure(error: final error) => Result.failure(error),
    };
  }
}
