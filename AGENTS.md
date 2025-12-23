# AGENTS.md

subctrl is a Flutter (Cupertino-first) subscription tracker with currency
conversion and optional local notifications. Keep changes minimal and aligned
with the architecture below.

## Core rules

- Clean Architecture: presentation -> application -> domain. Application may depend on infrastructure. Domain never depends on Flutter or
  infrastructure.
- Presentation (`lib/presentation/`) owns UI, ViewModels, and localization. No
  Drift or HTTP in this layer.
- Application (`lib/application/`) is use cases only, UI-agnostic.
- Domain (`lib/domain/`) is pure business logic. Repository interfaces live in
  `lib/domain/repositories/`.
- Infrastructure (`lib/infrastructure/`) contains Drift DB/DAOs, HTTP clients,
  and platform services.

## Key entry points

- `lib/main.dart` bootstraps the app and tabs.
- `lib/application/app_dependencies.dart` wires repositories, use cases, and
  external clients; dispose `YahooFinanceCurrencyClient` when done.

## Storage and services

- Drift database in `lib/infrastructure/persistence/database.dart`, stored as
  `subctrl.db` in the app documents directory; `schemaVersion` is 1.
- Currency seeds: `lib/infrastructure/persistence/seeds/currency_seed_data.dart`.
- External rates: `YahooFinanceCurrencyClient` and
  `SubscriptionCurrencyRatesClient`.
- Notifications: `LocalNotificationsService` (timezone aware).

## Repo map

- `lib/presentation/` screens/widgets/viewmodels/l10n/theme
- `lib/application/` use cases and DI
- `lib/domain/` entities/repositories/services
- `lib/infrastructure/` persistence/currency/platform/repositories
- `test/` mirrors layers

## Coding and testing

- Follow `analysis_options.yaml` (package imports, trailing commas, prefer
  const/final, avoid dynamic calls, directive ordering).
- Add tests for new behavior (domain, application, presentation viewmodels,
  infrastructure clients). Use mocktail and avoid real network/DB in unit tests.
- Run `build_runner`/`drift_dev` and keep
  `lib/infrastructure/persistence/database.g.dart` updated after schema changes.
- No secrets; avoid logging sensitive data; keep external services behind
  adapters.
