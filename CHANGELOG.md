## 4.0.0

- Upgrade to Dart 3

## 3.1.0

- Add ability to filter headers sent by `TelemetryHttpClient` (thanks @RCSandberg)

## 3.0.0

- Fix `TelemetryContext` so that the various getters and setters are nullable (thanks @mernen)
- Relevant `Processor` implementations now write to a `Logger` rather than directly to standard out

## 2.1.1

- Fix `TelemetryContext`'s `user.id` property to set the correct key (`ai.user.id` instead of `ai.user.userId`)

> **NOTE:** this is not a breaking change unless you are relying on the incorrect key (`ai.user.userId`) being set in some way, such as within custom Application Insights queries.

## 2.1.0

- Ability to specify the ingestion endpoint

## 2.0.0

- Null safety

## 1.0.3

- Further relax dependencies

## 1.0.2

- Relax dependencies

## 1.0.1

- Pub score fixes

## 1.0.0

- Initial version
