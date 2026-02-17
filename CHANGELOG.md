## 0.0.1

- Initial release of sealed `Result<T, E>`.
- Added `Success`/`Failure` variants and factory constructors.
- Added functional operators: `fold`, `map`, `flatMap`, `mapError`, `flatMapError`.
- Added extraction helpers: `getOrThrow`, `getOrElse`, `getOrDefault`, nullable accessors.
- Added recovery/side-effect helpers: `recover`, `tryRecover`, `tryRecoverSync`, `onSuccess`, `onFailure`.
- Added `tryRun`/`tryRunSync` helpers and unit tests.
- Added `tryRunWith`/`tryRunSyncWith` for custom error mapping with stack traces.
- Added `AsyncResultOps` extension for chaining on `Future<Result<...>>`, including `flatMapError`.
- Added `TryAsyncResultOps` extension for exception-safe chaining on `Future<Result<...>>`.
