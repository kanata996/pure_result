# pure_result

A lightweight `Result` type for Dart/Flutter inspired by Kotlin and Swift.

## Features

- Dart 3 `sealed class` based API.
- Core API export (`package:pure_result/pure_result.dart`) with `Result<T, E>` and `try_*` helpers.
- Functional transforms: `map`, `flatMap`, `mapError`, `flatMapError`.
- Recovery helpers: `recover`, `tryRecover`, `tryRecoverSync`.
- Utility helpers: `fold`, `getOrThrow`, `getOrElse`, `tryRun`, `tryRunSync`.
- Async chain support on `Future<Result<...>>` via `AsyncResultOps`: `map`, `flatMap`, `mapError`, `flatMapError`, `recover`.

Optional module imports:
- `package:pure_result/async_result.dart` for `AsyncResultOps`.

## Usage

```dart
import 'package:pure_result/pure_result.dart';
import 'package:pure_result/async_result.dart';

Result<int, String> parsePort(String raw) {
  final value = int.tryParse(raw);
  if (value == null) {
    return const Result.failure('Invalid port');
  }
  return Result.success(value);
}

void main() {
  final result = parsePort('8080').map((port) => port + 1);

  final display = result.fold(
    (value) => 'OK($value)',
    (error) => 'ERR($error)',
  );

  print(display);
}
```

## Test

```bash
dart test
```

## Publish Checklist

- Fill `homepage`, `repository`, and `issue_tracker` in `pubspec.yaml`.
- Add a permissive license text in `LICENSE`.
- Update version and changelog before each release.
- Run `dart analyze` and `dart test`.
- Dry run: `dart pub publish --dry-run`.
- Publish: `dart pub publish`.
