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
