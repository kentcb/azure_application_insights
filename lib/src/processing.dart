import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'context.dart';
import 'telemetry.dart';

abstract class Processor {
  void process({
    @required List<TelemetryWithContext> telemetryWithContext,
  });

  Future<void> flush();
}

@immutable
class TelemetryWithContext {
  const TelemetryWithContext({
    @required this.telemetry,
    @required this.context,
  })  : assert(telemetry != null),
        assert(context != null);

  final Telemetry telemetry;
  final TelemetryContext context;
}

class BufferedProcessor implements Processor {
  BufferedProcessor({
    this.next,
    this.capacity = 50,
    this.flushDelay = const Duration(seconds: 30),
  })  : assert(capacity != null),
        assert(capacity > 0),
        assert(flushDelay != null),
        assert(flushDelay >= Duration.zero),
        _buffer = <TelemetryWithContext>[];

  final Processor next;
  final int capacity;
  final List<TelemetryWithContext> _buffer;
  final Duration flushDelay;

  Timer _flushTimer;

  @override
  void process({
    @required List<TelemetryWithContext> telemetryWithContext,
  }) {
    assert(telemetryWithContext != null);

    for (final telemetryWithContextItem in telemetryWithContext) {
      _buffer.add(telemetryWithContextItem);

      if (_buffer.length > capacity) {
        // Capacity reached, so attempt to flush.
        flush();
      } else if (flushDelay == Duration.zero) {
        // Immediate flush.
        flush();
      } else {
        // Delayed flush if not already instigated.
        _flushTimer ??= Timer(
          flushDelay,
          flush,
        );
      }
    }
  }

  @override
  Future<void> flush() async {
    if (_buffer.isNotEmpty) {
      final bufferClone = List<TelemetryWithContext>.from(_buffer);
      _buffer.clear();

      if (next != null) {
        next.process(
          telemetryWithContext: bufferClone,
        );
        await next.flush();
      }
    }

    _flushTimer = null;

    return Future<void>.value(null);
  }
}

class TransmissionProcessor implements Processor {
  TransmissionProcessor({
    @required this.instrumentationKey,
    @required this.httpClient,
    @required this.timeout,
    this.next,
  })  : assert(instrumentationKey != null),
        assert(httpClient != null),
        assert(timeout != null),
        _outstandingFutures = <Future<void>>{};

  final Processor next;
  final String instrumentationKey;
  final Client httpClient;
  final Duration timeout;
  final Set<Future<void>> _outstandingFutures;

  @override
  void process({
    @required List<TelemetryWithContext> telemetryWithContext,
  }) {
    final future = _transmit(
      telemetryWithContext: telemetryWithContext,
    );

    if (future != null) {
      _outstandingFutures.add(future);
      future.whenComplete(() => _outstandingFutures.remove(future));
    }

    next?.process(
      telemetryWithContext: telemetryWithContext,
    );
  }

  @override
  Future<void> flush() => Future.wait(_outstandingFutures);

  Future<void> _transmit({
    @required List<TelemetryWithContext> telemetryWithContext,
  }) async {
    assert(telemetryWithContext != null);
    print('Transmitting ${telemetryWithContext.length} telemetry items');

    final serialized = _serializeTelemetry(
      telemetryWithContext: telemetryWithContext,
    );
    final encoded = jsonEncode(serialized);

    try {
      final response = await httpClient
          .post(
            'https://dc.services.visualstudio.com/v2/track',
            body: encoded,
          )
          .timeout(timeout);
      final result = response.statusCode >= 200 && response.statusCode < 300;

      if (!result) {
        print('Failed to submit telemetry: ${response.statusCode}');
      }
    } on Object catch (e) {
      print('Failed to submit telemetry: $e');
    }
  }

  List<Map<String, dynamic>> _serializeTelemetry({
    @required List<TelemetryWithContext> telemetryWithContext,
  }) {
    assert(telemetryWithContext != null);

    final result = telemetryWithContext
        .map((t) => _serializeTelemetryItem(
              telemetryWithContext: t,
            ))
        .toList(growable: false);
    return result;
  }

  Map<String, dynamic> _serializeTelemetryItem({
    @required TelemetryWithContext telemetryWithContext,
  }) {
    assert(telemetryWithContext != null);

    final telemetryData = telemetryWithContext.telemetry.getDataMap(context: telemetryWithContext.context);
    final serializedContext = telemetryWithContext.context.getContextMap();
    final result = <String, dynamic>{
      'name': telemetryWithContext.telemetry.envelopeName,
      'time': telemetryWithContext.telemetry.timestamp.toIso8601String(),
      'iKey': instrumentationKey,
      'tags': <String, dynamic>{
        'ai.internal.sdkVersion': '1',
        if (serializedContext != null) ...serializedContext,
      },
      'data': telemetryData,
    };
    return result;
  }
}

class DebugProcessor implements Processor {
  DebugProcessor({
    this.next,
  });

  final Processor next;

  @override
  void process({
    @required List<TelemetryWithContext> telemetryWithContext,
  }) {
    assert(telemetryWithContext != null);

    print('Processing ${telemetryWithContext.length} telemetry items:');

    for (final telemetryWithContextItem in telemetryWithContext) {
      final json = jsonEncode(telemetryWithContextItem.telemetry.getDataMap(context: telemetryWithContextItem.context));
      print('  - ${telemetryWithContextItem.telemetry.runtimeType}: $json');
    }

    next?.process(
      telemetryWithContext: telemetryWithContext,
    );
  }

  @override
  Future<void> flush({
    @required TelemetryContext context,
  }) =>
      Future<void>.value(null);
}
