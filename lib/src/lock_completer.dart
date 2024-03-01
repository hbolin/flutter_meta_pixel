import 'dart:async';

class LockCompleter {
  Completer<void>? _completer;

  Future<void> lock({
    required Future<void> Function() action,
  }) async {
    try {
      _completer ??= Completer<void>();
      await action();
    } finally {
      _completer?.complete();
      _completer = null;
    }
  }

  Future<void> awaitLock({
    required void Function() action,
  }) async {
    if (_completer != null && _completer!.isCompleted != true) {
      await _completer!.future;
    }
    action();
  }
}
