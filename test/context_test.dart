import 'dart:convert';

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  _cloudContext();
  _deviceContext();
  _locationContext();
  _operationContext();
  _sessionContext();
  _userContext();
}

void _verifyContextData({
  @required TelemetryContext context,
  @required String expectedJson,
}) {
  final actual = context.properties;
  final actualJson = jsonEncode(actual);

  expect(actualJson, expectedJson);
}

void _cloudContext() {
  test(
    'cloud',
    () {
      _verifyContextData(
        context: TelemetryContext()
          ..cloud.role = 'role'
          ..cloud.roleInstance = 'role instance',
        expectedJson:
            '{"ai.cloud.role":"role","ai.cloud.roleInstance":"role instance"}',
      );
    },
  );
}

void _deviceContext() {
  test(
    'device',
    () {
      _verifyContextData(
        context: TelemetryContext()
          ..device.id = 'id'
          ..device.locale = 'locale'
          ..device.model = 'model'
          ..device.oemName = 'oem name'
          ..device.osVersion = 'os version'
          ..device.type = 'type',
        expectedJson:
            '{"ai.device.id":"id","ai.device.locale":"locale","ai.device.model":"model","ai.device.oemName":'
            '"oem name","ai.device.osVersion":"os version","ai.device.type":"type"}',
      );
    },
  );
}

void _locationContext() {
  test(
    'location',
    () {
      _verifyContextData(
        context: TelemetryContext()
          ..location.city = 'city'
          ..location.country = 'country'
          ..location.ip = 'ip'
          ..location.province = 'province',
        expectedJson:
            '{"ai.location.city":"city","ai.location.country":"country","ai.location.ip":"ip",'
            '"ai.location.province":"province"}',
      );
    },
  );
}

void _operationContext() {
  test(
    'operation',
    () {
      _verifyContextData(
        context: TelemetryContext()
          ..operation.correlationVector = 'correlation vector'
          ..operation.id = 'id'
          ..operation.name = 'name'
          ..operation.parentId = 'parent id'
          ..operation.syntheticSource = 'synthetic source',
        expectedJson:
            '{"ai.operation.correlationVector":"correlation vector","ai.operation.id":"id",'
            '"ai.operation.name":"name","ai.operation.parentId":"parent id","ai.operation.syntheticSource":"synthetic source"}',
      );
    },
  );
}

void _sessionContext() {
  test(
    'session',
    () {
      _verifyContextData(
        context: TelemetryContext()
          ..session.isFirst = true
          ..session.sessionId = 'id',
        expectedJson: '{"ai.session.isFirst":true,"ai.session.id":"id"}',
      );
    },
  );
}

void _userContext() {
  test(
    'user',
    () {
      _verifyContextData(
        context: TelemetryContext()
          ..user.accountId = 'account id'
          ..user.authUserId = 'auth user id'
          ..user.id = 'id',
        expectedJson:
            '{"ai.user.accountId":"account id","ai.user.authUserId":"auth user id","ai.user.userId":"id"}',
      );
    },
  );
}
