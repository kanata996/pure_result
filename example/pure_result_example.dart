// ignore_for_file: unused_local_variable

import 'package:pure_result/pure_result.dart';
import 'package:pure_result/async_result.dart';

// ---------------------------------------------------------------------------
// Helper functions used in examples
// ---------------------------------------------------------------------------

Result<int, String> parsePort(String raw) {
  final value = int.tryParse(raw);
  if (value == null) return const Result.failure('Invalid port');
  return Result.success(value);
}

Result<String, String> validatePort(int port) {
  if (port < 0 || port > 65535) return Result.failure('Port out of range: $port');
  return Result.success('localhost:$port');
}

Future<Result<String, String>> fetchConfig() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return const Result.success('{"port": 8080}');
}

// ---------------------------------------------------------------------------
// Examples
// ---------------------------------------------------------------------------

void main() async {
  // ── 1. Create ─────────────────────────────────────────────────────────
  const ok = Result<int, String>.success(42);
  const err = Result<int, String>.failure('not found');
  print(ok); // Success(42)
  print(err); // Failure(not found)

  // ── 2. Read state ─────────────────────────────────────────────────────
  print(ok.isSuccess); // true
  print(ok.isFailure); // false
  print(ok.valueOrNull); // 42
  print(err.errorOrNull); // not found

  // ── 3. Pattern matching ───────────────────────────────────────────────
  final desc = switch (ok) {
    Success(value: final v) => 'value=$v',
    Failure(error: final e) => 'error=$e',
  };
  print(desc); // value=42

  // ── 4. fold (positional) ──────────────────────────────────────────────
  final label = ok.fold(
    (v) => 'OK: $v',
    (e) => 'ERR: $e',
  );
  print(label); // OK: 42

  // ── 5. when (named parameters) ────────────────────────────────────────
  final message = ok.when(
    success: (v) => 'Received $v',
    failure: (e) => 'Error: $e',
  );
  print(message); // Received 42

  // ── 6. getOrElse / getOrThrow ─────────────────────────────────────────
  print(err.getOrElse((_) => -1)); // -1
  print(ok.getOrThrow()); // 42

  // ── 7. map ────────────────────────────────────────────────────────────
  final doubled = ok.map((v) => v * 2);
  print(doubled); // Success(84)

  // ── 8. flatMap (chaining results) ─────────────────────────────────────
  final address = parsePort('8080').flatMap(validatePort);
  print(address); // Success(localhost:8080)

  final badAddress = parsePort('99999').flatMap(validatePort);
  print(badAddress); // Failure(Port out of range: 99999)

  final invalid = parsePort('abc').flatMap(validatePort);
  print(invalid); // Failure(Invalid port)

  // ── 9. mapError / flatMapError ────────────────────────────────────────
  final coded = err.mapError((e) => e.length);
  print(coded); // Failure(9)

  final retried = err.flatMapError(
    (e) => const Result<int, String>.success(0), // fallback
  );
  print(retried); // Success(0)

  // ── 10. recover ───────────────────────────────────────────────────────
  final recovered = err.recover((_) => 0);
  print(recovered); // Success(0)

  // ── 11. tryRunSync — bridge exceptions into Result ────────────────────
  final parsed = tryRunSync(() => int.parse('42'));
  print(parsed); // Success(42)

  final failed = tryRunSync(() => int.parse('nope'));
  print(failed); // Failure(CaughtError(...))

  // ── 12. tryRun — async variant ────────────────────────────────────────
  final asyncResult = await tryRun(() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'done';
  });
  print(asyncResult); // Success(done)

  // ── 13. Composing tryRunSync with flatMap ──────────────────────────────
  final chained = tryRunSync(() => int.parse('10'))
      .flatMap((v) => tryRunSync(() => v ~/ 2));
  print(chained); // Success(5)

  final chainedFail = tryRunSync(() => int.parse('10'))
      .flatMap((v) => tryRunSync(() => v ~/ 0));
  print(chainedFail); // Failure(CaughtError(...))

  // ── 14. Async chaining with AsyncResultOps ────────────────────────────
  final pipeline = await fetchConfig()
      .map((json) => json.length)
      .flatMap((len) async => Result<String, String>.success('length=$len'))
      .recover((_) => 'fallback');
  print(pipeline); // Success(length=16)
}
