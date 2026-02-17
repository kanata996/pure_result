class TestError {
  const TestError(this.message);

  final String message;

  @override
  bool operator ==(Object other) {
    return other is TestError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'TestError($message)';
}

class TestPanic extends Error {}
