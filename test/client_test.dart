// ignore_for_file: cascade_invocations

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  _constructor();
  _trackError();
  _trackEvent();
  _trackPageView();
  _trackRequest();
  _trackDependency();
  _trackTrace();
  _flush();
}

void _constructor() {
  group(
    'constructor',
    () {
      test(
        'an empty context is created by default',
        () {
          final processor = MockProcessor();
          final sut = TelemetryClient(processor: processor);

          expect(sut.context.properties.isEmpty, true);
        },
      );

      test(
        'a context can be explicitly provided',
        () {
          final context = TelemetryContext();
          context.properties['foo'] = 42;
          final processor = MockProcessor();
          final sut = TelemetryClient(
            processor: processor,
            context: context,
          );

          expect(sut.context.properties.isEmpty, false);
        },
      );
    },
  );
}

void _trackError() {
  group(
    'trackError',
    () {
      test(
        'creates exception telemetry and forwards to processor',
        () {
          final processor = MockProcessor();
          final sut = TelemetryClient(processor: processor);
          sut.trackError(
            severity: Severity.critical,
            error: 'an error',
          );

          expect(
            verify(processor.process(
                    contextualTelemetryItems:
                        captureAnyNamed('contextualTelemetryItems')))
                .captured
                .single,
            predicate<List<ContextualTelemetryItem>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetryItem;

              if (telemetry is ExceptionTelemetryItem) {
                return telemetry.severity == Severity.critical &&
                    telemetry.error == 'an error';
              }

              return false;
            }),
          );
        },
      );
    },
  );
}

void _trackEvent() {
  group(
    'trackEvent',
    () {
      test(
        'creates event telemetry and forwards to processor',
        () {
          final processor = MockProcessor();
          final sut = TelemetryClient(processor: processor);
          sut.trackEvent(
            name: 'an event',
          );

          expect(
            verify(processor.process(
                    contextualTelemetryItems:
                        captureAnyNamed('contextualTelemetryItems')))
                .captured
                .single,
            predicate<List<ContextualTelemetryItem>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetryItem;

              if (telemetry is EventTelemetryItem) {
                return telemetry.name == 'an event';
              }

              return false;
            }),
          );
        },
      );
    },
  );
}

void _trackPageView() {
  group(
    'trackPageView',
    () {
      test(
        'creates page view telemetry and forwards to processor',
        () {
          final processor = MockProcessor();
          final sut = TelemetryClient(processor: processor);
          sut.trackPageView(
            name: 'a page',
          );

          expect(
            verify(processor.process(
                    contextualTelemetryItems:
                        captureAnyNamed('contextualTelemetryItems')))
                .captured
                .single,
            predicate<List<ContextualTelemetryItem>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetryItem;

              if (telemetry is PageViewTelemetryItem) {
                return telemetry.name == 'a page';
              }

              return false;
            }),
          );
        },
      );
    },
  );
}

void _trackRequest() {
  group(
    'trackRequest',
    () {
      test(
        'creates request telemetry and forwards to processor',
        () {
          final processor = MockProcessor();
          final sut = TelemetryClient(processor: processor);
          sut.trackRequest(
            id: 'a request',
            duration: const Duration(milliseconds: 283),
            responseCode: '200',
          );

          expect(
            verify(processor.process(
                    contextualTelemetryItems:
                        captureAnyNamed('contextualTelemetryItems')))
                .captured
                .single,
            predicate<List<ContextualTelemetryItem>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetryItem;

              if (telemetry is RequestTelemetryItem) {
                return telemetry.id == 'a request' &&
                    telemetry.duration == const Duration(milliseconds: 283) &&
                    telemetry.responseCode == '200';
              }

              return false;
            }),
          );
        },
      );
    },
  );
}

void _trackDependency() {
  group(
    'trackDependency',
    () {
      test(
        'creates dependency telemetry and forwards to processor',
        () {
          final processor = MockProcessor();
          final sut = TelemetryClient(processor: processor);
          sut.trackDependency(
              id: 'a dependency call',
              duration: const Duration(milliseconds: 283),
              resultCode: '200',
              type: 'customType',
              name: 'somename',
              data: 'somedata');

          expect(
            verify(processor.process(
                    contextualTelemetryItems:
                        captureAnyNamed('contextualTelemetryItems')))
                .captured
                .single,
            predicate<List<ContextualTelemetryItem>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetryItem;

              if (telemetry is DependencyTelemetryItem) {
                return telemetry.id == 'a dependency call' &&
                    telemetry.duration == const Duration(milliseconds: 283) &&
                    telemetry.resultCode == '200' &&
                    telemetry.type == 'customType' &&
                    telemetry.name == 'somename' &&
                    telemetry.data == 'somedata';
              }

              return false;
            }),
          );
        },
      );
    },
  );
}

void _trackTrace() {
  group(
    'trackTrace',
    () {
      test(
        'creates trace telemetry and forwards to processor',
        () {
          final processor = MockProcessor();
          final sut = TelemetryClient(processor: processor);
          sut.trackTrace(
            severity: Severity.critical,
            message: 'a message',
          );

          expect(
            verify(processor.process(
                    contextualTelemetryItems:
                        captureAnyNamed('contextualTelemetryItems')))
                .captured
                .single,
            predicate<List<ContextualTelemetryItem>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetryItem;

              if (telemetry is TraceTelemetryItem) {
                return telemetry.severity == Severity.critical &&
                    telemetry.message == 'a message';
              }

              return false;
            }),
          );
        },
      );
    },
  );
}

void _flush() {
  group(
    'flush',
    () {
      test(
        'forwards to processor',
        () async {
          final processor = MockProcessor();
          final sut = TelemetryClient(processor: processor);
          await sut.flush();

          verify(processor.flush()).called(1);
        },
      );
    },
  );
}
