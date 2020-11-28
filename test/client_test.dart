// ignore_for_file: cascade_invocations

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  _trackError();
  _trackEvent();
  _trackPageView();
  _trackRequest();
  _trackTrace();
}

void _trackError() {
  group(
    'trackError',
    () {
      test(
        'creates exception telemetry and forwards to processor',
        () {
          final processor = ProcessorMock();
          final sut = TelemetryClient(processor: processor);
          sut.trackError(
            severity: Severity.critical,
            error: 'an error',
          );

          expect(
            verify(processor.process(telemetryWithContext: captureAnyNamed('telemetryWithContext'))).captured.single,
            predicate<List<TelemetryWithContext>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetry;

              if (telemetry is ExceptionTelemetry) {
                return telemetry.severity == Severity.critical && telemetry.error == 'an error';
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
          final processor = ProcessorMock();
          final sut = TelemetryClient(processor: processor);
          sut.trackEvent(
            name: 'an event',
          );

          expect(
            verify(processor.process(telemetryWithContext: captureAnyNamed('telemetryWithContext'))).captured.single,
            predicate<List<TelemetryWithContext>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetry;

              if (telemetry is EventTelemetry) {
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
          final processor = ProcessorMock();
          final sut = TelemetryClient(processor: processor);
          sut.trackPageView(
            name: 'a page',
          );

          expect(
            verify(processor.process(telemetryWithContext: captureAnyNamed('telemetryWithContext'))).captured.single,
            predicate<List<TelemetryWithContext>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetry;

              if (telemetry is PageViewTelemetry) {
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
          final processor = ProcessorMock();
          final sut = TelemetryClient(processor: processor);
          sut.trackRequest(
            id: 'a request',
            duration: const Duration(milliseconds: 283),
            responseCode: '200',
          );

          expect(
            verify(processor.process(telemetryWithContext: captureAnyNamed('telemetryWithContext'))).captured.single,
            predicate<List<TelemetryWithContext>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetry;

              if (telemetry is RequestTelemetry) {
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

void _trackTrace() {
  group(
    'trackTrace',
    () {
      test(
        'creates trace telemetry and forwards to processor',
        () {
          final processor = ProcessorMock();
          final sut = TelemetryClient(processor: processor);
          sut.trackTrace(
            severity: Severity.critical,
            message: 'a message',
          );

          expect(
            verify(processor.process(telemetryWithContext: captureAnyNamed('telemetryWithContext'))).captured.single,
            predicate<List<TelemetryWithContext>>((v) {
              if (v.length != 1) {
                return false;
              }

              final telemetry = v[0].telemetry;

              if (telemetry is TraceTelemetry) {
                return telemetry.severity == Severity.critical && telemetry.message == 'a message';
              }

              return false;
            }),
          );
        },
      );
    },
  );
}
