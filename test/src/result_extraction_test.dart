import 'package:flutter_test/flutter_test.dart';
import 'package:pure_result/pure_result.dart';

import 'test_types.dart';

void main() {
  group('Result extraction', () {
    test('fold routes to correct branch', () {
      const success = Result<int, TestError>.success(2);
      const failure = Result<int, TestError>.failure(TestError('x'));

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

    test('getOrElse', () {
      const success = Result<int, TestError>.success(10);
      const failure = Result<int, TestError>.failure(TestError('x'));

      expect(success.getOrElse((_) => -1), 10);
      expect(failure.getOrElse((_) => -1), -1);
    });

    test('getOrThrow returns value or throws', () {
      const success = Result<int, TestError>.success(7);
      const failure = Result<int, TestError>.failure(TestError('broken'));

      expect(success.getOrThrow(), 7);
      expect(() => failure.getOrThrow(), throwsA(isA<TestError>()));
    });
  });
}
