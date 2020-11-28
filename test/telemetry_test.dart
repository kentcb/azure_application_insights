import 'dart:convert';

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  _eventTelemetry();
  _exceptionTelemetry();
  _pageViewTelemetry();
  _requestTelemetry();
  _traceTelemetry();
}

void _verifyDataMap({
  @required Telemetry telemetry,
  @required TelemetryContext context,
  @required String expectedJson,
}) {
  final actual = telemetry.getDataMap(context: context);
  final actualJson = jsonEncode(actual);

  expect(actualJson, expectedJson);
}

void _eventTelemetry() {
  group(
    'EventTelemetry',
    () {
      test(
        'getDataMap',
        () {
          _verifyDataMap(
            telemetry: EventTelemetry(
              name: 'SomeEvent',
              timestamp: DateTime(2020, 10, 26).toUtc(),
              properties: const <String, Object>{},
            ),
            context: TelemetryContext(),
            expectedJson: '{"baseType":"EventData","baseData":{"ver":2,"name":"SomeEvent","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: EventTelemetry(
                name: 'SomeEvent',
                timestamp: DateTime(2020, 10, 26).toUtc(),
                properties: const <String, Object>{
                  'another': 1,
                }),
            context: TelemetryContext()..additionalProperties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"EventData","baseData":{"ver":2,"name":"SomeEvent","properties":{"foo":"bar","another":1}}}',
          );
        },
      );
    },
  );
}

void _exceptionTelemetry() {
  group(
    'ExceptionTelemetry',
    () {
      test(
        'getDataMap',
        () {
          _verifyDataMap(
            telemetry: ExceptionTelemetry(
              severity: Severity.error,
              error: 'a non-critical error',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":3,"exceptions":[{"typeName":"String",'
                '"message":"a non-critical error","hasFullStack":false}],"problemId":"ce2a6140b51626e15b01147dad0cf4ada5aa28d6",'
                '"properties":{}}}',
          );

          _verifyDataMap(
            telemetry: ExceptionTelemetry(
              severity: Severity.critical,
              error: 'a critical error',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":4,"exceptions":[{"typeName":"String",'
                '"message":"a critical error","hasFullStack":false}],"problemId":"ee31030288c93ce2336389a45bd2b64be5d4514d",'
                '"properties":{}}}',
          );

          _verifyDataMap(
            telemetry: ExceptionTelemetry(
              severity: Severity.critical,
              error: 'an error with an empty stack trace',
              stackTrace: StackTrace.empty,
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":4,"exceptions":[{"typeName":"String",'
                '"message":"an error with an empty stack trace","hasFullStack":true}],'
                '"problemId":"95762e69cc4165ab201b6cf22c9db54d8f6b8153","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: ExceptionTelemetry(
              severity: Severity.critical,
              error: 'an error with stack trace',
              stackTrace: StackTrace.fromString('#0      _first\n#1      _second'),
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":4,"exceptions":[{"typeName":"String",'
                '"message":"an error with stack trace","hasFullStack":true,"parsedStack":[{"level":0,"method":"_first",'
                '"assembly":null,"fileName":".","line":null},{"level":1,"method":"_second","assembly":null,'
                '"fileName":".","line":null}]}],"problemId":"021b549244a81c461387c9cef845b3daa368c581","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: ExceptionTelemetry(
              severity: Severity.critical,
              error: 'an error with properties',
              properties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..additionalProperties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":4,"exceptions":[{"typeName":"String",'
                '"message":"an error with properties","hasFullStack":false}],'
                '"problemId":"dc7b331564ab7acc456aee1c10e54adc8c710977","properties":{"foo":"bar","another":1}}}',
          );
        },
      );
    },
  );
}

void _pageViewTelemetry() {
  group(
    'PageViewTelemetry',
    () {
      test(
        'getDataMap',
        () {
          _verifyDataMap(
            telemetry: PageViewTelemetry(
              name: 'SomePage',
            ),
            context: TelemetryContext(),
            expectedJson: '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePage","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: PageViewTelemetry(
              name: 'SomePageWithId',
              id: 'an-id',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePageWithId","id":"an-id","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: PageViewTelemetry(
              name: 'SomePageWithDuration',
              duration: const Duration(milliseconds: 1268),
            ),
            context: TelemetryContext(),
            expectedJson: '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePageWithDuration","duration":'
                '"00:00:01.268000","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: PageViewTelemetry(
              name: 'SomePageWithUrl',
              url: 'http://something/',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePageWithUrl","url":"http://something/",'
                '"properties":{}}}',
          );

          _verifyDataMap(
            telemetry: PageViewTelemetry(
              name: 'SomePageWithProperties',
              properties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..additionalProperties['foo'] = 'bar',
            expectedJson: '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePageWithProperties","properties":'
                '{"foo":"bar","another":1}}}',
          );
        },
      );
    },
  );
}

void _requestTelemetry() {
  group(
    'RequestTelemetry',
    () {
      test(
        'getDataMap',
        () {
          _verifyDataMap(
            telemetry: RequestTelemetry(
              id: 'request-id',
              duration: const Duration(milliseconds: 2301),
              responseCode: '200',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RequestData","baseData":{"ver":2,"id":"request-id","duration":"00:00:02.301000",'
                '"responseCode":"200","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: RequestTelemetry(
              id: 'request-with-source',
              duration: const Duration(milliseconds: 2301),
              responseCode: '200',
              source: 'a source',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RequestData","baseData":{"ver":2,"id":"request-with-source","duration":"00:00:02.301000",'
                '"responseCode":"200","source":"a source","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: RequestTelemetry(
              id: 'request-with-name',
              duration: const Duration(milliseconds: 2301),
              responseCode: '200',
              name: 'a name',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RequestData","baseData":{"ver":2,"id":"request-with-name","duration":"00:00:02.301000",'
                '"responseCode":"200","name":"a name","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: RequestTelemetry(
              id: 'request-with-success',
              duration: const Duration(milliseconds: 2301),
              responseCode: '200',
              success: true,
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RequestData","baseData":{"ver":2,"id":"request-with-success","duration":"00:00:02.301000",'
                '"responseCode":"200","success":true,"properties":{}}}',
          );

          _verifyDataMap(
            telemetry: RequestTelemetry(
              id: 'request-with-url',
              duration: const Duration(milliseconds: 2301),
              responseCode: '200',
              url: 'http://somewhere/',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RequestData","baseData":{"ver":2,"id":"request-with-url","duration":"00:00:02.301000",'
                '"responseCode":"200","url":"http://somewhere/","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: RequestTelemetry(
              id: 'request-with-properties',
              duration: const Duration(milliseconds: 2301),
              responseCode: '200',
              properties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..additionalProperties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"RequestData","baseData":{"ver":2,"id":"request-with-properties","duration":"00:00:02.301000"'
                ',"responseCode":"200","properties":{"foo":"bar","another":1}}}',
          );
        },
      );
    },
  );
}

void _traceTelemetry() {
  group(
    'TraceTelemetry',
    () {
      test(
        'getDataMap',
        () {
          _verifyDataMap(
            telemetry: TraceTelemetry(
              severity: Severity.critical,
              message: 'a trace',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"MessageData","baseData":{"ver":2,"severityLevel":4,"message":"a trace","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: TraceTelemetry(
              severity: Severity.information,
              message: 'a trace with different severity',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"MessageData","baseData":{"ver":2,"severityLevel":1,"message":"a trace with different severity"'
                ',"properties":{}}}',
          );

          _verifyDataMap(
            telemetry: TraceTelemetry(
              severity: Severity.critical,
              message: 'a trace with properties',
              properties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..additionalProperties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"MessageData","baseData":{"ver":2,"severityLevel":4,"message":"a trace with properties",'
                '"properties":{"foo":"bar","another":1}}}',
          );
        },
      );
    },
  );
}
