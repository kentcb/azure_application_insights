import 'package:meta/meta.dart';
import 'context.dart';
import 'processing.dart';
import 'telemetry.dart';

class TelemetryClient {
  TelemetryClient({
    @required this.processor,
  }) : context = TelemetryContext();

  final TelemetryContext context;
  final Processor processor;

  void trackError({
    @required Severity severity,
    @required Object error,
    StackTrace stackTrace,
    String problemId,
    Map<String, Object> properties,
    DateTime timestamp,
  }) =>
      _track(ExceptionTelemetry(
        severity: severity,
        error: error,
        stackTrace: stackTrace,
        problemId: problemId,
        properties: properties,
        timestamp: timestamp,
      ));

  void trackEvent({
    @required String name,
    Map<String, Object> properties,
    DateTime timestamp,
  }) =>
      _track(EventTelemetry(
        name: name,
        properties: properties,
        timestamp: timestamp,
      ));

  void trackPageView({
    @required String name,
    String id,
    Duration duration,
    String url,
    Map<String, Object> properties,
    DateTime timestamp,
  }) =>
      _track(PageViewTelemetry(
        duration: duration,
        id: id,
        name: name,
        properties: properties,
        url: url,
        timestamp: timestamp,
      ));

  void trackRequest({
    @required String id,
    @required Duration duration,
    @required String responseCode,
    String source,
    String name,
    bool success,
    String url,
    Map<String, Object> properties,
    DateTime timestamp,
  }) =>
      _track(RequestTelemetry(
        duration: duration,
        id: id,
        name: name,
        properties: properties,
        responseCode: responseCode,
        source: source,
        success: success,
        url: url,
        timestamp: timestamp,
      ));

  void trackTrace({
    @required Severity severity,
    @required String message,
    Map<String, Object> properties,
    DateTime timestamp,
  }) =>
      _track(TraceTelemetry(
        severity: severity,
        message: message,
        properties: properties,
        timestamp: timestamp,
      ));

  void _track(Telemetry telemetry) {
    assert(telemetry != null);

    // We clone the context at this point so that any mutations prior to processing do not affect the outcome.
    final telemetryWithContext = TelemetryWithContext(
      telemetry: telemetry,
      context: context.clone(),
    );

    processor?.process(
      telemetryWithContext: [telemetryWithContext],
    );
  }

  Future<void> flush() => processor?.flush() ?? Future<void>.value(null);
}
