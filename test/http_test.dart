// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  _telemetryHttpClient();
}

void _telemetryHttpClient() {
  group(
    'TelemetryHttpClient',
    () {
      test(
        'requests are forwarded to inner',
        () async {
          final response = MockStreamedResponse();

          final inner = MockClient();
          when(
            inner.send(
              any,
            ),
          ).thenAnswer((realInvocation) => Future.value(response));

          final sut = TelemetryHttpClient(
            inner: inner,
            telemetryClient: MockTelemetryClient(),
          );
          await sut.get(Uri.parse('http://www.whatever.com'));

          verify(inner.send(any)).called(1);
        },
      );

      test(
        'request URLs are recorded',
        () async {
          final telemetryClient = MockTelemetryClient();
          final sut = TelemetryHttpClient(
            inner: MockClient(),
            telemetryClient: telemetryClient,
          );
          await sut.get(Uri.parse('http://www.whatever.com'));

          expect(
            verify(
              telemetryClient.trackRequest(
                id: anyNamed('id'),
                url: captureAnyNamed('url'),
                duration: anyNamed('duration'),
                responseCode: anyNamed('responseCode'),
                success: anyNamed('success'),
                additionalProperties: anyNamed('additionalProperties'),
                timestamp: anyNamed('timestamp'),
              ),
            ).captured.single,
            'http://www.whatever.com',
          );
        },
      );

      // Per the comments on the quiver package, it is not possible to control time with Dart's Stopwatch or DateTime classes unless you
      // use the clock package. I don't want to force that dependency on consumers, so am leaving this test out for now.
      //
      // test(
      //   'request durations are recorded',
      //   () {
      //     FakeAsync().run(
      //       (async) {
      //         final inner = MockClient();
      //         when(inner.send(any)).thenAnswer((_) {
      //           async.elapse(const Duration(seconds: 3));
      //           return Future.value(MockStreamedResponse());
      //         });

      //         final telemetryClient = MockTelemetryClient();
      //         final sut = TelemetryHttpClient(
      //           inner: inner,
      //           telemetryClient: telemetryClient,
      //         );
      //         sut.get('http://www.whatever.com');
      //         async.flushMicrotasks();

      //         expect(
      //           verify(
      //             telemetryClient.trackRequest(
      //               id: anyNamed('id'),
      //               url: anyNamed('url'),
      //               duration: captureAnyNamed('duration'),
      //               responseCode: anyNamed('responseCode'),
      //               success: anyNamed('success'),
      //               properties: anyNamed('additionalProperties'),
      //               timestamp: anyNamed('timestamp'),
      //             ),
      //           ).captured.single,
      //           const Duration(seconds: 3),
      //         );
      //       },
      //     );
      //   },
      // );

      test(
        'response codes are recorded',
        () async {
          Future<void> verifyStatusCode({
            required int statusCode,
            required bool isSuccess,
          }) async {
            final streamedResponse = MockStreamedResponse();
            when(streamedResponse.statusCode).thenReturn(statusCode);
            final inner = MockClient();
            when(
              inner.send(
                any,
              ),
            ).thenAnswer((realInvocation) => Future.value(streamedResponse));

            final telemetryClient = MockTelemetryClient();
            final sut = TelemetryHttpClient(
              inner: inner,
              telemetryClient: telemetryClient,
            );
            await sut.get(Uri.parse('http://www.whatever.com'));

            final captured = verify(
              telemetryClient.trackRequest(
                id: anyNamed('id'),
                url: anyNamed('url'),
                duration: anyNamed('duration'),
                responseCode: captureAnyNamed('responseCode'),
                success: captureAnyNamed('success'),
                additionalProperties: anyNamed('additionalProperties'),
                timestamp: anyNamed('timestamp'),
              ),
            ).captured;

            expect(captured[0], statusCode.toString());
            expect(captured[1], isSuccess);
          }

          await verifyStatusCode(
            statusCode: 200,
            isSuccess: true,
          );
          await verifyStatusCode(
            statusCode: 201,
            isSuccess: true,
          );
          await verifyStatusCode(
            statusCode: 401,
            isSuccess: false,
          );
          await verifyStatusCode(
            statusCode: 500,
            isSuccess: false,
          );
        },
      );

      test(
        'properties are recorded',
        () async {
          final inner = MockClient();
          final telemetryClient = MockTelemetryClient();
          final sut = TelemetryHttpClient(
            inner: inner,
            telemetryClient: telemetryClient,
          );
          await sut.post(
            Uri.parse('http://www.whatever.com'),
            headers: <String, String>{
              'first': 'value1',
              'second': 'value2',
            },
            body: 'a body',
          );

          final properties = verify(
            telemetryClient.trackRequest(
              id: anyNamed('id'),
              url: anyNamed('url'),
              duration: anyNamed('duration'),
              responseCode: anyNamed('responseCode'),
              success: anyNamed('success'),
              additionalProperties: captureAnyNamed('additionalProperties'),
              timestamp: anyNamed('timestamp'),
            ),
          ).captured.single as Map<String, Object>;

          expect(properties.length, 3);
          expect(properties['method'], 'POST');
          expect(properties['contentLength'], 6);
          expect(properties['headers'], 'first=value1,second=value2,content-type=text/plain; charset=utf-8');
        },
      );

      test(
        'timestamp is recorded',
        () async {
          final inner = MockClient();
          final telemetryClient = MockTelemetryClient();
          final sut = TelemetryHttpClient(
            inner: inner,
            telemetryClient: telemetryClient,
          );
          await sut.post(
            Uri.parse('http://www.whatever.com'),
            headers: <String, String>{
              'first': 'value1',
              'second': 'value2',
            },
            body: 'a body',
          );

          final timestamp = verify(
            telemetryClient.trackRequest(
              id: anyNamed('id'),
              url: anyNamed('url'),
              duration: anyNamed('duration'),
              responseCode: anyNamed('responseCode'),
              success: anyNamed('success'),
              additionalProperties: anyNamed('additionalProperties'),
              timestamp: captureAnyNamed('timestamp'),
            ),
          ).captured.single as DateTime;

          expect(timestamp, isNotNull);
        },
      );

      test(
        'can configure that no request headers are appended',
        () async {
          final inner = MockClient();
          final telemetryClient = MockTelemetryClient();
          final sut = TelemetryHttpClient(
            inner: inner,
            telemetryClient: telemetryClient,
            appendHeader: (_) => false,
          );
          await sut.post(
            Uri.parse('http://www.whatever.com'),
            headers: <String, String>{
              'first': 'value1',
              'second': 'value2',
            },
            body: 'a body',
          );

          final properties = verify(
            telemetryClient.trackRequest(
              id: anyNamed('id'),
              url: anyNamed('url'),
              duration: anyNamed('duration'),
              responseCode: anyNamed('responseCode'),
              success: anyNamed('success'),
              additionalProperties: captureAnyNamed('additionalProperties'),
              timestamp: anyNamed('timestamp'),
            ),
          ).captured.single as Map<String, Object>;

          expect(properties.length, 2);
          expect(properties['headers'], isNull);
          expect(properties['method'], 'POST');
          expect(properties['contentLength'], 6);
        },
      );

      test(
        'can configure that selection of request headers are appended',
        () async {
          final inner = MockClient();
          final telemetryClient = MockTelemetryClient();
          final sut = TelemetryHttpClient(
            inner: inner,
            telemetryClient: telemetryClient,
            appendHeader: (header) => header == 'first' || header == 'third',
          );
          await sut.post(
            Uri.parse('http://www.whatever.com'),
            headers: <String, String>{
              'first': 'value1',
              'second': 'value2',
              'third': 'value3',
            },
            body: 'a body',
          );

          final properties = verify(
            telemetryClient.trackRequest(
              id: anyNamed('id'),
              url: anyNamed('url'),
              duration: anyNamed('duration'),
              responseCode: anyNamed('responseCode'),
              success: anyNamed('success'),
              additionalProperties: captureAnyNamed('additionalProperties'),
              timestamp: anyNamed('timestamp'),
            ),
          ).captured.single as Map<String, Object>;

          expect(properties.length, 3);
          expect(properties['headers'], 'first=value1,third=value3');
          expect(properties['method'], 'POST');
          expect(properties['contentLength'], 6);
        },
      );
    },
  );
}
