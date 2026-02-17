import 'package:flutter_test/flutter_test.dart';
import 'package:pure_result/pure_result.dart';

import 'support/test_types.dart';

void main() {
  group('Result equality and toString', () {
    test('supports value equality', () {
      expect(
        const Result<int, TestError>.success(1),
        const Result<int, TestError>.success(1),
      );
      expect(
        const Result<int, TestError>.failure(TestError('x')),
        const Result<int, TestError>.failure(TestError('x')),
      );
    });

    test('equal results have same hashCode', () {
      const successA = Result<int, TestError>.success(1);
      const successB = Result<int, TestError>.success(1);
      const failureA = Result<int, TestError>.failure(TestError('x'));
      const failureB = Result<int, TestError>.failure(TestError('x'));

      expect(successA.hashCode, successB.hashCode);
      expect(failureA.hashCode, failureB.hashCode);
    });

    test('toString is readable', () {
      expect(const Result<int, TestError>.success(1).toString(), 'Success(1)');
      expect(
        const Result<int, TestError>.failure(TestError('x')).toString(),
        'Failure(TestError(x))',
      );
    });

    test('CaughtError toString is readable', () {
      final caught = CaughtError(StateError('oops'), StackTrace.current);
      final text = caught.toString();

      expect(text, contains('CaughtError(error:'));
      expect(text, contains('Bad state: oops'));
      expect(text, contains('stackTrace:'));
    });
  });
}
