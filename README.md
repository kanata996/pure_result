# pure_result

[![Pub](https://img.shields.io/pub/v/pure_result.svg)](https://pub.dev/packages/pure_result)
[![CI](https://github.com/kanata996/pure_result/workflows/CI/badge.svg)](https://github.com/kanata996/pure_result/actions/workflows/ci.yml)
[![Codecov](https://codecov.io/github/kanata996/pure_result/graph/badge.svg)](https://codecov.io/github/kanata996/pure_result)

A sealed `Result<T, E>` type for Dart and Flutter.

`pure_result` helps you represent success/failure as values instead of throwing everywhere.

## ✨ Highlights

- ✅ Dart 3 `sealed class` API.
- ✅ Strongly typed success and error channels (`T` / `E`).
- ✅ Functional composition: `map`, `flatMap`, `mapError`, `flatMapError`, `recover`.
- ✅ Exception capture helpers: `tryRunSync`, `tryRun`.
- ✅ Async chaining on `Future<Result<...>>` via `AsyncResultOps`.

## 📦 Installation

```yaml
dependencies:
  pure_result: ^0.1.2
```

Then run:

```bash
dart pub get
```

## 📥 Imports

Core API:

```dart
import 'package:pure_result/pure_result.dart';
```

Optional async extension API:

```dart
import 'package:pure_result/async_result.dart';
```

## 🚀 Quick Start

```dart
import 'package:pure_result/pure_result.dart';

Result<int, String> parsePort(String raw) {
  final value = int.tryParse(raw);
  if (value == null) {
    return const Result.failure('Invalid port');
  }
  return Result.success(value);
}

void main() {
  final result = parsePort('8080').map((port) => port + 1);

  final text = result.fold(
    (value) => 'OK: $value',
    (error) => 'ERR: $error',
  );

  print(text); // OK: 8081
}
```

## 🧱 Core Model

Create success/failure values:

```dart
const ok = Result<int, String>.success(42);
const err = Result<int, String>.failure('boom');
```

Read state:

```dart
print(ok.isSuccess); // true
print(ok.isFailure); // false
print(ok.valueOrNull); // 42
print(ok.errorOrNull); // null

print(err.isSuccess); // false
print(err.valueOrNull); // null
print(err.errorOrNull); // boom
```

Pattern-match with `switch`:

```dart
String describe(Result<int, String> r) {
  return switch (r) {
    Success(value: final v) => 'value=$v',
    Failure(error: final e) => 'error=$e',
  };
}
```

## 🛠 Value-Side APIs

### `fold`

```dart
final label = Result<int, String>.success(7).fold(
  (v) => 'value:$v',
  (e) => 'error:$e',
);
// value:7
```

### `when`

Named-parameter variant of `fold` for improved readability:

```dart
final label = Result<int, String>.success(7).when(
  success: (v) => 'value:$v',
  failure: (e) => 'error:$e',
);
// value:7
```

### `getOrElse`

```dart
final value = Result<int, String>.failure('bad').getOrElse((_) => 0);
// 0
```

### `getOrThrow`

```dart
final value = Result<int, Exception>.success(10).getOrThrow();
// 10

// Throws stored error when failure
// Result<int, Exception>.failure(Exception('x')).getOrThrow();
```

## 🔁 Transform APIs

### `map` / `flatMap`

```dart
Result<int, String> readCount() => const Result.success(2);
Result<String, String> toText(int n) => Result.success('count=$n');

final mapped = readCount().map((n) => n + 1);
// Success(3)

final chained = readCount().flatMap(toText);
// Success(count=2)
```

### `mapError` / `flatMapError`

```dart
const failed = Result<int, String>.failure('not_found');

final mappedError = failed.mapError((msg) => msg.length);
// Failure(9)

final remapped = failed.flatMapError(
  (msg) => Result<int, int>.failure(msg.length),
);
// Failure(9)
```

### `recover`

```dart
const failed = Result<int, String>.failure('timeout');
final recovered = failed.recover((_) => 30);
// Success(30)
```

## 🧯 Exception Capture APIs

`pure_result` can convert thrown errors into typed failure values.

### `tryRunSync`

```dart
final ok = tryRunSync(() => 100 ~/ 4);
// Success(25)

final failed = tryRunSync(() => 100 ~/ 0);
// Failure(CaughtError(...))
```

### `tryRun`

```dart
final result = await tryRun(() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return 'done';
});
// Success(done)
```

`CaughtError` stores both `error` and `stackTrace`:

```dart
final r = tryRunSync(() => throw StateError('explode'));
if (r.isFailure) {
  final ce = r.errorOrNull!;
  print(ce.error); // StateError: Bad state: explode
  print(ce.stackTrace);
}
```

### Composing `tryRunSync` with existing APIs

You can combine `tryRunSync` / `tryRun` with `fold`, `map`, or `flatMap`
to handle exceptions in a pipeline without losing type safety:

```dart
// Map a success value with a function that might throw:
final result = tryRunSync(() => int.parse(rawInput))
    .map((n) => n * 2);
// Success(result) or Failure(CaughtError(...))

// Chain multiple fallible steps:
final chained = tryRunSync(() => step1())
    .flatMap((v) => tryRunSync(() => step2(v)));
// Each step is independently captured
```

## 🌊 Async Result Chaining (`AsyncResultOps`)

Import optional async extension:

```dart
import 'package:pure_result/async_result.dart';
```

Then chain directly on `Future<Result<T, E>>`:

```dart
Future<Result<int, String>> fetchPort() async {
  return const Result.success(8080);
}

final result = await fetchPort()
    .map((port) => port + 1)
    .flatMap((port) => Result<String, String>.success('port=$port'))
    .mapError((e) => 'ERR:$e')
    .recover((_) => 'port=80');

print(result); // Success(port=8081)
```

## 📚 API Surface

From `package:pure_result/pure_result.dart`:

- `Result.success` / `Result.failure`
- `isSuccess` / `isFailure`
- `valueOrNull` / `errorOrNull`
- `fold` / `when` / `getOrElse` / `getOrThrow`
- `map` / `flatMap` / `mapError` / `flatMapError` / `recover`
- `tryRunSync` / `tryRun`
- `CaughtError`

From `package:pure_result/async_result.dart`:

- `AsyncResultOps.map`
- `AsyncResultOps.flatMap`
- `AsyncResultOps.mapError`
- `AsyncResultOps.flatMapError`
- `AsyncResultOps.recover`

## 📊 Test & Coverage

The badges at the top are powered by:

- GitHub Actions workflow: `.github/workflows/ci.yml`
- Codecov report from `coverage/lcov.info`

Run locally:

```bash
dart test -r expanded
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage \
  --packages=.dart_tool/package_config.json \
  --report-on=lib \
  --in=coverage \
  --out=coverage/lcov.info \
  --lcov
```

## 📄 License

MIT License.
