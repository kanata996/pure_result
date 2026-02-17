import 'package:flutter_test/flutter_test.dart';
import 'package:pure_result/pure_result.dart';

import 'support/test_types.dart';

void main() {
  group('Result transform', () {
    test('map and flatMap transform success only', () {
      const success = Result<int, TestError>.success(3);
      const failure = Result<int, TestError>.failure(TestError('x'));

      final mapped = success.map((value) => value * 2);
      final mappedFailure = failure.map((value) => value * 2);

      final flatMapped = success.flatMap(
        (value) => Result<String, TestError>.success('v:$value'),
      );
      final flatMappedFailure = failure.flatMap(
        (value) => Result<String, TestError>.success('v:$value'),
      );

      expect(mapped, const Result<int, TestError>.success(6));
      expect(mappedFailure.isFailure, isTrue);
      expect(flatMapped, const Result<String, TestError>.success('v:3'));
      expect(flatMappedFailure.isFailure, isTrue);
    });

    test('mapError and flatMapError transform failure only', () {
      const success = Result<int, TestError>.success(5);
      const failure = Result<int, TestError>.failure(TestError('x'));

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
      const success = Result<int, TestError>.success(8);
      const failure = Result<int, TestError>.failure(TestError('x'));

      expect(
        success.recover((_) => 100),
        const Result<int, TestError>.success(8),
      );
      expect(
        failure.recover((_) => 100),
        const Result<int, TestError>.success(100),
      );
    });

    test('tryMapSync captures thrown error', () {
      const success = Result<int, TestError>.success(4);
      const failure = Result<int, TestError>.failure(TestError('x'));

      final mapped = success.tryMapSync((value) => value * 3);
      final mappedThrown = success.tryMapSync<int>((_) {
        throw StateError('explode');
      });
      final mappedFailure = failure.tryMapSync((value) => value * 3);

      expect(mapped, const Result<int, Object>.success(12));
      expect(mappedThrown.isFailure, isTrue);
      expect(mappedThrown.errorOrNull, isA<CaughtError>());
      expect(mappedFailure, const Result<int, Object>.failure(TestError('x')));
    });

    test('tryRecoverSync captures thrown error', () {
      const failure = Result<int, TestError>.failure(TestError('x'));

      final recovered = failure.tryRecoverSync((_) => 9);
      final recoveredThrown = failure.tryRecoverSync((_) {
        throw StateError('explode');
      });

      expect(recovered, const Result<int, Object>.success(9));
      expect(recoveredThrown.isFailure, isTrue);
      expect(recoveredThrown.errorOrNull, isA<CaughtError>());
    });

    test('tryRecoverSync passes through success', () {
      const success = Result<int, TestError>.success(8);
      var called = false;

      final recovered = success.tryRecoverSync((_) {
        called = true;
        return 9;
      });

      expect(recovered, const Result<int, Object>.success(8));
      expect(called, isFalse);
    });

    test('tryMap captures async thrown error', () async {
      const success = Result<int, TestError>.success(4);
      const failure = Result<int, TestError>.failure(TestError('x'));

      final mapped = await success.tryMap((value) async => value * 3);
      final mappedThrown = await success.tryMap<int>((_) async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('explode');
      });
      final mappedFailure = await failure.tryMap((value) async => value * 3);

      expect(mapped, const Result<int, Object>.success(12));
      expect(mappedThrown.isFailure, isTrue);
      expect(mappedThrown.errorOrNull, isA<CaughtError>());
      expect(mappedFailure, const Result<int, Object>.failure(TestError('x')));
    });

    test('tryRecover captures async thrown error', () async {
      const success = Result<int, TestError>.success(8);
      const failure = Result<int, TestError>.failure(TestError('x'));

      final recoveredSuccess = await success.tryRecover((_) async => 9);
      final recovered = await failure.tryRecover((_) async => 9);
      final recoveredThrown = await failure.tryRecover((_) async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('explode');
      });

      expect(recoveredSuccess, const Result<int, Object>.success(8));
      expect(recovered, const Result<int, Object>.success(9));
      expect(recoveredThrown.isFailure, isTrue);
      expect(recoveredThrown.errorOrNull, isA<CaughtError>());
    });
  });
}
