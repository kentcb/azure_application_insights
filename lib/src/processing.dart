import 'dart:async';
import 'dart:convert';

import 'package:azure_application_insights/src/client.dart';
import 'package:azure_application_insights/src/context.dart';
import 'package:azure_application_insights/src/http.dart';
import 'package:azure_application_insights/src/telemetry.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// Used by a [TelemetryClient] to process telemetry items.
///
/// Processors implement the [chain of responsibility](https://en.wikipedia.org/wiki/Chain-of-responsibility_pattern#C#_example)
/// pattern, with [next] being the subsequent processor in the chain. This allows a set of processors to be composed.
abstract class Processor {
  /// The next processor in the chain, or `null` if there is none.
  Processor? get next;

  /// Requests that [contextualTelemetryItems] be processed by this [Processor].
  void process({
    required List<ContextualTelemetryItem> contextualTelemetryItems,
  });

  /// Instructs the processor to force all telemetry items to be handled regardless of any internal buffering logic,
  /// completing asynchronously once all items are flushed.
  Future<void> flush();
}

/// Encapsulates a [telemetryItem] and related [context].
@immutable
class ContextualTelemetryItem {
  /// Creates a new instance of [ContextualTelemetryItem].
  const ContextualTelemetryItem({
    required this.telemetryItem,
    required this.context,
  });

  /// The telemetry.
  final TelemetryItem telemetryItem;

  /// The telemetry context.
  final TelemetryContext context;
}

/// A [Processor] that buffers up to [capacity] telemetry items for at most [flushDelay] before forwarding them onto
/// [next].
///
/// Telemetry items passed into [process] will be added to a buffer of size [capacity]. If the buffer is full, all
/// telemetry items within it are immediately forwarded onto [next]. Even if the buffer is not full, telemetry items
/// will be forwarded once [flushDelay] elapses.
class BufferedProcessor implements Processor {
  BufferedProcessor({
    this.next,
    this.capacity = 50,
    this.flushDelay = const Duration(seconds: 30),
  })  : assert(capacity > 0),
        assert(flushDelay >= Duration.zero),
        _buffer = <ContextualTelemetryItem>[];

  @override
  final Processor? next;

  /// The capacity of the buffer which, once filled, will be immediately forwarded to [next].
  final int capacity;

  /// The maximum amount of time telemetry items can sit in the buffer before being forwarded onto [next].
  final Duration flushDelay;

  final List<ContextualTelemetryItem> _buffer;
  Timer? _flushTimer;

  /// Add [contextualTelemetryItems] to the buffer, automatically forwarding telemetry if the buffer is full.
  ///
  /// Even if the buffer is not filled, it will eventually be forwarded once [flushDelay] elapses.
  @override
  void process({
    required List<ContextualTelemetryItem> contextualTelemetryItems,
  }) {
    for (final contextualTelemetryItem in contextualTelemetryItems) {
      _buffer.add(contextualTelemetryItem);

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

  /// Forwards all items in the buffer onto [next] before also flushing [next].
  @override
  Future<void> flush() async {
    if (_buffer.isNotEmpty) {
      final bufferClone = List<ContextualTelemetryItem>.from(_buffer);
      _buffer.clear();

      final next = this.next;

      if (next != null) {
        next.process(
          contextualTelemetryItems: bufferClone,
        );
        await next.flush();
      }
    }

    // It's vital to call cancel here in case flush was called pro-actively prior to shutting down the application.
    // If the timer is not canceled, it will cause the process to wait for it to fire before it exits.
    _flushTimer?.cancel();
    _flushTimer = null;
  }
}

/// A [Processor] that sends telemetry to the Azure Application Insights instance associated with [instrumentationKey]
/// at endpoint [ingestionEndpoint].
class TransmissionProcessor implements Processor {
  TransmissionProcessor({
    required this.instrumentationKey,
    required this.httpClient,
    required this.timeout,
    Logger? logger,
    this.ingestionEndpoint = 'https://dc.services.visualstudio.com/v2/track',
    this.next,
  })  : logger = logger ?? Logger('TransmissionProcessor'),
        _ingestionEndpointUri = Uri.parse(ingestionEndpoint),
        _outstandingFutures = <Future<void>>{};

  @override
  final Processor? next;

  /// The Application Insights instrumentation key to use when submitting telemetry.
  final String instrumentationKey;

  /// The endpoint to which data is sent.
  final String ingestionEndpoint;

  /// The HTTP client to use when submitting telemetry.
  ///
  /// Note that you should never use a [TelemetryHttpClient] for this value, since doing so would result in telemetry
  /// being created recursively.
  final Client httpClient;

  /// How long to wait before timing out on telemetry submission.
  final Duration timeout;

  /// A [Logger] to which processing information will be written.
  final Logger logger;

  final Uri _ingestionEndpointUri;
  final Set<Future<void>> _outstandingFutures;

  /// Sends [contextualTelemetryItems] to Application Insights, then on to [next].
  @override
  void process({
    required List<ContextualTelemetryItem> contextualTelemetryItems,
  }) {
    final future = _transmit(
      contextualTelemetry: contextualTelemetryItems,
    );

    _outstandingFutures.add(future);
    future.whenComplete(() => _outstandingFutures.remove(future));

    next?.process(
      contextualTelemetryItems: contextualTelemetryItems,
    );
  }

  /// Waits for any in flight telemetry submission, as well as flushing [next].
  @override
  Future<void> flush() {
    final next = this.next;

    return Future.wait([
      ..._outstandingFutures,
      if (next != null) next.flush(),
    ]);
  }

  Future<void> _transmit({
    required List<ContextualTelemetryItem> contextualTelemetry,
  }) async {
    logger.fine('Transmitting ${contextualTelemetry.length} telemetry items');

    final serialized = _serializeTelemetry(
      contextualTelemetry: contextualTelemetry,
    );
    final encoded = jsonEncode(serialized);

    try {
      final response = await httpClient
          .post(
            _ingestionEndpointUri,
            body: encoded,
          )
          .timeout(timeout);
      final result = response.statusCode >= 200 && response.statusCode < 300;

      if (!result) {
        logger.severe('Failed to submit telemetry: ${response.statusCode}');
      }
    } on Object catch (e) {
      logger.warning('Failed to submit telemetry: $e');
    }
  }

  List<Map<String, dynamic>> _serializeTelemetry({
    required List<ContextualTelemetryItem> contextualTelemetry,
  }) {
    final result = contextualTelemetry
        .map(
          (t) => _serializeTelemetryItem(
            contextualTelemetry: t,
          ),
        )
        .toList(growable: false);
    return result;
  }

  Map<String, dynamic> _serializeTelemetryItem({
    required ContextualTelemetryItem contextualTelemetry,
  }) {
    final serializedTelemetry = contextualTelemetry.telemetryItem.serialize(context: contextualTelemetry.context);
    final contextProperties = contextualTelemetry.context.properties;
    final serializedContext = contextProperties.isEmpty ? null : contextProperties;
    final result = <String, dynamic>{
      'name': contextualTelemetry.telemetryItem.envelopeName,
      'time': contextualTelemetry.telemetryItem.timestamp.toIso8601String(),
      'iKey': instrumentationKey,
      'tags': <String, dynamic>{
        'ai.internal.sdkVersion': '1',
        if (serializedContext != null) ...serializedContext,
      },
      'data': serializedTelemetry,
    };
    return result;
  }
}

/// A [Processor] that outputs messages that are useful in diagnosing telemetry processing.
///
/// Messages are output to the provided [logger], or to a default [Logger] if none is provided. All log messages are at
/// the [Level.INFO] level.
class DebugProcessor implements Processor {
  /// Creates an instance of [DebugProcessor].
  DebugProcessor({
    this.next,
    Logger? logger,
  }) : logger = logger ?? Logger('DebugProcessor');

  @override
  final Processor? next;

  /// A [Logger] to which processing information will be written.
  final Logger logger;

  /// Outputs a message detailing the telemetry being processed, then forwards the telemetry onto [next].
  @override
  void process({
    required List<ContextualTelemetryItem> contextualTelemetryItems,
  }) {
    logger.info('Processing ${contextualTelemetryItems.length} telemetry items:');

    for (final contextualTelemetryItem in contextualTelemetryItems) {
      final json =
          jsonEncode(contextualTelemetryItem.telemetryItem.serialize(context: contextualTelemetryItem.context));
      logger.info('  - ${contextualTelemetryItem.telemetryItem.runtimeType}: $json');
    }

    next?.process(
      contextualTelemetryItems: contextualTelemetryItems,
    );
  }

  /// Outputs a message, then forwards onto [next].
  @override
  Future<void> flush() async {
    logger.info('Flushing');
    await next?.flush();
  }
}
