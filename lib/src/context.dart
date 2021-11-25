import 'client.dart';

/// Additional information to be attached to telemetry items produced by a [TelemetryClient].
///
/// A [TelemetryContext] is mutable wrapper around a [Map<String, dynamic>]. Every [TelemetryClient] has an instance
/// of [TelemetryContext] that will be attached to each telemetry item produced by it.
///
/// Most of the properties on this type, such as [device] and [user], are provided for convenience. They allow you to
/// easily get or set contextual information for commonly-known Application Insights properties without needing to know
/// the property keys. All properties, regardless of whether they're well-known or custom ones, can also be accessed
/// via [properties].
///
/// See also:
/// * [Public schema for Application Insights context tag keys](https://github.com/microsoft/ApplicationInsights-dotnet/blob/405fd6a9916956f2233520c8ab66110a1f9dcfbc/WEB/Schema/PublicSchema/ContextTagKeys.bond)
class TelemetryContext {
  /// Creates an instance of [TelemetryContext] that is initially empty.
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
  static const _applicationVersionKey = 'ai.application.ver';

  /// The application version to attach to telemetry items.
  String get applicationVersion => _contextMap[_applicationVersionKey];

  /// Setting will change the application version attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.application.ver` key on [TelemetryContext.properties].
  set applicationVersion(String value) => _contextMap.setOrRemove(_applicationVersionKey, value);

  /// Cloud-related properties to attach to telemetry items.
  final CloudContext cloud;

  /// Device-related properties to attach to telemetry items.
  final DeviceContext device;

  /// Location-related properties to attach to telemetry items.
  final LocationContext location;

  /// Operation-related properties to attach to telemetry items.
  final OperationContext operation;

  /// Session-related properties to attach to telemetry items.
  final SessionContext session;

  /// User-related properties to attach to telemetry items.
  final UserContext user;

  /// All properties attached to this context, including those encapsulated by convenience Dart properties such as
  /// [device] and [user].
  Map<String, dynamic> get properties => _contextMap;

  /// Creates a clone of this context that is completely independent of its source.
  TelemetryContext clone() => TelemetryContext._(Map<String, dynamic>.from(_contextMap));
}

/// Encapsulates cloud-related properties in a related [TelemetryContext].
class CloudContext {
  CloudContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;
  static const _prefix = 'ai.cloud.';
  static const _roleKey = '${_prefix}role';
  static const _roleInstanceKey = '${_prefix}roleInstance';

  /// The cloud role to attach to telemetry items.
  String get role => _contextMap[_roleKey];

  /// Setting will change the cloud role attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.cloud.role` key on [TelemetryContext.properties].
  set role(String value) => _contextMap.setOrRemove(_roleKey, value);

  /// The cloud role instance to attach to telemetry items.
  String get roleInstance => _contextMap[_roleInstanceKey];

  /// Setting will change the cloud role instance attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.cloud.roleInstance` key on [TelemetryContext.properties].
  set roleInstance(String value) => _contextMap.setOrRemove(_roleInstanceKey, value);

  /// Remove cloud properties from the associated [TelemetryContext.properties].
  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith(_prefix));
}

/// Encapsulates device-related properties in a related [TelemetryContext].
class DeviceContext {
  DeviceContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;
  static const _prefix = 'ai.device.';
  static const _idKey = '${_prefix}id';
  static const _localeKey = '${_prefix}locale';
  static const _modelKey = '${_prefix}model';
  static const _oemNameKey = '${_prefix}oemName';
  static const _osVersionKey = '${_prefix}osVersion';
  static const _typeKey = '${_prefix}type';

  /// The device ID to attach to telemetry items.
  String get id => _contextMap[_idKey];

  /// Setting will change the device ID attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.device.id` key on [TelemetryContext.properties].
  set id(String value) => _contextMap.setOrRemove(_idKey, value);

  /// The device locale to attach to telemetry items.
  String get locale => _contextMap[_localeKey];

  /// Setting will change the device locale attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.device.locale` key on [TelemetryContext.properties].
  set locale(String value) => _contextMap.setOrRemove(_localeKey, value);

  /// The device model to attach to telemetry items.
  String get model => _contextMap[_modelKey];

  /// Setting will change the devicemodel attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.device.model` key on [TelemetryContext.properties].
  set model(String value) => _contextMap.setOrRemove(_modelKey, value);

  /// The device OEM name to attach to telemetry items.
  String get oemName => _contextMap[_oemNameKey];

  /// Setting will change the device OEM name attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.device.eomName` key on [TelemetryContext.properties].
  set oemName(String value) => _contextMap.setOrRemove(_oemNameKey, value);

  /// The device operating system version to attach to telemetry items.
  String get osVersion => _contextMap[_osVersionKey];

  /// Setting will change the device operating system version attached to telemetry items submitted with
  /// this context.
  ///
  /// This is a convenience for setting the `ai.device.osVersion` key on [TelemetryContext.properties].
  set osVersion(String value) => _contextMap.setOrRemove(_osVersionKey, value);

  /// The device type to attach to telemetry items.
  String get type => _contextMap[_typeKey];

  /// Setting will change the device type attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.device.type` key on [TelemetryContext.properties].
  set type(String value) => _contextMap.setOrRemove(_typeKey, value);

  /// Remove device properties from the associated [TelemetryContext.properties].
  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith(_prefix));
}

/// Encapsulates location-related properties in a related [TelemetryContext].
class LocationContext {
  LocationContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;
  static const _prefix = 'ai.location.';
  static const _ipKey = '${_prefix}ip';
  static const _countryKey = '${_prefix}country';
  static const _provinceKey = '${_prefix}province';
  static const _cityKey = '${_prefix}city';

  /// The location IP address to attach to telemetry items.
  String get ip => _contextMap[_ipKey];

  /// Setting will change the location IP address attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.location.ip` key on [TelemetryContext.properties].
  set ip(String value) => _contextMap.setOrRemove(_ipKey, value);

  /// The location country to attach to telemetry items.
  String get country => _contextMap[_countryKey];

  /// Setting will change the location country attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.location.country` key on [TelemetryContext.properties].
  set country(String value) => _contextMap.setOrRemove(_countryKey, value);

  /// The location province to attach to telemetry items.
  String get province => _contextMap[_provinceKey];

  /// Setting will change the location province attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.location.province` key on [TelemetryContext.properties].
  set province(String value) => _contextMap.setOrRemove(_provinceKey, value);

  /// The location city to attach to telemetry items.
  String get city => _contextMap[_cityKey];

  /// Setting will change the location city attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.location.city` key on [TelemetryContext.properties].
  set city(String value) => _contextMap.setOrRemove(_cityKey, value);

  /// Remove location properties from the associated [TelemetryContext.properties].
  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith(_prefix));
}

/// Encapsulates operation-related properties in a related [TelemetryContext].
class OperationContext {
  OperationContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;
  static const _prefix = 'ai.operation.';
  static const _idKey = '${_prefix}id';
  static const _nameKey = '${_prefix}name';
  static const _parentIdKey = '${_prefix}parentId';
  static const _syntheticSourceKey = '${_prefix}syntheticSource';
  static const _correlationVectorKey = '${_prefix}correlationVector';

  /// The operation ID to attach to telemetry items.
  String get id => _contextMap[_idKey];

  /// Setting will change the operation ID attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.operation.id` key on [TelemetryContext.properties].
  set id(String value) => _contextMap.setOrRemove(_idKey, value);

  /// The operation name to attach to telemetry items.
  String get name => _contextMap[_nameKey];

  /// Setting will change the operation name attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.operation.name` key on [TelemetryContext.properties].
  set name(String value) => _contextMap.setOrRemove(_nameKey, value);

  /// The operation parent ID to attach to telemetry items.
  String get parentId => _contextMap[_parentIdKey];

  /// Setting will change the operation parent ID attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.operation.parentId` key on [TelemetryContext.properties].
  set parentId(String value) => _contextMap.setOrRemove(_parentIdKey, value);

  /// The operation synthetic source to attach to telemetry items.
  String get syntheticSource => _contextMap[_syntheticSourceKey];

  /// Setting will change the operation synthetic source attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.operation.syntheticSource` key on [TelemetryContext.properties].
  set syntheticSource(String value) => _contextMap.setOrRemove(_syntheticSourceKey, value);

  /// The operation correlation vector to attach to telemetry items.
  String get correlationVector => _contextMap[_correlationVectorKey];

  /// Setting will change the operation correlation vector attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.operation.correlationVector` key on [TelemetryContext.properties].
  set correlationVector(String value) => _contextMap.setOrRemove(_correlationVectorKey, value);

  /// Remove operation properties from the associated [TelemetryContext.properties].
  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith(_prefix));
}

/// Encapsulates session-related properties in a related [TelemetryContext].
class SessionContext {
  SessionContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;
  static const _prefix = 'ai.session.';
  static const _idKey = '${_prefix}id';
  static const _isFirstKey = '${_prefix}isFirst';

  /// The session ID to attach to telemetry items.
  String get sessionId => _contextMap[_idKey];

  /// Setting will change the session ID attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.session.id` key on [TelemetryContext.properties].
  set sessionId(String value) => _contextMap.setOrRemove(_idKey, value);

  /// The session "is first" flag to attach to telemetry items.
  bool get isFirst => _contextMap[_isFirstKey];

  /// Setting will change the session "is first" flag attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.session.isFirst` key on [TelemetryContext.properties].
  set isFirst(bool value) => _contextMap.setOrRemove(_isFirstKey, value);

  /// Remove session properties from the associated [TelemetryContext.properties].
  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith(_prefix));
}

/// Encapsulates user-related properties in a related [TelemetryContext].
class UserContext {
  UserContext._(this._contextMap);

  final Map<String, dynamic> _contextMap;
  static const _prefix = 'ai.user.';
  static const _accountIdKey = '${_prefix}accountId';
  static const _userIdKey = '${_prefix}id';
  static const _authUserIdKey = '${_prefix}authUserId';

  /// The user account ID to attach to telemetry items.
  String get accountId => _contextMap[_accountIdKey];

  /// Setting will change the user account ID attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.user.accountId` key on [TelemetryContext.properties].
  set accountId(String value) => _contextMap.setOrRemove(_accountIdKey, value);

  /// The user ID to attach to telemetry items.
  String get id => _contextMap[_userIdKey];

  /// Setting will change the user ID attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.userId` key on [TelemetryContext.properties].
  set id(String value) => _contextMap.setOrRemove(_userIdKey, value);

  /// The user authenticated ID to attach to telemetry items.
  String get authUserId => _contextMap[_authUserIdKey];

  /// Setting will change the user authenticated ID attached to telemetry items submitted with this context.
  ///
  /// This is a convenience for setting the `ai.user.authUserId` key on [TelemetryContext.properties].
  set authUserId(String value) => _contextMap.setOrRemove(_authUserIdKey, value);

  /// Remove user properties from the associated [TelemetryContext.properties].
  void clear() => _contextMap.removeWhere((key, dynamic value) => key.startsWith(_prefix));
}

extension _MapExtensions<K, V> on Map<K, V> {
  void setOrRemove(K key, V value) => value == null ? remove(key) : this[key] = value;
}
