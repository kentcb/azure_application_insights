# Azure Application Insights
[![pub package](https://img.shields.io/pub/v/azure_application_insights.svg)](https://pub.dartlang.org/packages/azure_application_insights)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

## What?

This is a Dart library that integrates with Azure's Application Insights service. It allows you to push telemetry items into your Application Insights instance.

## Why?

Application Insights is a powerful tool for understanding how your software system is operating. In the context of Flutter applications, it allows you to deeply understand user interactions, performance, and faults in your application.

## Where?

Firstly, [install the azure_application_insights package](https://pub.dev/packages/azure_application_insights/install), then you can import it into your Dart code as follows:

```dart
import 'package:azure_application_insights/azure_application_insights.dart';
```

## How?

The only piece of information you need to integrate with Application Insights is your instrumentation key, which you can find inside the Azure portal. Open your Application Insights resource and look in the **Overview** tab.

Once you have your instrumentation key, you can construct a `TelemetryClient` as follows:

```dart
final processor = BufferedProcessor(
  next: TransmissionProcessor(
    instrumentationKey: instrumentationKey,
    httpClient: client,
    timeout: const Duration(seconds: 10),
  ),
);

final telemetryClient = TelemetryClient(
  processor: processor,
);
```

> NOTE: depending on your Azure environment, you may also wish to override the default ingestion endpoint. To do this,
> provide a value for the `ingestionEndpoint` parameter when creating a `TransmissionProcessor`.

This is a typical setup where telemetry items are buffered before being transmitted. Depending on your processing needs, you may have a need for more than one `TelemetryClient` in your application. For example, you might have one `TelemetryClient` that buffers telemetry items and is used for all telemetry other than errors, and a second that does not buffer and is used only to submit errors as promptly as possible. Please review the example code and API docs for alternative configurations.

Once you have a `TelemetryClient`, you can simply invoke the various methods to capture telemetry items:

```dart
telemetryClient.trackTrace(
  severity: Severity.information,
  message: 'Hello from Dart!',
);
```

You may also want to configure additional properties to be submitted with telemetry items. These can be configured in two places:

1. On the `TelemetryContext` associated with your `TelemetryClient`. Properties in this context object will be attached to every telemetry item submitted. Moreover, you can share a `TelemetryContext` between multiple `TelemetryClient` instances if desired.
2. Every method on `TelemetryClient` allows you to specify `additionalProperties` that will be captured only for that telemetry item. As the name suggests, these properties are in addition to those within the context.

Here are examples of both:

```dart
final telemetryClient = ...;

// 1. Properties associated with the TelemetryClient will be attached to
// all telemetry items submitted via that client.
telemetryClient.context
    // These built-in helpers simply set the pre-defined properties
    // Application Insights provides.
    ..applicationVersion = 'my version'
    ..device.type = 'Android';
    // But you can also set whatever property name you like.
    ..properties['environmentName'] = 'dev';

// 2. Additional properties can be bundled with individual telemetry items.
telemetryClient.traceTrace(
    severity: Severity.information,
    message: 'An example',
    additionalProperties: <String, Object>{
        'answer': 42,
    },
);
```

Of course, you can leverage whatever data sources and third party libraries make sense in order to populate properties. Typically you would use a package like [`device_info_plus`](https://pub.dev/packages/device_info_plus) to obtain information on the device and fill in the appropriate properties on the context.

### Flutter Integration

To submit crashes in Flutter applications as telemetry, follow the following recipe:

```dart
void main() {
    // You probably don't want to always run with crash reporting because it interferes with the normal
    // debug/development experience. Here we use kReleaseMode to only enable crash reporting for release builds, but
    // you can use whatever criteria and mechanism you like.
    if (kReleaseMode) {
        runWithCrashReporting(codeToExecute: run);
    } else {
        run();
    }
}

void run() => runApp(MyApp());

Future<void> runWithCrashReporting({
  required VoidCallback codeToExecute,
}) async {
  // Hook into Flutter error handling.
  FlutterError.onError = (details) => submitErrorAsTelemetry(
        isFatal: true,
        error: details.exception,
        trace: details.stack,
      );

  // Run the code to execute in a zone and handle all errors within.
  runZonedGuarded(
    codeToExecute,
    (error, trace) => submitErrorAsTelemetry(
      isFatal: true,
      error: error,
      trace: trace,
    ),
  );
}

Future<void> submitErrorAsTelemetry({
  required bool isFatal,
  required Object error,
  required StackTrace trace,
}) async {
  debugPrint('reporting ${isFatal ? 'fatal' : 'non-fatal'} error: $error');
  debugPrint('$trace');

  try {
    // Get your TelemetryClient instance here, perhaps by DI or some other mechanism.
    final telemetryClient = ...;

    // Get any additional properties for the crash report here, such as device information.
    final errorProperties = ...;

    // Write an error telemetry item.
    telemetryClient.trackError(
      error: error,
      stackTrace: trace,
      severity: isFatal ? Severity.critical : Severity.error,
      additionalProperties: errorProperties,
    );

    if (isFatal) {
      await telemetryClient.flush();
    }
  } on Object catch (e, t) {
    // We print synchronously here to ensure the output is written in the case we force exit.
    debugPrintSynchronously('Sending error telemetry failed: $e\r\n$t');
    debugPrintSynchronously('Original error: $error');
  } finally {
    if (isFatal && kReleaseMode) {
      debugPrintSynchronously('Forcing exit');
    }
  }
}
```

### HTTP Middleware

Whilst you can certainly use `TelemetryClient.trackRequest` to track HTTP requests yourself, you can save time by using the `TelemetryHttpClient` HTTP client. This class will automatically time requests and forward on the details of completed requests to a given `TelemetryClient` as request telemetry items.

Typical usage looks like this:

```dart
final telemetryHttpClient = TelemetryHttpClient(
  telemetryClient: telemetryClient,
  inner: Client(),
);

// This request will be captured as a request telemetry item.
await telemetryHttpClient.get('https://kent-boogaart.com/');
```

The `TelemetryHttpClient` could be one piece in a long chain of HTTP middleware - it is composable.

## Who?

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center"><a href="https://kent-boogaart.com/"><img src="https://avatars2.githubusercontent.com/u/1901832?v=4?s=100" width="100px;" alt="Kent Boogaart"/><br /><sub><b>Kent Boogaart</b></sub></a><br /><a href="https://github.com/kentcb/azure_application_insights/commits?author=kentcb" title="Code">💻</a> <a href="https://github.com/kentcb/azure_application_insights/commits?author=kentcb" title="Tests">⚠️</a> <a href="https://github.com/kentcb/azure_application_insights/commits?author=kentcb" title="Documentation">📖</a> <a href="#example-kentcb" title="Examples">💡</a></td>
      <td align="center"><a href="https://mernen.com/"><img src="https://avatars.githubusercontent.com/u/6412?v=4?s=100" width="100px;" alt="Daniel Luz"/><br /><sub><b>Daniel Luz</b></sub></a><br /><a href="https://github.com/kentcb/azure_application_insights/commits?author=mernen" title="Code">💻</a></td>
      <td align="center"><a href="https://www.sandbergit.se"><img src="https://avatars.githubusercontent.com/u/18184100?v=4?s=100" width="100px;" alt="Robert Sandberg"/><br /><sub><b>Robert Sandberg</b></sub></a><br /><a href="https://github.com/kentcb/azure_application_insights/commits?author=RCSandberg" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!