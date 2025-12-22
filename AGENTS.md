# AGENTS.md

---

This guide equips AI coding agents (and humans) to work effectively in this repository. It documents the application architecture, repository structure, technology stack, storage, and coding guidelines. Follow it to keep changes predictable, minimal, and aligned with the project’s long-term goals.

## Project Overview

---

**subctrl** is a Flutter-based subscription tracker with an iOS-first (Cupertino) shell that also runs on Android, macOS, and web targets.

- Tracks subscriptions (name, cost, billing period, purchase/next-payment dates, tags, and active state) via `SubscriptionsScreen`, `AddSubscriptionSheet`, and `SubscriptionCard`.
- Converts every subscription to a configurable base currency using cached exchange rates pulled from Yahoo Finance, with auto-download (toggle in settings) plus manual entry on the `CurrencyRatesScreen`.
- Lets users manage theme, locale, tags, currencies, and currency rate behavior from `SettingsSheet`, `CurrencySettingsScreen`, `TagSettingsScreen`, `SupportScreen`, and `About` links.
- Offers analytics placeholders for future work, localized strings in English and Russian (`lib/presentation/l10n/app_localizations.dart`), and a predictable MVVM flow.
- Prioritizes maintainability, explicit flows, and a clean domain model where business rules never escape the domain layer.

## Technology Stack

---

- **Framework**: Flutter 3.10 / Dart 3.10 with Cupertino widgets (`CupertinoApp`, `CupertinoTabScaffold`) and custom theming (`lib/presentation/theme/*`).
- **State management**: MVVM-style `ChangeNotifier` `ViewModel`s (`lib/presentation/viewmodels`) that expose immutable state + explicit commands/intents.
- **Architecture**: Clean Architecture with Presentation → Application → Domain → Infrastructure dependency flow, wired manually via `AppDependencies` (`lib/application/app_dependencies.dart`).
- **Local persistence**: SQLite via Drift (`lib/infrastructure/persistence`), `build_runner` + `drift_dev` generate `database.g.dart`, and the database lives in the application documents directory (`path_provider` + `path`).
- **Networking**: `http` package powering a bespoke `YahooFinanceCurrencyClient` (`lib/infrastructure/currency/yahoo_finance_client.dart`) and `SubscriptionCurrencyRatesClient` that filters requests for built-in currencies.
- **Localization**: Curated English + Russian resource map backed by Flutter’s global localization delegates.
- **Utilities**: `intl`, `sqlite3_flutter_libs`, `package_info_plus`.
- **Dev tooling**: `flutter_lints`, `mocktail` for mocks, `build_runner`, `drift_dev`.

Dependencies must be actively maintained, justified, and easy to drop when requirements change.

## Architecture

---

### Dependency rule (strict)

Presentation → Application → Domain
Presentation → Infrastructure
Application → Infrastructure

### Layer responsibilities

#### Presentation (MVVM)

- Lives in `lib/presentation/` and is strictly Flutter/UI code. Screens (`screens/`), widgets (`widgets/`), formatters (`formatters/`), mappers (`mappers/`), theme helpers (`theme/`), callback types (`types/`), localization (`l10n/`), and ViewModels (`viewmodels/`) all belong here.
- Entry point `lib/main.dart` wires `HomeTabs`, `SubscriptionsScreen`, `AnalyticsScreen`, and settings/locale/theme callbacks. `HomeTabs` keeps the current `ThemePreference`, base currency, locale, and auto-download toggle while passing `AppDependencies` to child screens.
- ViewModels extend `ChangeNotifier`, subscribe to `Stream`s exposed by use cases, handle currency refresh and search, and never reach for Drift/HTTP directly. `SubscriptionsViewModel` demonstrates this by listening to subscriptions/currencies/tags/rates and calling use cases such as `FetchSubscriptionRatesUseCase` when needed.
- Widgets render Cupertino UI, show modal sheets (`AddSubscriptionSheet`, `SettingsSheet`), expose actions (`CurrencyPicker`, `TagPicker`), and read localization strings from `AppLocalizations`.

#### Application (Use Cases)

- Organized by feature folders (`application/subscriptions`, `application/currencies`, `application/currency_rates`, `application/settings`, `application/tags`).
- Each file represents one user intent (e.g., `AddSubscriptionUseCase`, `WatchCurrencyRatesUseCase`, `SetThemePreferenceUseCase`). Use cases orchestrate multiple repositories/services, translate between layers, and remain UI-agnostic.
- The manual DI container `lib/application/app_dependencies.dart` wires repositories (`Drift*Repository`), the `YahooFinanceCurrencyClient`, and `SubscriptionCurrencyRatesClient`. It exposes bracelets for every use case and closes the HTTP client in `dispose()`.

#### Domain

- Contains pure business logic and data definitions under `lib/domain/entities`, `lib/domain/repositories`, and `lib/domain/services`.
- Key entities: `Subscription` + `BillingCycle` (auto-calculates `nextPaymentDate`), `Currency`, `CurrencyRate`, `Tag`.
- Repository interfaces (subscriptions, currencies, settings, currency rates, tags) describe streams and CRUD operations without mentioning Flutter or persistence.
- `CurrencyRatesProvider` (`domain/services`) abstracts rate fetching logic; `FetchSubscriptionRatesUseCase` depends on it rather than Firebase/HTTP details.

#### Infrastructure

- Houses everything that touches Drift, HTTP, or platform APIs (`lib/infrastructure/*`).
- `persistence/` defines the Drift schema (tables, migrations, seeds) plus the `AppDatabase` that exposes streams, inserts, and updates.
- `repositories/` (`drift_*` implementations) satisfy each domain repository interface and sit between Drift data models and domain entities.
- `currency/` contains `YahooFinanceCurrencyClient` (session management, crumb/cookie, parsing) and `SubscriptionCurrencyRatesClient` (filters quotes to built-in currencies and reused quotes).
- All concrete implementations live here; domain/use cases consume them through abstractions.

### Cross-cutting concerns

- `AppDependencies` keeps long-lived instances of `AppDatabase`, repositories, and HTTP clients so the presentation layer can request use cases without building dependencies repeatedly.
- Time is deterministic inside domain entities (`BillingCycle`), but the app currently relies on `DateTime.now()` for next payment calculation and rate freshness. Tests freeze time via `mocktail` when necessary.
- Networking is abstracted behind `CurrencyRatesProvider` and `http.Client`, so the application and presentation layers never directly issue HTTP requests.
- Currency rate refresh is throttled through `SubscriptionsViewModel` (auto-download toggle, manual refresh button) to avoid redundant API calls and to persist the latest response in `CurrencyRatesTable`.
- Localization strings live inside `AppLocalizations`, so UI code just calls getters rather than switching on raw codes.

## App wiring

---

- Entry point: `lib/main.dart` instantiates `AppDependencies`, loads persisted settings (theme, locale, base currency, auto-download), and renders `HomeTabs`.
- `HomeTabs` manages the two-core tabs (`Subscriptions`, `Analytics`) and always injects `AppDependencies` into the screens. It tracks theme, locale, base currency, and the currency auto-download toggle, which it forwards to `SubscriptionsScreen`.
- `SubscriptionsScreen` creates `SubscriptionsViewModel` by passing all needed use cases from `AppDependencies`. The ViewModel listens to repository streams, triggers currency refreshes, and exposes state for the widgets.
- Settings-related flows (theme/locale/base currency/tag/currencies/auto-download) run through `SettingsSheet`, `CurrencySettingsScreen`, `CurrencyRatesScreen`, and `TagSettingsScreen`, which in turn call the settings/currency/tag use cases wired in `AppDependencies`.

## Data Storage

---

- The single Drift database is defined in `lib/infrastructure/persistence/database.dart` and stored under `subctrl.db` inside the app documents directory.
- Tables: `subscriptions` (with `tagId`, `isActive`, `statusChangedAt`, `nextPaymentDate`), `currencies` (code/name/symbol/flags), `currency_rates` (base, quote, rate, fetchedAt), `settings` (key-value store for theme, locale, base currency, auto-download), and `tags` (id, name, colorHex).
- `AppDatabase` exposes streams (`watchSubscriptions`, `watchCurrencies`, `watchCurrencyRates`, `watchTags`) plus helpers (`ensureCurrenciesSeeded`, `upsertCurrencyRate`, `getSetting`).
- Schema version 8 ensures migrations: new tables added progressively, `isActive`/`statusChangedAt` columns added for subscriptions, `isEnabled` column for currencies, seed data marked as built-in, new tags table, and `tagId` column added last. Refer to the `MigrationStrategy` block for exact steps.
- `currency_seed_data.dart` lists Yahoo Finance-supported currencies used when seeding the database so the UI only shows the allowed set until the user adds customs.

## Repository Structure

---

```
/
├─ android/
├─ ios/
├─ macos/
├─ web/
├─ lib/
│  ├─ presentation/
│  │  ├─ screens/
│  │  ├─ widgets/
│  │  ├─ viewmodels/
│  │  ├─ formatters/
│  │  ├─ mappers/
│  │  ├─ theme/
│  │  ├─ types/
│  │  └─ l10n/
│  ├─ application/
│  │  ├─ subscriptions/
│  │  ├─ currencies/
│  │  ├─ currency_rates/
│  │  ├─ settings/
│  │  ├─ tags/
│  │  └─ app_dependencies.dart
│  ├─ domain/
│  │  ├─ entities/
│  │  ├─ repositories/
│  │  └─ services/
│  ├─ infrastructure/
│  │  ├─ persistence/
│  │  │  ├─ tables/
│  │  │  ├─ seeds/
│  │  │  └─ database.dart
│  │  ├─ repositories/
│  │  └─ currency/
│  └─ main.dart
├─ test/
│  ├─ domain/
│  ├─ application/
│  ├─ infrastructure/
│  └─ presentation/
├─ analysis_options.yaml
├─ pubspec.yaml
├─ AGENTS.md
```

Rules:

- `domain/` must not import Flutter or infrastructure. Keep entities, value objects, and services pure.
- `presentation/` never touches Drift tables, DAOs, or HTTP: it only talks to use cases/viewmodels and reads localization/theme helpers.
- Repository interfaces live in `lib/domain/repositories`; concrete implementations live under `lib/infrastructure/repositories`.

## Coding Guidelines

---

- Prefer clarity over cleverness. Break large algorithms into small, descriptive functions/objects.
- Favor explicit behavior; avoid hidden logic paths. `SubscriptionsViewModel` is a good example of guarding state transitions explicitly before notifying listeners.
- Avoid global mutable state. Dependencies are passed via constructors (`ViewModel`s, use cases) and wired through `AppDependencies`.
- Keep `application/` use cases UI-agnostic — no Flutter widgets, no platform channels, no persistence details. They orchestrate repositories/services and translate between layers.
- Keep `presentation/` reactive and minimal. Widgets should delegate side effects to use cases/viewmodels and read strings from `AppLocalizations`.
- Domain entities enforce invariants at construction time (e.g., `Subscription` always has `nextPaymentDate`), even though the app currently sources the clock from `DateTime.now()`.
- `analysis_options.yaml` (powered by `flutter_lints`) enforces `always_use_package_imports`, `require_trailing_commas`, `prefer_const_constructors`, `avoid_dynamic_calls`, `directives_ordering`, and `prefer_final_locals`. Respect these in new files.
- Remove unused code/dependencies, keep files focused, and keep imports sorted per the lint configuration.

## Testing Strategy

---

- All new functionality must be covered by tests; new code should aim for at least 70% coverage.
- `test/domain` exercises pure business rules (e.g., `test/domain/entities/subscription_test.dart` verifies `BillingCycle` behavior and `copyWith` filtering).
- `test/application` verifies use-case orchestration and repository interactions (e.g., `test/application/subscriptions/subscription_use_cases_test.dart`).
- `test/infrastructure` keeps HTTP/business adapters deterministic; the existing currency client tests (`subscription_currency_rates_client_test.dart`, `yahoo_finance_client_test.dart`) stub `http.Client`/`CurrencyRepository`.
- `test/presentation/viewmodels` covers ViewModel logic (`subscriptions_view_model_test.dart`, `currency_rates_view_model_test.dart`, etc.) using `mocktail` to stub use cases and ensure state transitions are explicit.
- Use `mocktail` to stub interfaces, prefer synchronous expectations, and avoid hitting real network or Drift databases in ViewModel/unit tests. Infrastructure tests may mock HTTP responses.
- `build_runner` + `drift_dev` must be run when schema/tables change to regenerate `database.g.dart`; keep generated files checked in (`lib/infrastructure/persistence/database.g.dart`).

## Documentation

---

- Keep documentation close to the code. Update this `AGENTS.md` whenever behavior/architecture changes.
- Mention any external services or APIs you wire in (e.g., Yahoo Finance) in the surrounding code/doc comments so future contributors can audit dependencies.

## Security and Privacy

---

- Do not hardcode secrets or credentials into the codebase.
- Treat subscription/financial data as sensitive; avoid unnecessary logging or sharing.
- External services must be documented, optional, and accessed through adapters so they can be mocked/stubbed for testing.
