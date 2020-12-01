import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'client.dart';

/// A [Client] that automatically forwards the details of all completed HTTP requests onto [telemetryClient] via
/// the [TelemetryClient.trackRequest] method.
///
/// Use an instance of [TelemetryHttpClient], either directly or as part of composed HTTP middleware, to ensure all
/// requests result in appropriate telemetry items being created via [telemetryClient]. All request telemetry items
/// will include durations, response codes, and other relevant properties set.
class TelemetryHttpClient extends BaseClient {
  /// Create an instance of [TelemetryHttpClient] that forwards HTTP requests onto [inner] and telemetry items onto
  /// [telemetryClient].
  TelemetryHttpClient({
    @required this.inner,
    @required this.telemetryClient,
  })  : assert(inner != null),
        assert(telemetryClient != null);

  /// The inner HTTP client.
  final Client inner;

  /// The telemetry client.
  final TelemetryClient telemetryClient;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now().toUtc();
    final response = await inner.send(request);
    stopwatch.stop();
    telemetryClient.trackRequest(
      id: Uuid().v4().toString(),
      url: request.url.toString(),
      duration: stopwatch.elapsed,
      responseCode: response?.statusCode?.toString(),
      success: response?.statusCode != null && (response.statusCode >= 200 && response.statusCode < 300),
      additionalProperties: <String, Object>{
        'method': request.method,
        'headers': request.headers.entries.map((e) => '${e.key}=${e.value}').join(','),
        'contentLength': request.contentLength,
      },
      timestamp: timestamp,
    );

    return response;
  }
}
