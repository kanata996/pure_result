## 0.1.3

- Added `Result.when()` — named-parameter variant of `fold` for improved readability.
- Added `CaughtError` value equality (`==` / `hashCode`) based on error identity.
- Added `example/pure_result_example.dart` covering all public APIs.
- Supplemented unit tests for `when` and `CaughtError` equality (100% coverage).

## 0.1.2

- Removed `TryResultOps` extension (`tryMapSync`, `tryMap`, `tryRecoverSync`, `tryRecover`) — these methods erased the error type to `Object`, undermining type safety.
- Retained core exception capture helpers: `tryRunSync`, `tryRun`, `CaughtError`.
- Updated README with composable usage examples using `tryRunSync` + `flatMap`.

## 0.1.1

- Improved public API documentation across `Result`, async extensions, and try helpers.
- Enabled `public_member_api_docs` lint to keep API docs coverage enforced.
- Expanded package description in `pubspec.yaml` for clearer pub.dev metadata.

## 0.1.0

- Initial release of sealed `Result<T, E>`.
- Added `Success`/`Failure` variants and factory constructors.
- Added core functional operators: `fold`, `map`, `flatMap`, `mapError`, `flatMapError`, `recover`.
- Added extraction helpers: `getOrThrow`, `getOrElse`, nullable accessors.
- Added exception capture helpers: `tryRun`, `tryRunSync`, `tryMap`, `tryMapSync`, `tryRecover`, `tryRecoverSync`.
- Added `AsyncResultOps` extension for chaining on `Future<Result<...>>`: `map`, `flatMap`, `mapError`, `flatMapError`, `recover`.
- Slimmed modules: `package:pure_result/pure_result.dart` exports core `Result` + `try_*` helpers, while `package:pure_result/async_result.dart` remains an optional import for `AsyncResultOps`.
