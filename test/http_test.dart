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
          final inner = ClientMock();
          final sut = TelemetryHttpClient(
            inner: inner,
            telemetryClient: TelemetryClientMock(),
          );
          await sut.get('http://www.whatever.com');

          verify(inner.send(any)).called(1);
        },
      );

      test(
        'request URLs are recorded',
        () async {
          final telemetryClient = TelemetryClientMock();
          final sut = TelemetryHttpClient(
            inner: ClientMock(),
            telemetryClient: telemetryClient,
          );
          await sut.get('http://www.whatever.com');

          expect(
            verify(
              telemetryClient.trackRequest(
                id: anyNamed('id'),
                url: captureAnyNamed('url'),
                duration: anyNamed('duration'),
                responseCode: anyNamed('responseCode'),
                success: anyNamed('success'),
                properties: anyNamed('properties'),
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
      //         final inner = ClientMock();
      //         when(inner.send(any)).thenAnswer((_) {
      //           async.elapse(const Duration(seconds: 3));
      //           return Future.value(StreamedResponseMock());
      //         });

      //         final telemetryClient = TelemetryClientMock();
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
      //               properties: anyNamed('properties'),
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
            int statusCode,
            bool isSuccess,
          }) async {
            final streamedResponse = StreamedResponseMock();
            when(streamedResponse.statusCode).thenReturn(statusCode);
            final inner = ClientMock();
            when(inner.send(
              any,
            )).thenAnswer((realInvocation) => Future.value(streamedResponse));

            final telemetryClient = TelemetryClientMock();
            final sut = TelemetryHttpClient(
              inner: inner,
              telemetryClient: telemetryClient,
            );
            await sut.get('http://www.whatever.com');

            final captured = verify(
              telemetryClient.trackRequest(
                id: anyNamed('id'),
                url: anyNamed('url'),
                duration: anyNamed('duration'),
                responseCode: captureAnyNamed('responseCode'),
                success: captureAnyNamed('success'),
                properties: anyNamed('properties'),
                timestamp: anyNamed('timestamp'),
              ),
            ).captured;

            expect(captured[0], statusCode?.toString());
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
          final inner = ClientMock();
          final telemetryClient = TelemetryClientMock();
          final sut = TelemetryHttpClient(
            inner: inner,
            telemetryClient: telemetryClient,
          );
          await sut.post(
            'http://www.whatever.com',
            headers: <String, String>{
              'first': 'value1',
              'second': 'value2',
            },
            body: 'a body',
          );

          final Map<String, Object> properties = verify(
            telemetryClient.trackRequest(
              id: anyNamed('id'),
              url: anyNamed('url'),
              duration: anyNamed('duration'),
              responseCode: anyNamed('responseCode'),
              success: anyNamed('success'),
              properties: captureAnyNamed('properties'),
              timestamp: anyNamed('timestamp'),
            ),
          ).captured.single;

          expect(properties.length, 3);
          expect(properties['method'], 'POST');
          expect(properties['contentLength'], 6);
          expect(properties['headers'], 'first=value1,second=value2,content-type=text/plain; charset=utf-8');
        },
      );

      test(
        'timestamp is recorded',
        () async {
          final inner = ClientMock();
          final telemetryClient = TelemetryClientMock();
          final sut = TelemetryHttpClient(
            inner: inner,
            telemetryClient: telemetryClient,
          );
          await sut.post(
            'http://www.whatever.com',
            headers: <String, String>{
              'first': 'value1',
              'second': 'value2',
            },
            body: 'a body',
          );

          final DateTime timestamp = verify(
            telemetryClient.trackRequest(
              id: anyNamed('id'),
              url: anyNamed('url'),
              duration: anyNamed('duration'),
              responseCode: anyNamed('responseCode'),
              success: anyNamed('success'),
              properties: anyNamed('properties'),
              timestamp: captureAnyNamed('timestamp'),
            ),
          ).captured.single;

          expect(timestamp, isNotNull);
        },
      );
    },
  );
}
