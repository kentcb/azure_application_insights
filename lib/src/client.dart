import 'package:azure_application_insights/src/context.dart';
import 'package:azure_application_insights/src/http.dart';
import 'package:azure_application_insights/src/processing.dart';
import 'package:azure_application_insights/src/telemetry.dart';

/// Used to write telemetry data to Azure's Application Insights service.
///
/// A [TelemetryClient] provides methods to construct the various telemetry items that are supported by Application
/// Insights. These items are then forwarded onto whatever [Processor] is used to construct the [TelemetryClient].
/// Typically, this will be a chain of processors to buffer and transmit telemetry items, per the following example:
///
/// ```
/// final telemetryClient = TelemetryClient(
///   processor: BufferedProcessor(
///     next: TransmissionProcessor(
///       instrumentationKey: instrumentationKey,
///       httpClient: Client(),
///       timeout: const Duration(seconds: 10),
///     ),
/// );
/// ```
///
/// You can then use the [trackError], [trackEvent], [trackPageView], [trackRequest], and [trackTrace] methods to
/// capture telemetry, though you will typically want to use [TelemetryHttpClient] rather than calling [trackRequest]
/// yourself.
///
/// See also:
/// * [TelemetryHttpClient]
class TelemetryClient {
  /// Creates a telemetry client.
  ///
  /// The provided [processor] will receive all telemetry events created by this [TelemetryClient].
  ///
  /// Callers can optionally specify a [context] to use, which facilitates sharing a single [TelemetryContext]
  /// between multiple [TelemetryClient] instances. If unspecified, a new [TelemetryContext] will be created instead.
  TelemetryClient({
    required this.processor,
    TelemetryContext? context,
  }) : context = context ?? TelemetryContext();

  /// A [Processor] that receives all telemetry items created by this [TelemetryClient].
  ///
  /// Processors are typically composed to attain the desired behavior. For example, a [TransmissionProcessor] is
  /// often wrapped in a [BufferedProcessor] so that telemetry items are queued up and transmitted in batches.
  final Processor processor;

  /// Contains context to be attached to every telemetry item created by this [TelemetryClient].
  ///
  /// The context is a mutable object that can be updated at any time. Whenever a telemetry item is created by this
  /// [TelemetryClient], the current context state is captured and attached to it for future submission.
  final TelemetryContext context;

  /// Creates an [ExceptionTelemetryItem] item and forwards it onto the [processor].
  void trackError({
    required Severity severity,
    required Object error,
    StackTrace? stackTrace,
    String? problemId,
    Map<String, Object> additionalProperties = const <String, Object>{},
    DateTime? timestamp,
  }) =>
      _track(
        ExceptionTelemetryItem(
          severity: severity,
          error: error,
          stackTrace: stackTrace,
          problemId: problemId,
          additionalProperties: additionalProperties,
          timestamp: timestamp,
        ),
      );

  /// Creates an [EventTelemetryItem] item and forwards it onto the [processor].
  void trackEvent({
    required String name,
    Map<String, Object> additionalProperties = const <String, Object>{},
    DateTime? timestamp,
  }) =>
      _track(
        EventTelemetryItem(
          name: name,
          additionalProperties: additionalProperties,
          timestamp: timestamp,
        ),
      );

  /// Creates a [PageViewTelemetryItem] item and forwards it onto the [processor].
  void trackPageView({
    required String name,
    String? id,
    Duration? duration,
    String? url,
    Map<String, Object> additionalProperties = const <String, Object>{},
    DateTime? timestamp,
  }) =>
      _track(
        PageViewTelemetryItem(
          duration: duration,
          id: id,
          name: name,
          additionalProperties: additionalProperties,
          url: url,
          timestamp: timestamp,
        ),
      );

  /// Creates a [RequestTelemetryItem] item and forwards it onto the [processor].
  void trackRequest({
    required String id,
    required Duration duration,
    required String responseCode,
    String? source,
    String? name,
    bool? success,
    String? url,
    Map<String, Object> additionalProperties = const <String, Object>{},
    DateTime? timestamp,
  }) =>
      _track(
        RequestTelemetryItem(
          duration: duration,
          id: id,
          name: name,
          additionalProperties: additionalProperties,
          responseCode: responseCode,
          source: source,
          success: success,
          url: url,
          timestamp: timestamp,
        ),
      );

  /// Creates a [DependencyTelemetryItem] item and forwards it onto the [processor].
  void trackDependency({
    required String name,
    String? id,
    String? type,
    String? resultCode,
    String? target,
    Duration? duration,
    bool? success,
    String? data,
    Map<String, Object> additionalProperties = const <String, Object>{},
    DateTime? timestamp,
  }) =>
      _track(
        DependencyTelemetryItem(
          duration: duration,
          id: id,
          name: name,
          additionalProperties: additionalProperties,
          resultCode: resultCode,
          target: target,
          success: success,
          data: data,
          type: type,
          timestamp: timestamp,
        ),
      );

  /// Creates a [TraceTelemetryItem] item and forwards it onto the [processor].
  void trackTrace({
    required Severity severity,
    required String message,
    Map<String, Object> additionalProperties = const <String, Object>{},
    DateTime? timestamp,
  }) =>
      _track(
        TraceTelemetryItem(
          severity: severity,
          message: message,
          additionalProperties: additionalProperties,
          timestamp: timestamp,
        ),
      );

  void _track(TelemetryItem telemetry) {
    // We clone the context at this point so that any mutations prior to processing do not affect the outcome.
    final contextualTelemetry = ContextualTelemetryItem(
      telemetryItem: telemetry,
      context: context.clone(),
    );

    processor.process(
      contextualTelemetryItems: [contextualTelemetry],
    );
  }

  /// Flushes this [TelemetryClient]'s [processor].
  Future<void> flush() => processor.flush();
}
