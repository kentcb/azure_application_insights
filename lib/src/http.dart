import 'dart:math';

import 'package:azure_application_insights/src/client.dart';
import 'package:http/http.dart';

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
    this.appendHeader,
  });

  /// The inner HTTP client.
  final Client inner;

  /// The telemetry client.
  final TelemetryClient telemetryClient;

  /// Callback that determines whether or not to append certain header.
  ///
  /// [appendHeader] defaults to null, meaning all headers will be appended. Other examples:
  ///
  /// If only header named 'foo' should be appended when tracking request:
  /// ```dart
  /// TelemetryHttpClient(
  ///   ...
  ///   appendHeader: (header) => header == 'foo',
  /// )
  /// ```
  ///
  /// If no headers should be appended when tracking request:
  /// ```dart
  /// TelemetryHttpClient(
  ///   ...
  ///   appendHeader: (_) => false,
  /// )
  /// ```
  final bool Function(String header)? appendHeader;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final timestamp = DateTime.now().toUtc();

    final stopwatch = Stopwatch()..start();
    final response = await inner.send(request);
    stopwatch.stop();

    final contentLength = request.contentLength;
    final appendHeader = this.appendHeader ?? (_) => true;
    final headers = request.headers.entries
        .where((e) => appendHeader(e.key))
        .map((e) => '${e.key}=${e.value}')
        .join(',');
    telemetryClient.trackRequest(
      id: _generateRequestId(),
      url: request.url.toString(),
      duration: stopwatch.elapsed,
      responseCode: response.statusCode.toString(),
      success: response.statusCode >= 200 && response.statusCode < 300,
      additionalProperties: <String, Object>{
        'method': request.method,
        if (headers.isNotEmpty) 'headers': headers,
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
