import 'package:flutter_test/flutter_test.dart';
import 'package:pure_result/pure_result.dart';

import 'test_types.dart';

void main() {
  group('Result state', () {
    test('success exposes value', () {
      const result = Result<int, TestError>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, isNull);
    });

    test('failure exposes error', () {
      const error = TestError('boom');
      const result = Result<int, TestError>.failure(error);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, error);
    });
  });
}
