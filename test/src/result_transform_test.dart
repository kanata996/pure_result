import 'package:test/test.dart';
import 'package:pure_result/pure_result.dart';

import 'test_types.dart';

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
  });
}
