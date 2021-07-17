// Mocks generated by Mockito 5.0.0 from annotations
// in azure_application_insights/test/mocks.dart.
// Do not manually edit this file.

import 'dart:async' as _i8;
import 'dart:convert' as _i12;
import 'dart:typed_data' as _i2;

import 'package:azure_application_insights/src/client.dart' as _i9;
import 'package:azure_application_insights/src/context.dart' as _i4;
import 'package:azure_application_insights/src/processing.dart' as _i3;
import 'package:azure_application_insights/src/telemetry.dart' as _i10;
import 'package:http/src/base_request.dart' as _i13;
import 'package:http/src/byte_stream.dart' as _i7;
import 'package:http/src/client.dart' as _i11;
import 'package:http/src/response.dart' as _i5;
import 'package:http/src/streamed_response.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

class _FakeUint8List extends _i1.Fake implements _i2.Uint8List {}

class _FakeProcessor extends _i1.Fake implements _i3.Processor {}

class _FakeTelemetryContext extends _i1.Fake implements _i4.TelemetryContext {}

class _FakeResponse extends _i1.Fake implements _i5.Response {}

class _FakeStreamedResponse extends _i1.Fake implements _i6.StreamedResponse {}

class _FakeByteStream extends _i1.Fake implements _i7.ByteStream {}

/// A class which mocks [Processor].
///
/// See the documentation for Mockito's code generation for more information.
class MockProcessor extends _i1.Mock implements _i3.Processor {
  MockProcessor() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void process({List<_i3.ContextualTelemetryItem>? contextualTelemetryItems}) =>
      super.noSuchMethod(Invocation.method(#process, [], {#contextualTelemetryItems: contextualTelemetryItems}),
          returnValueForMissingStub: null);
  @override
  _i8.Future<void> flush() => (super.noSuchMethod(Invocation.method(#flush, []),
      returnValue: Future.value(null), returnValueForMissingStub: Future.value()) as _i8.Future<void>);
}

/// A class which mocks [Response].
///
/// See the documentation for Mockito's code generation for more information.
class MockResponse extends _i1.Mock implements _i5.Response {
  MockResponse() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Uint8List get bodyBytes =>
      (super.noSuchMethod(Invocation.getter(#bodyBytes), returnValue: _FakeUint8List()) as _i2.Uint8List);
  @override
  String get body => (super.noSuchMethod(Invocation.getter(#body), returnValue: '') as String);
  @override
  int get statusCode => (super.noSuchMethod(Invocation.getter(#statusCode), returnValue: 0) as int);
  @override
  Map<String, String> get headers =>
      (super.noSuchMethod(Invocation.getter(#headers), returnValue: <String, String>{}) as Map<String, String>);
  @override
  bool get isRedirect => (super.noSuchMethod(Invocation.getter(#isRedirect), returnValue: false) as bool);
  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection), returnValue: false) as bool);
}

/// A class which mocks [TelemetryClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockTelemetryClient extends _i1.Mock implements _i9.TelemetryClient {
  MockTelemetryClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Processor get processor =>
      (super.noSuchMethod(Invocation.getter(#processor), returnValue: _FakeProcessor()) as _i3.Processor);
  @override
  _i4.TelemetryContext get context =>
      (super.noSuchMethod(Invocation.getter(#context), returnValue: _FakeTelemetryContext()) as _i4.TelemetryContext);
  @override
  void trackError(
          {_i10.Severity? severity,
          Object? error,
          StackTrace? stackTrace,
          String? problemId,
          Map<String, Object>? additionalProperties = const {},
          DateTime? timestamp}) =>
      super.noSuchMethod(
          Invocation.method(#trackError, [], {
            #severity: severity,
            #error: error,
            #stackTrace: stackTrace,
            #problemId: problemId,
            #additionalProperties: additionalProperties,
            #timestamp: timestamp
          }),
          returnValueForMissingStub: null);
  @override
  void trackEvent({String? name, Map<String, Object>? additionalProperties = const {}, DateTime? timestamp}) =>
      super.noSuchMethod(
          Invocation.method(
              #trackEvent, [], {#name: name, #additionalProperties: additionalProperties, #timestamp: timestamp}),
          returnValueForMissingStub: null);
  @override
  void trackPageView(
          {String? name,
          String? id,
          Duration? duration,
          String? url,
          Map<String, Object>? additionalProperties = const {},
          DateTime? timestamp}) =>
      super.noSuchMethod(
          Invocation.method(#trackPageView, [], {
            #name: name,
            #id: id,
            #duration: duration,
            #url: url,
            #additionalProperties: additionalProperties,
            #timestamp: timestamp
          }),
          returnValueForMissingStub: null);
  @override
  void trackRequest(
          {String? id,
          Duration? duration,
          String? responseCode,
          String? source,
          String? name,
          bool? success,
          String? url,
          Map<String, Object>? additionalProperties = const {},
          DateTime? timestamp}) =>
      super.noSuchMethod(
          Invocation.method(#trackRequest, [], {
            #id: id,
            #duration: duration,
            #responseCode: responseCode,
            #source: source,
            #name: name,
            #success: success,
            #url: url,
            #additionalProperties: additionalProperties,
            #timestamp: timestamp
          }),
          returnValueForMissingStub: null);
  @override
  void trackTrace(
          {_i10.Severity? severity,
          String? message,
          Map<String, Object>? additionalProperties = const {},
          DateTime? timestamp}) =>
      super.noSuchMethod(
          Invocation.method(#trackTrace, [], {
            #severity: severity,
            #message: message,
            #additionalProperties: additionalProperties,
            #timestamp: timestamp
          }),
          returnValueForMissingStub: null);
  @override
  _i8.Future<void> flush() => (super.noSuchMethod(Invocation.method(#flush, []),
      returnValue: Future.value(null), returnValueForMissingStub: Future.value()) as _i8.Future<void>);
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClientBase extends _i1.Mock implements _i11.Client {
  MockClientBase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<_i5.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#head, [url], {#headers: headers}),
          returnValue: Future.value(_FakeResponse())) as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> get(Uri? url, {Map<String, String>? headers}) => (super
          .noSuchMethod(Invocation.method(#get, [url], {#headers: headers}), returnValue: Future.value(_FakeResponse()))
      as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> post(Uri? url, {Map<String, String>? headers, Object? body, _i12.Encoding? encoding}) =>
      (super.noSuchMethod(Invocation.method(#post, [url], {#headers: headers, #body: body, #encoding: encoding}),
          returnValue: Future.value(_FakeResponse())) as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> put(Uri? url, {Map<String, String>? headers, Object? body, _i12.Encoding? encoding}) =>
      (super.noSuchMethod(Invocation.method(#put, [url], {#headers: headers, #body: body, #encoding: encoding}),
          returnValue: Future.value(_FakeResponse())) as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> patch(Uri? url, {Map<String, String>? headers, Object? body, _i12.Encoding? encoding}) =>
      (super.noSuchMethod(Invocation.method(#patch, [url], {#headers: headers, #body: body, #encoding: encoding}),
          returnValue: Future.value(_FakeResponse())) as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> delete(Uri? url, {Map<String, String>? headers, Object? body, _i12.Encoding? encoding}) =>
      (super.noSuchMethod(Invocation.method(#delete, [url], {#headers: headers, #body: body, #encoding: encoding}),
          returnValue: Future.value(_FakeResponse())) as _i8.Future<_i5.Response>);
  @override
  _i8.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#read, [url], {#headers: headers}), returnValue: Future.value(''))
          as _i8.Future<String>);
  @override
  _i8.Future<_i2.Uint8List> readBytes(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#readBytes, [url], {#headers: headers}),
          returnValue: Future.value(_FakeUint8List())) as _i8.Future<_i2.Uint8List>);
  @override
  _i8.Future<_i6.StreamedResponse> send(_i13.BaseRequest? request) =>
      (super.noSuchMethod(Invocation.method(#send, [request]), returnValue: Future.value(_FakeStreamedResponse()))
          as _i8.Future<_i6.StreamedResponse>);
}

/// A class which mocks [StreamedResponse].
///
/// See the documentation for Mockito's code generation for more information.
class MockStreamedResponseBase extends _i1.Mock implements _i6.StreamedResponse {
  MockStreamedResponseBase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.ByteStream get stream =>
      (super.noSuchMethod(Invocation.getter(#stream), returnValue: _FakeByteStream()) as _i7.ByteStream);
  @override
  int get statusCode => (super.noSuchMethod(Invocation.getter(#statusCode), returnValue: 0) as int);
  @override
  Map<String, String> get headers =>
      (super.noSuchMethod(Invocation.getter(#headers), returnValue: <String, String>{}) as Map<String, String>);
  @override
  bool get isRedirect => (super.noSuchMethod(Invocation.getter(#isRedirect), returnValue: false) as bool);
  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection), returnValue: false) as bool);
}
