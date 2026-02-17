import 'package:flutter_test/flutter_test.dart';
import 'package:pure_result/async_result.dart';
import 'package:pure_result/pure_result.dart';

import 'test_types.dart';

void main() {
  group('AsyncResultOps', () {
    test('map and flatMap chain on Future<Result>', () async {
      final result = await Future.value(const Result<int, TestError>.success(2))
          .map((value) => value + 1)
          .flatMap((value) => Result<String, TestError>.success('v:$value'));

      expect(result, const Result<String, TestError>.success('v:3'));
    });

    test('map passes through failure without running transform', () async {
      var called = false;

      final result =
          await Future.value(
            const Result<int, TestError>.failure(TestError('x')),
          ).map((value) {
            called = true;
            return value + 1;
          });

      expect(result, const Result<int, TestError>.failure(TestError('x')));
      expect(called, isFalse);
    });

    test('flatMap passes through failure without running transform', () async {
      var called = false;

      final result =
          await Future.value(
            const Result<int, TestError>.failure(TestError('x')),
          ).flatMap((value) {
            called = true;
            return Result<String, TestError>.success('v:$value');
          });

      expect(result, const Result<String, TestError>.failure(TestError('x')));
      expect(called, isFalse);
    });

    test('mapError and recover chain on Future<Result>', () async {
      final result = await Future.value(
        const Result<int, TestError>.failure(TestError('x')),
      ).mapError((error) => error.message.length).recover((_) => 9);

      expect(result, const Result<int, int>.success(9));
    });

    test('flatMapError transforms failure on Future<Result>', () async {
      final result = await Future.value(
        const Result<int, TestError>.failure(TestError('xyz')),
      ).flatMapError((error) => Result<int, int>.failure(error.message.length));

      expect(result, const Result<int, int>.failure(3));
    });

    test(
      'flatMapError passes through success without running transform',
      () async {
        var called = false;

        final result =
            await Future.value(
              const Result<int, TestError>.success(7),
            ).flatMapError((error) {
              called = true;
              return Result<int, int>.failure(error.message.length);
            });

        expect(result, const Result<int, int>.success(7));
        expect(called, isFalse);
      },
    );

    test('map propagates exceptions from transform', () async {
      final future = Future.value(const Result<int, TestError>.success(1))
          .map<int>((_) {
            throw StateError('map explode');
          });

      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('flatMap propagates exceptions from transform', () async {
      final future = Future.value(const Result<int, TestError>.success(1))
          .flatMap<int>((_) {
            throw StateError('flatMap explode');
          });

      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('mapError propagates exceptions from transform', () async {
      final future =
          Future.value(
            const Result<int, TestError>.failure(TestError('x')),
          ).mapError<int>((_) {
            throw StateError('mapError explode');
          });

      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('flatMapError propagates exceptions from transform', () async {
      final future =
          Future.value(
            const Result<int, TestError>.failure(TestError('x')),
          ).flatMapError<int>((_) {
            throw StateError('flatMapError explode');
          });

      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('recover propagates exceptions from transform', () async {
      final future =
          Future.value(
            const Result<int, TestError>.failure(TestError('x')),
          ).recover((_) {
            throw StateError('recover explode');
          });

      await expectLater(future, throwsA(isA<StateError>()));
    });
  });
}
