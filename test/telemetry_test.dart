import 'dart:convert';

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:test/test.dart';

void main() {
  _eventTelemetry();
  _exceptionTelemetry();
  _pageViewTelemetry();
  _requestTelemetry();
  _dependencyTelemetry();
  _traceTelemetry();
}

void _verifyDataMap({
  required TelemetryItem telemetry,
  required TelemetryContext context,
  required String expectedJson,
}) {
  final actual = telemetry.serialize(context: context);
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
            telemetry: EventTelemetryItem(
              name: 'SomeEvent',
              timestamp: DateTime(2020, 10, 26).toUtc(),
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"EventData","baseData":{"ver":2,"name":"SomeEvent","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: EventTelemetryItem(
              name: 'SomeEvent',
              timestamp: DateTime(2020, 10, 26).toUtc(),
              additionalProperties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..properties['foo'] = 'bar',
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
            telemetry: ExceptionTelemetryItem(
              severity: Severity.error,
              error: 'a non-critical error',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":3,"exceptions":[{"typeName":"String","message":"a non-critical error","hasFullStack":false}],"problemId":"ce2a6140b51626e15b01147dad0cf4ada5aa28d6","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: ExceptionTelemetryItem(
              severity: Severity.critical,
              error: 'a critical error',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":4,"exceptions":[{"typeName":"String","message":"a critical error","hasFullStack":false}],"problemId":"ee31030288c93ce2336389a45bd2b64be5d4514d","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: ExceptionTelemetryItem(
              severity: Severity.critical,
              error: 'an error with an empty stack trace',
              stackTrace: StackTrace.empty,
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":4,"exceptions":[{"typeName":"String","message":"an error with an empty stack trace","hasFullStack":true}],"problemId":"95762e69cc4165ab201b6cf22c9db54d8f6b8153","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: ExceptionTelemetryItem(
              severity: Severity.critical,
              error: 'an error with stack trace',
              stackTrace:
                  StackTrace.fromString('#0      _first\n#1      _second'),
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":4,"exceptions":[{"typeName":"String","message":"an error with stack trace","hasFullStack":true,"parsedStack":[{"level":0,"method":"_first","assembly":null,"fileName":".","line":null},{"level":1,"method":"_second","assembly":null,"fileName":".","line":null}]}],"problemId":"021b549244a81c461387c9cef845b3daa368c581","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: ExceptionTelemetryItem(
              severity: Severity.critical,
              error: 'an error with properties',
              additionalProperties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..properties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"ExceptionData","baseData":{"ver":2,"severityLevel":4,"exceptions":[{"typeName":"String","message":"an error with properties","hasFullStack":false}],"problemId":"dc7b331564ab7acc456aee1c10e54adc8c710977","properties":{"foo":"bar","another":1}}}',
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
            telemetry: PageViewTelemetryItem(
              name: 'SomePage',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePage","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: PageViewTelemetryItem(
              name: 'SomePageWithId',
              id: 'an-id',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePageWithId","id":"an-id","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: PageViewTelemetryItem(
              name: 'SomePageWithDuration',
              duration: const Duration(milliseconds: 1268),
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePageWithDuration","duration":'
                '"00:00:01.268000","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: PageViewTelemetryItem(
              name: 'SomePageWithUrl',
              url: 'http://something/',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePageWithUrl","url":"http://something/",'
                '"properties":{}}}',
          );

          _verifyDataMap(
            telemetry: PageViewTelemetryItem(
              name: 'SomePageWithProperties',
              additionalProperties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..properties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"PageViewData","baseData":{"ver":2,"name":"SomePageWithProperties","properties":'
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
            telemetry: RequestTelemetryItem(
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
            telemetry: RequestTelemetryItem(
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
            telemetry: RequestTelemetryItem(
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
            telemetry: RequestTelemetryItem(
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
            telemetry: RequestTelemetryItem(
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
            telemetry: RequestTelemetryItem(
              id: 'request-with-properties',
              duration: const Duration(milliseconds: 2301),
              responseCode: '200',
              additionalProperties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..properties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"RequestData","baseData":{"ver":2,"id":"request-with-properties","duration":"00:00:02.301000"'
                ',"responseCode":"200","properties":{"foo":"bar","another":1}}}',
          );
        },
      );
    },
  );
}

void _dependencyTelemetry() {
  group(
    'DependencyTelemetry',
    () {
      test(
        'getDataMap',
        () {
          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'somename',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"somename","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'name',
              id: 'dependency-id',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"name","id":"dependency-id","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'name',
              type: 'sometype',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"name","type":"sometype","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'name',
              resultCode: 'someresultcode',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"name","resultCode":"someresultcode","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'name',
              target: 'https://someserver.com',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"name","target":"https://someserver.com","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'name',
              duration: const Duration(milliseconds: 2301),
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"name","duration":"00:00:02.301000","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'name',
              success: true,
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"name","success":true,"properties":{}}}',
          );

          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'name',
              data: 'http://somewhere/',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"name","data":"http://somewhere/","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: DependencyTelemetryItem(
              name: 'name',
              additionalProperties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..properties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"RemoteDependencyData","baseData":{"ver":2,"name":"name","properties":{"foo":"bar","another":1}}}',
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
            telemetry: TraceTelemetryItem(
              severity: Severity.critical,
              message: 'a trace',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"MessageData","baseData":{"ver":2,"severityLevel":4,"message":"a trace","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: TraceTelemetryItem(
              severity: Severity.information,
              message: 'a trace with different severity',
            ),
            context: TelemetryContext(),
            expectedJson:
                '{"baseType":"MessageData","baseData":{"ver":2,"severityLevel":1,"message":"a trace with different severity","properties":{}}}',
          );

          _verifyDataMap(
            telemetry: TraceTelemetryItem(
              severity: Severity.critical,
              message: 'a trace with properties',
              additionalProperties: const <String, Object>{
                'another': 1,
              },
            ),
            context: TelemetryContext()..properties['foo'] = 'bar',
            expectedJson:
                '{"baseType":"MessageData","baseData":{"ver":2,"severityLevel":4,"message":"a trace with properties","properties":{"foo":"bar","another":1}}}',
          );
        },
      );
    },
  );
}
