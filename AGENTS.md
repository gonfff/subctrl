# AGENTS.md

---

This guide equips AI coding agents (and humans) to work effectively in this repository. It documents the application architecture, repository structure, technology stack, storage, and coding guidelines. Follow it to keep changes predictable, minimal, and aligned with the project’s long-term goals.

## Project Overview

---

**Subtrackr** is a mobile application for tracking recurring subscriptions.

- Primary platform: **iOS**
- Possible future platform: **Android**

Core features:

- Subscription tracking
- Currency conversion to a base currency
- Calendar view of upcoming payments
- Notifications and reminders
- Optional creation of system calendar events

The project prioritizes long-term maintainability, explicit behavior, and a clean domain model.

## Technology Stack

---

- **Framework**: Flutter
- **Language**: Dart
- **State management**: MVVM-style (ViewModel owns state + intents; UI is reactive)
- **Architecture**: Clean Architecture + MVVM
- **Local database**: **SQLite via Drift**
- **Notifications**: local notifications plugin (platform channels behind an adapter)
- **Currency rates**: external API client + caching
- **Calendar integration**: optional, behind an adapter

Dependencies must be actively maintained, justified, and easy to remove.

## Architecture

---

The application combines **Clean Architecture** with **MVVM**.

- **Clean Architecture** defines how the codebase is structured
- **MVVM** defines how UI screens are implemented

### Dependency rule (strict)

Presentation → Application → Domain
Presentation → Infrastructure
Application → Infrastructure
Domain → (no dependencies)

Only abstractions (interfaces) are allowed to point inward. Concrete implementations stay in outer layers.

### Layer responsibilities

#### Presentation (MVVM)

- Flutter widgets
- ViewModels (screen state + user intents)
- Navigation/routing
- UI-only formatting and mapping

Must NOT:

- contain business rules (recurrence, currency rules, scheduling)
- access the database directly
- call HTTP clients directly

#### Application (Use Cases)

- One use case per user intent
  (e.g. `AddSubscription`, `UpdateSubscription`, `GetUpcomingPayments`)
- Coordinates repositories and services
- Defines transaction boundaries
- Maps domain models to presentation DTOs/state

#### Domain

- Pure business logic
- Entities and value objects:
  - `Subscription`
  - `Money`
  - `Currency`
  - `RecurrenceRule`
  - `PaymentSchedule`
- Domain services for non-trivial logic (schedule generation, currency conversion rules)
- No Flutter, no database, no HTTP, no platform code

#### Infrastructure

- Drift/SQLite persistence (tables + DAOs)
- Repository implementations
- Currency rate provider (API + cache)
- Notification scheduling adapter
- Calendar integration adapter
- Mapping between persistence models and domain models

### Cross-cutting concerns

- Time must be injectable (clock abstraction) for deterministic tests
- Networking must be abstracted and mockable
- Offline-first behavior is preferred
- External I/O must be cancellable/time-limited where applicable

## Data Storage

---

### Primary storage

- **SQLite database managed via Drift**
- Data is stored locally and should work offline

### Schema principles

- Normalize core data (subscriptions, currencies, payment schedule metadata)
- Store computed/derived data only if it is expensive to recompute and has clear invalidation rules
- Use migrations for any schema changes (no destructive changes without migration)

### Security notes

- No secrets in code or config
- If any tokens/keys must be stored on-device, use secure storage (platform keychain/keystore) via an adapter

## Repository Structure

---

Suggested structure (names may vary, but the layering must remain):

/
├─ lib/
│ ├─ presentation/
│ │ ├─ screens/
│ │ ├─ widgets/
│ │ ├─ navigation/
│ │ └─ viewmodels/
│ │
│ ├─ application/
│ │ ├─ use_cases/
│ │ ├─ dto/
│ │ └─ mappers/
│ │
│ ├─ domain/
│ │ ├─ entities/
│ │ ├─ value_objects/
│ │ ├─ services/
│ │ └─ rules/
│ │
│ ├─ infrastructure/
│ │ ├─ persistence/ # drift database, tables, daos, migrations
│ │ ├─ repositories/ # implementations
│ │ ├─ currency/ # api + cache
│ │ ├─ notifications/ # scheduling adapters
│ │ └─ calendar/ # optional integration adapters
│ │
│ └─ main.dart
│
├─ test/
│ ├─ domain/
│ ├─ application/
│ └─ infrastructure/
│
├─ scripts/
├─ docs/
└─ AGENTS.md

Rules:

- `domain/` must not import anything from Flutter or infrastructure
- `presentation/` must not know about Drift tables/DAOs or HTTP clients
- Repository interfaces live in inner layers; implementations live in `infrastructure/`

## Coding Guidelines

---

### General

- Prefer clarity over cleverness
- Explicit behavior over implicit magic
- Avoid global mutable state
- Remove unused code and dependencies
- Use small, composable classes/functions

### Domain

- Prefer immutability
- Enforce invariants at construction time
- Keep logic deterministic (inject time and randomness)

### Application

- Use cases are thin orchestration units
- No UI concerns
- No persistence details
- All external interactions via interfaces

### Presentation

- Widgets are reactive and minimal
- ViewModels expose immutable state and explicit commands/intents
- Side effects go through use cases / adapters only

### Platform-specific functionality

- Must be behind an adapter in `infrastructure/`
- No direct platform channel calls from `presentation/` or `domain/`

## Testing Strategy

---

- **All new functionality must be covered by tests**
- **Minimum coverage for new code: 70%**
- Domain logic must be unit-tested
- Use cases must have focused tests
- Infrastructure tests should mock external systems and use temp DBs when needed
- UI/widget tests are encouraged for critical flows (optional, but preferred)

Tests must be deterministic, fast, and independent.

## Version Control

---

- Small, focused commits
- Meaningful commit messages
- No direct commits to protected branches
- Prefer rebase over merge when possible

## Documentation

---

- Keep documentation close to the code
- Update docs when behavior/architecture changes
- `AGENTS.md` is a source of truth and must be kept current

## Security and Privacy

---

- No hardcoded secrets
- Minimal data collection
- Subscription and financial-related data is sensitive by default
- External services must be documented and optional where possible

---

When in doubt, favor explicit design, minimal dependencies, and long-term maintainability.
