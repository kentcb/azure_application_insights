import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart';
import 'context.dart';
import 'serialization.dart';

@immutable
abstract class Telemetry {
  DateTime get timestamp;

  String get envelopeName;

  Map<String, dynamic> getDataMap({
    @required TelemetryContext context,
  });
}

@immutable
class EventTelemetry implements Telemetry {
  EventTelemetry({
    @required this.name,
    this.properties,
    DateTime timestamp,
  })  : assert(name != null),
        assert(timestamp == null || timestamp.isUtc),
        timestamp = timestamp ?? DateTime.now().toUtc();

  @override
  String get envelopeName => 'AppEvents';

  @override
  final DateTime timestamp;

  final String name;
  final Map<String, Object> properties;

  @override
  Map<String, dynamic> getDataMap({
    @required TelemetryContext context,
  }) =>
      <String, dynamic>{
        'baseType': 'EventData',
        'baseData': <String, dynamic>{
          'ver': 2,
          'name': name,
          'properties': <String, dynamic>{
            ...context.additionalProperties,
            ...?properties,
          }
        },
      };
}

@immutable
class ExceptionTelemetry implements Telemetry {
  ExceptionTelemetry({
    @required this.severity,
    @required this.error,
    this.stackTrace,
    this.problemId,
    this.properties,
    DateTime timestamp,
  })  : assert(severity != null),
        assert(error != null),
        assert(timestamp == null || timestamp.isUtc),
        timestamp = timestamp ?? DateTime.now().toUtc();

  @override
  String get envelopeName => 'AppExceptions';

  @override
  final DateTime timestamp;

  final Severity severity;
  final Object error;
  final StackTrace stackTrace;
  final String problemId;
  final Map<String, Object> properties;

  @override
  Map<String, dynamic> getDataMap({
    @required TelemetryContext context,
  }) {
    final trace = stackTrace == null ? null : Trace.parse(stackTrace.toString());
    return <String, dynamic>{
      'baseType': 'ExceptionData',
      'baseData': <String, dynamic>{
        'ver': 2,
        'severityLevel': severity.intValue,
        'exceptions': [
          _getErrorDataMap(trace),
        ],
        'problemId': problemId ?? _generateProblemId(trace),
        'properties': <String, dynamic>{
          ...context.additionalProperties,
          ...?properties,
        },
      },
    };
  }

  String _generateProblemId(Trace trace) {
    // Make a best effort at disambiguating errors by using the error message and the first frame from any available stack trace.
    final code = '$error${trace == null || trace.frames.isEmpty ? '' : trace.frames[0].toString()}';
    final codeBytes = utf8.encode(code);
    final hash = sha1.convert(codeBytes);
    final result = hash.toString();
    return result;
  }

  Map<String, dynamic> _getErrorDataMap(Trace trace) => <String, dynamic>{
        'typeName': error.runtimeType.toString(),
        'message': error.toString(),
        'hasFullStack': trace != null,
        if (trace != null && trace.frames.isNotEmpty)
          'parsedStack': trace.frames
              .asMap()
              .entries
              .map((e) => <String, dynamic>{
                    'level': e.key,
                    'method': e.value.member,
                    'assembly': e.value.package,
                    'fileName': e.value.location,
                    'line': e.value.line,
                  })
              .toList(growable: false),
      };
}

@immutable
class PageViewTelemetry implements Telemetry {
  PageViewTelemetry({
    @required this.name,
    this.id,
    this.duration,
    this.url,
    this.properties,
    DateTime timestamp,
  })  : assert(name != null),
        assert(timestamp == null || timestamp.isUtc),
        timestamp = timestamp ?? DateTime.now().toUtc();

  @override
  String get envelopeName => 'AppPageViews';

  @override
  final DateTime timestamp;

  final String name;
  final Duration duration;
  final String id;
  final String url;
  final Map<String, Object> properties;

  @override
  Map<String, dynamic> getDataMap({
    @required TelemetryContext context,
  }) =>
      <String, dynamic>{
        'baseType': 'PageViewData',
        'baseData': <String, dynamic>{
          'ver': 2,
          'name': name,
          if (id != null) 'id': id,
          if (duration != null) 'duration': formatDurationForDotNet(duration),
          if (url != null) 'url': url,
          'properties': <String, dynamic>{
            ...context.additionalProperties,
            ...?properties,
          }
        },
      };
}

@immutable
class RequestTelemetry implements Telemetry {
  RequestTelemetry({
    @required this.id,
    @required this.duration,
    @required this.responseCode,
    this.source,
    this.name,
    this.success,
    this.url,
    this.properties,
    DateTime timestamp,
  })  : assert(id != null),
        assert(duration != null),
        assert(responseCode != null),
        assert(timestamp == null || timestamp.isUtc),
        timestamp = timestamp ?? DateTime.now().toUtc();

  @override
  String get envelopeName => 'AppRequests';

  @override
  final DateTime timestamp;

  final String id;
  final String source;
  final String name;
  final Duration duration;
  final String responseCode;
  final bool success;
  final String url;
  final Map<String, Object> properties;

  @override
  Map<String, dynamic> getDataMap({
    @required TelemetryContext context,
  }) =>
      <String, dynamic>{
        'baseType': 'RequestData',
        'baseData': <String, dynamic>{
          'ver': 2,
          'id': id,
          'duration': formatDurationForDotNet(duration),
          'responseCode': responseCode,
          if (source != null) 'source': source,
          if (name != null) 'name': name,
          if (success != null) 'success': success,
          if (url != null) 'url': url,
          'properties': <String, dynamic>{
            ...context.additionalProperties,
            ...?properties,
          }
        },
      };
}

@immutable
class TraceTelemetry implements Telemetry {
  TraceTelemetry({
    @required this.severity,
    @required this.message,
    this.properties,
    DateTime timestamp,
  })  : assert(severity != null),
        assert(message != null),
        assert(timestamp == null || timestamp.isUtc),
        timestamp = timestamp ?? DateTime.now().toUtc();

  @override
  String get envelopeName => 'AppTraces';

  @override
  final DateTime timestamp;

  final Severity severity;
  final String message;
  final Map<String, Object> properties;

  @override
  Map<String, dynamic> getDataMap({
    @required TelemetryContext context,
  }) =>
      <String, dynamic>{
        'baseType': 'MessageData',
        'baseData': <String, dynamic>{
          'ver': 2,
          'severityLevel': severity.intValue,
          'message': message,
          'properties': <String, dynamic>{
            ...context.additionalProperties,
            ...?properties,
          }
        },
      };
}

enum Severity {
  verbose,
  information,
  warning,
  error,
  critical,
}

extension SeverityExtensions on Severity {
  int get intValue {
    switch (this) {
      case Severity.verbose:
        return 0;
      case Severity.information:
        return 1;
      case Severity.warning:
        return 2;
      case Severity.error:
        return 3;
      case Severity.critical:
        return 4;
      default:
        throw UnsupportedError('Unsupported value: $this');
    }
  }
}
