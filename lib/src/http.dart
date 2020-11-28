import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'client.dart';

class TelemetryHttpClient extends BaseClient {
  TelemetryHttpClient({
    @required this.inner,
    @required this.telemetryClient,
  })  : assert(inner != null),
        assert(telemetryClient != null);

  final Client inner;
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
      properties: <String, Object>{
        'method': request.method,
        'headers': request.headers.entries.map((e) => '${e.key}=${e.value}').join(','),
        'contentLength': request.contentLength,
      },
      timestamp: timestamp,
    );

    return response;
  }
}
