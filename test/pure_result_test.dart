import 'package:flutter_test/flutter_test.dart';
import 'package:pure_result/pure_result.dart';

void main() {
  group('Result state', () {
    test('success exposes value', () {
      const result = Result<int, _TestError>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, isNull);
    });

    test('failure exposes error', () {
      const error = _TestError('boom');
      const result = Result<int, _TestError>.failure(error);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, error);
    });
  });

  group('Result extraction', () {
    test('fold routes to correct branch', () {
      const success = Result<int, _TestError>.success(2);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      final successText = success.fold(
        (value) => 'ok:$value',
        (error) => 'err:${error.message}',
      );
      final failureText = failure.fold(
        (value) => 'ok:$value',
        (error) => 'err:${error.message}',
      );

      expect(successText, 'ok:2');
      expect(failureText, 'err:x');
    });

    test('getOrElse and getOrDefault', () {
      const success = Result<int, _TestError>.success(10);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      expect(success.getOrElse((_) => -1), 10);
      expect(failure.getOrElse((_) => -1), -1);
      expect(success.getOrDefault(99), 10);
      expect(failure.getOrDefault(99), 99);
    });

    test('getOrThrow returns value or throws', () {
      const success = Result<int, _TestError>.success(7);
      const failure = Result<int, _TestError>.failure(_TestError('broken'));

      expect(success.getOrThrow(), 7);
      expect(() => failure.getOrThrow(), throwsA(isA<_TestError>()));
    });
  });

  group('Result transform', () {
    test('map and flatMap transform success only', () {
      const success = Result<int, _TestError>.success(3);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      final mapped = success.map((value) => value * 2);
      final mappedFailure = failure.map((value) => value * 2);

      final flatMapped = success.flatMap(
        (value) => Result<String, _TestError>.success('v:$value'),
      );
      final flatMappedFailure = failure.flatMap(
        (value) => Result<String, _TestError>.success('v:$value'),
      );

      expect(mapped, const Result<int, _TestError>.success(6));
      expect(mappedFailure.isFailure, isTrue);
      expect(flatMapped, const Result<String, _TestError>.success('v:3'));
      expect(flatMappedFailure.isFailure, isTrue);
    });

    test('mapError and flatMapError transform failure only', () {
      const success = Result<int, _TestError>.success(5);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      final mappedSuccess = success.mapError((error) => error.message.length);
      final mappedFailure = failure.mapError((error) => error.message.length);

      final flatMappedSuccess = success.flatMapError(
        (error) => Result<int, int>.failure(error.message.length),
      );
      final flatMappedFailure = failure.flatMapError(
        (error) => Result<int, int>.failure(error.message.length),
      );

      expect(mappedSuccess, const Result<int, int>.success(5));
      expect(mappedFailure, const Result<int, int>.failure(1));
      expect(flatMappedSuccess, const Result<int, int>.success(5));
      expect(flatMappedFailure, const Result<int, int>.failure(1));
    });

    test('recover turns failure into success', () {
      const success = Result<int, _TestError>.success(8);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      expect(
        success.recover((_) => 100),
        const Result<int, _TestError>.success(8),
      );
      expect(
        failure.recover((_) => 100),
        const Result<int, _TestError>.success(100),
      );
    });

    test('mapCatching captures thrown error', () {
      const success = Result<int, _TestError>.success(4);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      final mapped = success.mapCatching((value) => value * 3);
      final mappedThrown = success.mapCatching<int>((_) {
        throw StateError('explode');
      });
      final mappedFailure = failure.mapCatching((value) => value * 3);

      expect(mapped, const Result<int, Object>.success(12));
      expect(mappedThrown.isFailure, isTrue);
      expect(mappedFailure, const Result<int, Object>.failure(_TestError('x')));
    });

    test('recoverCatching captures thrown error', () {
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      final recovered = failure.recoverCatching((_) => 9);
      final recoveredThrown = failure.recoverCatching((_) {
        throw StateError('explode');
      });

      expect(recovered, const Result<int, Object>.success(9));
      expect(recoveredThrown.isFailure, isTrue);
    });

    test('mapCatchingAsync captures async thrown error', () async {
      const success = Result<int, _TestError>.success(4);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      final mapped = await success.mapCatchingAsync((value) async => value * 3);
      final mappedThrown = await success.mapCatchingAsync<int>((_) async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('explode');
      });
      final mappedFailure = await failure.mapCatchingAsync(
        (value) async => value * 3,
      );

      expect(mapped, const Result<int, Object>.success(12));
      expect(mappedThrown.isFailure, isTrue);
      expect(mappedFailure, const Result<int, Object>.failure(_TestError('x')));
    });

    test('recoverCatchingAsync captures async thrown error', () async {
      const success = Result<int, _TestError>.success(8);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      final recoveredSuccess = await success.recoverCatchingAsync(
        (_) async => 9,
      );
      final recovered = await failure.recoverCatchingAsync((_) async => 9);
      final recoveredThrown = await failure.recoverCatchingAsync((_) async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('explode');
      });

      expect(recoveredSuccess, const Result<int, Object>.success(8));
      expect(recovered, const Result<int, Object>.success(9));
      expect(recoveredThrown.isFailure, isTrue);
    });
  });

  group('Result side effects', () {
    test('onSuccess and onFailure', () {
      const success = Result<int, _TestError>.success(11);
      const failure = Result<int, _TestError>.failure(_TestError('x'));

      var successValue = 0;
      String? failureMessage;

      success
          .onSuccess((value) => successValue = value)
          .onFailure((error) => failureMessage = error.message);

      expect(successValue, 11);
      expect(failureMessage, isNull);

      failure
          .onSuccess((value) => successValue = value)
          .onFailure((error) => failureMessage = error.message);

      expect(successValue, 11);
      expect(failureMessage, 'x');
    });
  });

  group('runCatching', () {
    test('returns success when no exception', () {
      final result = runCatching(() => 'ok');

      expect(result, const Result<String, Object>.success('ok'));
    });

    test('returns failure when exception is thrown', () {
      final result = runCatching<String>(() {
        throw StateError('oops');
      });

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<StateError>());
    });
  });

  group('runCatchingAsync', () {
    test('returns success when no exception', () async {
      final result = await runCatchingAsync(() async => 'ok');

      expect(result, const Result<String, Object>.success('ok'));
    });

    test('returns failure when exception is thrown', () async {
      final result = await runCatchingAsync<String>(() async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('oops');
      });

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<StateError>());
    });
  });

  group('Result equality and toString', () {
    test('supports value equality', () {
      expect(
        const Result<int, _TestError>.success(1),
        const Result<int, _TestError>.success(1),
      );
      expect(
        const Result<int, _TestError>.failure(_TestError('x')),
        const Result<int, _TestError>.failure(_TestError('x')),
      );
    });

    test('toString is readable', () {
      expect(const Result<int, _TestError>.success(1).toString(), 'Success(1)');
      expect(
        const Result<int, _TestError>.failure(_TestError('x')).toString(),
        'Failure(TestError(x))',
      );
    });
  });
}

class _TestError {
  const _TestError(this.message);

  final String message;

  @override
  bool operator ==(Object other) {
    return other is _TestError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'TestError($message)';
}
