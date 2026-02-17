import 'dart:async';

import 'result.dart';

extension AsyncResultOps<T, E extends Object> on Future<Result<T, E>> {
  Future<Result<R, E>> map<R>(FutureOr<R> Function(T value) transform) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => Result.success(await transform(value)),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<R, E>> flatMap<R>(
    FutureOr<Result<R, E>> Function(T value) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => await transform(value),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<Result<T, F>> mapError<F extends Object>(
    FutureOr<F> Function(E error) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => Result.failure(await transform(error)),
    };
  }

  Future<Result<T, E>> recover(FutureOr<T> Function(E error) transform) async {
    final result = await this;
    return switch (result) {
      Success() => result,
      Failure(error: final error) => Result.success(await transform(error)),
    };
  }

  Future<Result<T, E>> onSuccess(
    FutureOr<void> Function(T value) action,
  ) async {
    final result = await this;
    if (result case Success(value: final value)) {
      await action(value);
    }
    return result;
  }

  Future<Result<T, E>> onFailure(
    FutureOr<void> Function(E error) action,
  ) async {
    final result = await this;
    if (result case Failure(error: final error)) {
      await action(error);
    }
    return result;
  }
}
