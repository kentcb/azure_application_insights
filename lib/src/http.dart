import 'dart:math';

import 'package:http/http.dart';

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
    required this.inner,
    required this.telemetryClient,
  });

  /// The inner HTTP client.
  final Client inner;

  /// The telemetry client.
  final TelemetryClient telemetryClient;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now().toUtc();
    final response = await inner.send(request);
    final contentLength = request.contentLength;
    stopwatch.stop();
    telemetryClient.trackRequest(
      id: _generateRequestId(),
      url: request.url.toString(),
      duration: stopwatch.elapsed,
      responseCode: response.statusCode.toString(),
      success: response.statusCode >= 200 && response.statusCode < 300,
      additionalProperties: <String, Object>{
        'method': request.method,
        'headers': request.headers.entries.map((e) => '${e.key}=${e.value}').join(','),
        if (contentLength != null) 'contentLength': contentLength,
      },
      timestamp: timestamp,
    );

    return response;
  }
}

// We generate our own request IDs rather than depending on an external package so that we reduce dependencies. At
// the time of writing, the uuid package did not support null safety, and I want this package to ASAP.
String _generateRequestId() {
  const chars = '0123456789abcdefghijklmnopqrstuvwxyz';

  final random = Random.secure();
  final result = StringBuffer();

  for (var i = 0; i < 16; ++i) {
    result.write(chars[random.nextInt(chars.length)]);
  }

  return result.toString();
}
