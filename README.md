# pure_result

A lightweight `Result` type for Dart/Flutter inspired by Kotlin and Swift.

## Features

- Dart 3 `sealed class` based API.
- Strongly typed success and failure branches: `Result<T, E>`.
- Functional transforms: `map`, `flatMap`, `mapError`, `flatMapError`.
- Recovery and side-effects: `recover`, `recoverCatching`, `onSuccess`, `onFailure`.
- Utility helpers: `fold`, `getOrThrow`, `getOrElse`, `getOrDefault`, `runCatching`.

## Usage

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
  final result = parsePort('8080')
      .map((port) => port + 1)
      .onSuccess((value) => print('next port: $value'))
      .onFailure((error) => print('error: $error'));

  final display = result.fold(
    (value) => 'OK($value)',
    (error) => 'ERR($error)',
  );

  print(display);
}
```

## Test

```bash
flutter test
```

## Publish Checklist

- Fill `homepage`, `repository`, and `issue_tracker` in `pubspec.yaml`.
- Add a permissive license text in `LICENSE`.
- Update version and changelog before each release.
- Run `flutter analyze` and `flutter test`.
- Dry run: `flutter pub publish --dry-run`.
- Publish: `flutter pub publish`.
