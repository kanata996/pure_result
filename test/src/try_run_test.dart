import 'package:flutter_test/flutter_test.dart';
import 'package:pure_result/pure_result.dart';

import 'support/test_types.dart';

void main() {
  group('tryRunSync', () {
    test('returns success when no exception', () {
      final result = tryRunSync(() => 'ok');

      expect(result, const Result<String, CaughtError>.success('ok'));
    });

    test('returns failure when exception is thrown', () {
      final result = tryRunSync<String>(() {
        throw StateError('oops');
      });

      expect(result.isFailure, isTrue);
      final caught = result.errorOrNull;
      expect(caught, isA<CaughtError>());
      expect(caught!.error, isA<StateError>());
      expect(caught.stackTrace.toString(), isNotEmpty);
    });
  });

  group('tryRun', () {
    test('returns success when no exception', () async {
      final result = await tryRun(() async => 'ok');

      expect(result, const Result<String, CaughtError>.success('ok'));
    });

    test('returns failure when exception is thrown', () async {
      final result = await tryRun<String>(() async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('oops');
      });

      expect(result.isFailure, isTrue);
      final caught = result.errorOrNull;
      expect(caught, isA<CaughtError>());
      expect(caught!.error, isA<StateError>());
      expect(caught.stackTrace.toString(), isNotEmpty);
    });

    test('returns failure when action throws synchronously', () async {
      final result = await tryRun<String>(() {
        throw StateError('sync oops');
      });

      expect(result.isFailure, isTrue);
      final caught = result.errorOrNull;
      expect(caught, isA<CaughtError>());
      expect(caught!.error, isA<StateError>());
      expect(caught.stackTrace.toString(), isNotEmpty);
    });

    test('returns failure when Error is thrown', () async {
      final result = await tryRun<String>(() async {
        throw TestPanic();
      });

      expect(result.isFailure, isTrue);
      final caught = result.errorOrNull;
      expect(caught, isA<CaughtError>());
      expect(caught!.error, isA<TestPanic>());
      expect(caught.stackTrace.toString(), isNotEmpty);
    });
  });
}
