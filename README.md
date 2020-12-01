# Azure Application Insights

[![pub package](https://img.shields.io/pub/v/azure_application_insights.svg)](https://pub.dartlang.org/packages/azure_application_insights)


## What?

This is a Dart library that integrates with Azure's Application Insights service. It allows you to push telemetry items into your Application Insights instance.

## Why?

Application Insights is a powerful tool for understanding how your software system is operating. In the context of Flutter applications, it allows you to deeply understand user interactions, performance, and faults in your application.

## Where?

You can install this library via pub by adding the following to your `pubspec.yaml`:

```yaml
dependencies:
  azure_application_insights: ^1.0.0
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

