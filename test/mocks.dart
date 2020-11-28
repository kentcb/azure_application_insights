import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

class ProcessorMock extends Mock implements Processor {}

class StreamMock extends Mock implements Stream {}

class StreamedResponseMock extends Mock implements StreamedResponse {
  StreamedResponseMock() {
    when(stream).thenAnswer((_) => ByteStream.fromBytes([]));
    when(statusCode).thenReturn(200);
  }
}

class ResponseMock extends Mock implements Response {}

class ClientMock extends Mock implements Client {
  ClientMock() {
    when(send(
      any,
    )).thenAnswer((realInvocation) => Future.value(StreamedResponseMock()));

    when(this.post(
      any,
      body: anyNamed('body'),
    )).thenAnswer((realInvocation) => Future.value(ResponseMock()));
  }
}

class TelemetryClientMock extends Mock implements TelemetryClient {}
