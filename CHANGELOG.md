## 0.0.1

- Initial release of sealed `Result<T, E>`.
- Added `Success`/`Failure` variants and factory constructors.
- Added core functional operators: `fold`, `map`, `flatMap`, `mapError`, `flatMapError`, `recover`.
- Added extraction helpers: `getOrThrow`, `getOrElse`, nullable accessors.
- Added exception capture helpers: `tryRun`, `tryRunSync`, `tryMap`, `tryMapSync`, `tryRecover`, `tryRecoverSync`.
- Added `AsyncResultOps` extension for chaining on `Future<Result<...>>`: `map`, `flatMap`, `mapError`, `flatMapError`, `recover`.
- Slimmed modules: `package:pure_result/pure_result.dart` exports core `Result` + `try_*` helpers, while `package:pure_result/async_result.dart` remains an optional import for `AsyncResultOps`.
