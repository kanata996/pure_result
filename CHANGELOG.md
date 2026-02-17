## 0.0.1

- Initial release of sealed `Result<T, E>`.
- Added `Success`/`Failure` variants and factory constructors.
- Added functional operators: `fold`, `map`, `flatMap`, `mapError`, `flatMapError`.
- Added extraction helpers: `getOrThrow`, `getOrElse`, `getOrDefault`, nullable accessors.
- Added recovery/side-effect helpers: `recover`, `recoverCatching`, `onSuccess`, `onFailure`.
- Added `runCatching` helper and unit tests.
