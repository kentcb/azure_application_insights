import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';

export 'mocks.mocks.dart';

@GenerateMocks(
  [
    Processor,
    Response,
    TelemetryClient,
  ],
  customMocks: [
    MockSpec<Client>(as: #MockClientBase),
    MockSpec<StreamedResponse>(as: #MockStreamedResponseBase),
  ],
)
class MockClient extends MockClientBase {
  MockClient() {
    when(
      send(
        any,
      ),
    ).thenAnswer((realInvocation) => Future.value(MockStreamedResponse()));

    when(
      this.post(
        any,
        body: anyNamed('body'),
      ),
    ).thenAnswer((realInvocation) => Future.value(MockResponse()));
  }
}

class MockStreamedResponse extends MockStreamedResponseBase {
  MockStreamedResponse() {
    // ByteStream is a final class, so we need to provide a dummy in order to call when(stream) below.
    provideDummy(ByteStream.fromBytes([]));

    when(request).thenAnswer((_) => null);
    when(headers).thenAnswer((_) => const <String, String>{});
    when(isRedirect).thenAnswer((_) => false);
    when(persistentConnection).thenAnswer((_) => false);
    when(reasonPhrase).thenAnswer((_) => null);
    when(stream).thenAnswer((_) => ByteStream.fromBytes([]));
    when(statusCode).thenReturn(200);
  }
}
