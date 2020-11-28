import 'map_extensions.dart';

class TelemetryContext {
  TelemetryContext() : this._(<String, dynamic>{});

  TelemetryContext._(Map<String, dynamic> contextMap)
      : _contextMap = contextMap,
        cloud = CloudContext._(contextMap),
        device = DeviceContext._(contextMap),
        location = LocationContext._(contextMap),
        operation = OperationContext._(contextMap),
        session = SessionContext._(contextMap),
        user = UserContext._(contextMap);

  final Map<String, dynamic> _contextMap;

  String get applicationVersion => _contextMap['ai.application.ver'];
  set applicationVersion(String value) => _contextMap.setOrRemove('ai.application.ver', value);

  final CloudContext cloud;
  final DeviceContext device;
  final LocationContext location;
  final OperationContext operation;
  final SessionContext session;
  final UserContext user;

  Map<String, dynamic> get additionalProperties => _contextMap;

  Map<String, dynamic> getContextMap() => _contextMap.isEmpty ? null : _contextMap;

  TelemetryContext clone() => TelemetryContext._(Map<String, dynamic>.from(_contextMap));
}

class CloudContext {
  CloudContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;

  String get role => _contextMap['ai.cloud.role'];
  set role(String value) => _contextMap.setOrRemove('ai.cloud.role', value);

  String get roleInstance => _contextMap['ai.cloud.roleInstance'];
  set roleInstance(String value) => _contextMap.setOrRemove('ai.cloud.roleInstance', value);

  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith('ai.cloud.'));
}

class DeviceContext {
  DeviceContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;

  String get id => _contextMap['ai.device.id'];
  set id(String value) => _contextMap.setOrRemove('ai.device.id', value);

  String get locale => _contextMap['ai.device.locale'];
  set locale(String value) => _contextMap.setOrRemove('ai.device.locale', value);

  String get model => _contextMap['ai.device.model'];
  set model(String value) => _contextMap.setOrRemove('ai.device.model', value);

  String get oemName => _contextMap['ai.device.oemName'];
  set oemName(String value) => _contextMap.setOrRemove('ai.device.oemName', value);

  String get osVersion => _contextMap['ai.device.osVersion'];
  set osVersion(String value) => _contextMap.setOrRemove('ai.device.osVersion', value);

  String get type => _contextMap['ai.device.type'];
  set type(String value) => _contextMap.setOrRemove('ai.device.type', value);

  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith('ai.device.'));
}

class LocationContext {
  LocationContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;

  String get ip => _contextMap['ai.location.ip'];
  set ip(String value) => _contextMap.setOrRemove('ai.location.ip', value);

  String get country => _contextMap['ai.location.country'];
  set country(String value) => _contextMap.setOrRemove('ai.location.country', value);

  String get province => _contextMap['ai.location.province'];
  set province(String value) => _contextMap.setOrRemove('ai.location.province', value);

  String get city => _contextMap['ai.location.city'];
  set city(String value) => _contextMap.setOrRemove('ai.location.city', value);

  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith('ai.location.'));
}

class OperationContext {
  OperationContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;

  String get id => _contextMap['ai.operation.id'];
  set id(String value) => _contextMap.setOrRemove('ai.operation.id', value);

  String get name => _contextMap['ai.operation.name'];
  set name(String value) => _contextMap.setOrRemove('ai.operation.name', value);

  String get parentId => _contextMap['ai.operation.parentId'];
  set parentId(String value) => _contextMap.setOrRemove('ai.operation.parentId', value);

  String get syntheticSource => _contextMap['ai.operation.syntheticSource'];
  set syntheticSource(String value) => _contextMap.setOrRemove('ai.operation.syntheticSource', value);

  String get correlationVector => _contextMap['ai.operation.correlationVector'];
  set correlationVector(String value) => _contextMap.setOrRemove('ai.operation.correlationVector', value);

  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith('ai.operation.'));
}

class SessionContext {
  SessionContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;

  String get sessionId => _contextMap['ai.session.id'];
  set sessionId(String value) => _contextMap.setOrRemove('ai.session.id', value);

  bool get isFirst => _contextMap['ai.session.isFirst'];
  set isFirst(bool value) => _contextMap.setOrRemove('ai.session.isFirst', value);

  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith('ai.session.'));
}

class UserContext {
  UserContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;

  String get accountId => _contextMap['ai.user.accountId'];
  set accountId(String value) => _contextMap.setOrRemove('ai.user.accountId', value);

  String get id => _contextMap['ai.user.userId'];
  set id(String value) => _contextMap.setOrRemove('ai.user.userId', value);

  String get authUserId => _contextMap['ai.user.authUserId'];
  set authUserId(String value) => _contextMap.setOrRemove('ai.user.authUserId', value);

  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith('ai.user.'));
}
