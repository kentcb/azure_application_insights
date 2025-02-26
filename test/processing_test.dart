// ignore_for_file: cascade_invocations

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  _bufferedProcessor();
  _transmissionProcessor();
}

void _bufferedProcessor() {
  group(
    'BufferedProcessor',
    () {
      test(
        'process buffers flushes synchronously if delay is zero',
        () {
          final next = MockProcessor();
          final sut = BufferedProcessor(
            capacity: 10,
            flushDelay: Duration.zero,
            next: next,
          );
          sut.process(
            contextualTelemetryItems: [
              ContextualTelemetryItem(
                telemetryItem: EventTelemetryItem(name: 'anything'),
                context: TelemetryContext(),
              ),
            ],
          );

          verify(next.process(
                  contextualTelemetryItems:
                      anyNamed('contextualTelemetryItems')))
              .called(1);
        },
      );

      test(
        'process buffers flushes synchronously if the capacity is surpassed',
        () {
          final next = MockProcessor();
          final sut = BufferedProcessor(
            capacity: 1,
            flushDelay: const Duration(seconds: 10),
            next: next,
          );
          sut.process(
            contextualTelemetryItems: [
              ContextualTelemetryItem(
                telemetryItem: EventTelemetryItem(name: 'anything'),
                context: TelemetryContext(),
              ),
              ContextualTelemetryItem(
                telemetryItem: EventTelemetryItem(name: 'anything'),
                context: TelemetryContext(),
              ),
            ],
          );

          verify(next.process(
                  contextualTelemetryItems:
                      anyNamed('contextualTelemetryItems')))
              .called(1);
        },
      );

      test(
        'process buffers until flush delay is surpassed',
        () {
          FakeAsync().run(
            (async) {
              final next = MockProcessor();
              final sut = BufferedProcessor(
                capacity: 10,
                flushDelay: const Duration(seconds: 10),
                next: next,
              );
              sut.process(
                contextualTelemetryItems: [
                  ContextualTelemetryItem(
                    telemetryItem: EventTelemetryItem(name: 'anything'),
                    context: TelemetryContext(),
                  ),
                ],
              );

              verifyNever(next.process(
                  contextualTelemetryItems:
                      anyNamed('contextualTelemetryItems')));
              async.elapse(const Duration(seconds: 5));
              verifyNever(next.process(
                  contextualTelemetryItems:
                      anyNamed('contextualTelemetryItems')));
              async.elapse(const Duration(seconds: 6));
              verify(next.process(
                      contextualTelemetryItems:
                          anyNamed('contextualTelemetryItems')))
                  .called(1);
            },
          );
        },
      );

      test(
        'flush does nothing if the buffer is empty',
        () {
          final next = MockProcessor();
          final sut = BufferedProcessor(
            next: next,
          );
          sut.flush();

          verifyNever(next.process(
              contextualTelemetryItems: anyNamed('contextualTelemetryItems')));
        },
      );

      test(
        'flush immediately forwards pending telemetry',
        () {
          final next = MockProcessor();
          final sut = BufferedProcessor(
            flushDelay: const Duration(seconds: 10),
            next: next,
          );
          sut.process(
            contextualTelemetryItems: [
              ContextualTelemetryItem(
                telemetryItem: EventTelemetryItem(name: 'anything'),
                context: TelemetryContext(),
              ),
            ],
          );

          verifyNever(next.process(
              contextualTelemetryItems: anyNamed('contextualTelemetryItems')));
          sut.flush();
          verify(next.process(
                  contextualTelemetryItems:
                      anyNamed('contextualTelemetryItems')))
              .called(1);
        },
      );
    },
  );
}

void _transmissionProcessor() {
  group(
    'TransmissionProcessor',
    () {
      test(
        'process asynchronously transmits telemetry via HTTP',
        () {
          final httpClient = MockClient();
          final sut = TransmissionProcessor(
            connectionString: 'InstrumentationKey=key',
            httpClient: httpClient,
            timeout: const Duration(seconds: 10),
          );

          sut.process(
            contextualTelemetryItems: [
              ContextualTelemetryItem(
                telemetryItem: EventTelemetryItem(
                  name: 'anything',
                  timestamp: DateTime.utc(2020, 10, 26),
                ),
                context: TelemetryContext(),
              ),
            ],
          );

          expect(
            verify(
              httpClient.post(
                any,
                body: captureAnyNamed('body'),
              ),
            ).captured.single,
            '[{"name":"AppEvents","time":"2020-10-26T00:00:00.000Z","iKey":"key","tags":{"ai.internal.sdkVersion":"1"},"data":{"baseType":"EventData","baseData":{"ver":2,"name":"anything","properties":{}}}}]',
          );
        },
      );

      test(
        'process synchronously forwards telemetry onto next',
        () {
          final httpClient = MockClient();
          final next = MockProcessor();
          final sut = TransmissionProcessor(
            connectionString: 'InstrumentationKey=key',
            httpClient: httpClient,
            timeout: const Duration(seconds: 10),
            next: next,
          );
          sut.process(
            contextualTelemetryItems: [
              ContextualTelemetryItem(
                telemetryItem: EventTelemetryItem(
                  name: 'anything',
                  timestamp: DateTime(2020, 10, 26).toUtc(),
                ),
                context: TelemetryContext(),
              ),
            ],
          );

          verify(next.process(
                  contextualTelemetryItems:
                      anyNamed('contextualTelemetryItems')))
              .called(1);
        },
      );

      test(
        'onError() callback receives the response status code when the HttpClient gives failure status code in TransmissionProcessor',
        () {
          void onError(
            List<ContextualTelemetryItem> contextualTelemetryItems,
            int? responseStatusCode,
            Object? exception,
          ) {
            final eventName = (contextualTelemetryItems
                    .firstOrNull?.telemetryItem as EventTelemetryItem?)
                ?.name;

            // Validating the data received from processor in onError() callback
            expect(eventName, 'mock event');
            expect(responseStatusCode, 400);
          }

          final httpClient = MockClient();
          final sut = TransmissionProcessor(
            connectionString: 'InstrumentationKey=key',
            httpClient: httpClient,
            timeout: const Duration(seconds: 10),
            onError: onError,
          );

          when(httpClient.post(
            any,
            body: anyNamed('body'),
          )).thenAnswer((_) async => Response('', 400));

          sut.process(
            contextualTelemetryItems: [
              ContextualTelemetryItem(
                telemetryItem: EventTelemetryItem(
                  name: 'mock event',
                  timestamp: DateTime.utc(2020, 10, 26),
                ),
                context: TelemetryContext(),
              ),
            ],
          );
        },
      );

      test(
        'onError() callback receives the exception object when the HttpClient throws exception during API call in TransmissionProcessor',
        () {
          final mockException = Exception('mock exception');

          void onError(
            List<ContextualTelemetryItem> contextualTelemetryItems,
            int? responseStatusCode,
            Object? exception,
          ) {
            final eventName = (contextualTelemetryItems
                    .firstOrNull?.telemetryItem as EventTelemetryItem?)
                ?.name;

            // Validating the data received from processor in onError() callback
            expect(eventName, 'mock event');
            expect(exception, mockException);
          }

          final httpClient = MockClient();
          final sut = TransmissionProcessor(
            connectionString: 'InstrumentationKey=key',
            httpClient: httpClient,
            timeout: const Duration(seconds: 10),
            onError: onError,
          );

          when(httpClient.post(
            any,
            body: anyNamed('body'),
          )).thenThrow(mockException);

          sut.process(
            contextualTelemetryItems: [
              ContextualTelemetryItem(
                telemetryItem: EventTelemetryItem(
                  name: 'mock event',
                  timestamp: DateTime.utc(2020, 10, 26),
                ),
                context: TelemetryContext(),
              ),
            ],
          );
        },
      );
    },
  );
}
