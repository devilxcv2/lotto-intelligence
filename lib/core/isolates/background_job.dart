// lib/core/isolates/background_job.dart

import 'dart:async';
import 'dart:isolate';

typedef ProgressReporter = void Function(double fraction);

class JobCancelled implements Exception {
  const JobCancelled();

  @override
  String toString() => 'Operazione annullata.';
}

/// Lavoro CPU su un isolate dedicato, con avanzamento e annullamento.
/// Annullare termina l'isolate: non serve che il calcolo controlli un flag.
class BackgroundJob<T> {
  BackgroundJob._(this._isolate, this._port, this._progress, this._result);

  final Isolate _isolate;
  final ReceivePort _port;
  final StreamController<double> _progress;
  final Completer<T> _result;

  Stream<double> get progress => _progress.stream;
  Future<T> get result => _result.future;

  void cancel() {
    if (_result.isCompleted) return;
    _isolate.kill(priority: Isolate.immediate);
    _finish(error: const JobCancelled());
  }

  void _finish({T? value, Object? error}) {
    if (_result.isCompleted) return;
    _port.close();
    unawaited(_progress.close());
    if (error != null) {
      _result.completeError(error);
    } else {
      _result.complete(value as T);
    }
  }

  /// [work] viaggia verso l'isolate: deve catturare solo dati inviabili,
  /// quindi va costruita in una funzione top-level e non dentro un widget.
  static Future<BackgroundJob<T>> start<T>(T Function(ProgressReporter report) work) async {
    final port = ReceivePort();
    final progress = StreamController<double>.broadcast();
    final completer = Completer<T>();
    final isolate = await Isolate.spawn(
      _entry,
      _JobStart(port.sendPort, work),
      onError: port.sendPort,
      onExit: port.sendPort,
    );
    final job = BackgroundJob<T>._(isolate, port, progress, completer);
    port.listen((message) {
      if (message is double) {
        if (!progress.isClosed) progress.add(message);
      } else if (message is _JobDone) {
        job._finish(value: message.value as T);
      } else if (message is List && message.length == 2) {
        job._finish(error: StateError('${message[0]}'));
      } else if (message == null) {
        job._finish(error: StateError('Il calcolo si è interrotto senza risultato.'));
      }
    });
    return job;
  }
}

class _JobStart {
  const _JobStart(this.port, this.work);

  final SendPort port;
  final Object? Function(ProgressReporter report) work;
}

class _JobDone {
  const _JobDone(this.value);

  final Object? value;
}

void _entry(_JobStart start) {
  final clock = Stopwatch()..start();
  var lastSent = -1000;
  final value = start.work((fraction) {
    // Al massimo dieci messaggi al secondo verso la UI.
    if (clock.elapsedMilliseconds - lastSent < 100 && fraction < 1) return;
    lastSent = clock.elapsedMilliseconds;
    start.port.send(fraction.clamp(0.0, 1.0));
  });
  Isolate.exit(start.port, _JobDone(value));
}
