# CLAUDE.md — TaskFlow

Persistent project context for Claude Code. Read this before making
architectural decisions; update it when a convention changes or a new one
is established.

## What this is

TaskFlow is an offline-first task/project management iOS app — a
portfolio piece (app 1 of 4) demonstrating Clean Architecture + MVVM-C,
modularized Swift Packages, Swift Concurrency + Combine, Core Data, and a
tested, CI-gated build. Full requirements: `taskflow-spec.md`. Locked
architecture decisions and build order: `taskflow-plan.md`. Design tokens:
`taskflow-styling-tokens.md`. Task-by-task execution checklist:
`taskflow-tasks.md`.

## Build environment note

This repo has been developed from a Windows machine without Xcode. There
is no `xcodebuild`/`xcrun` on this box, and the Windows Swift toolchain
cannot compile SwiftUI/UIKit/Core Data/LocalAuthentication/Swift Charts
code. **All Xcode-project and Swift source files in this repo are written
but not build-verified on this machine.** Treat any commit made under
this constraint as needing a real `xcodebuild`/Xcode open-and-build pass
on macOS before being trusted. If you are Claude Code running on macOS
with Xcode available, prefer that — actually build and run the test plans
rather than relying on prior "code review only" verification.

## Architecture

**Clean Architecture + MVVM-C**, three layers per feature module:

- **Domain**: entities (`Task`, `Project`, `Subtask`, `Priority`,
  `SyncStatus`), use cases (one type per use case, e.g.
  `CreateTaskUseCase`), repository protocols (`TaskRepository`,
  `ProjectRepository`). No Core Data, no networking, no SwiftUI types leak
  in here — pure Swift + Foundation.
- **Data**: repository implementations (Core Data local source + REST
  remote source), the sync engine (`SyncActor`) reconciling local/remote
  state behind the repository protocol — sync is never exposed directly
  to ViewModels.
- **Presentation**: SwiftUI views + ViewModels, one ViewModel per screen,
  owning `@Published`/`@Observable` state and calling into use cases (not
  repositories directly).
- **Coordinator**: UIKit `UINavigationController`-based coordinators
  (`AppCoordinator` → `TaskListCoordinator`, `ProjectListCoordinator`,
  `SettingsCoordinator`) wrap SwiftUI roots in `UIHostingController`.
  Navigation is pushed through coordinators, not `NavigationLink` state —
  this keeps navigation testable and centralized. Don't add
  `NavigationLink`-driven pushes once a coordinator owns that flow.

## Module boundaries (local SPM packages)

```
TaskFlow/                          # App target: composition root only —
                                    # App/Scene entry, DI wiring, AppDelegate
                                    # hook for coordinators. No feature logic.
Packages/
├── Core/                          # No dependency on TaskManagement.
│   ├── Networking/                # URLSession client behind a protocol,
│   │                              # DummyJSON DTOs
│   ├── Persistence/                # Core Data stack behind
│   │                              # PersistenceController protocol
│   ├── DI/                        # Factory-pattern container
│   └── Styling/                   # Styling.swift — colors, type scale,
│                                  # spacing from the design prototype
└── TaskManagement/                # Depends on Core. All task/project
    ├── Domain/                    # feature logic lives here.
    ├── Data/
    └── Presentation/
```

Rule: `Core` never imports `TaskManagement`. `TaskManagement`'s Domain
layer never imports `Data` or `Presentation` types from its own package
(use cases depend on repository *protocols*, defined in Domain).

## Dependency injection

Lightweight Factory-pattern container in `Core/DI` — explicit
registration, no reflection/property-wrapper magic, no third-party DI
framework. Composition root (the `TaskFlow` app target) registers
concrete implementations against protocols at launch; everything else
receives dependencies via initializer injection. If a new dependency
needs to be shared across ViewModels/use cases, register it in the
container rather than reaching for a singleton.

## Concurrency

- `async/await` + actors for the sync/data-flow pipeline and Core Data
  writes (`SyncActor`).
- Combine used deliberately for one thing: search debouncing —
  `@Published var searchQuery` → `.debounce(for: .milliseconds(300))` →
  `.removeDuplicates()` → triggers `SearchTasksUseCase`. Don't reach for
  Combine elsewhere; async/await is the default.

## Sync model (deliberate, documented limitation)

DummyJSON's `Todo` DTO is minimal (`todo`, `completed`, `userId`), so only
title + completion state round-trip through the remote API. Priority,
tags, project, subtasks, and due date live authoritatively in Core Data
only. Conflicts are simulated client-side by comparing `lastModified`
timestamps (last-write-wins, with a surfaced conflict banner in Task
Detail when both sides changed since last sync) — DummyJSON itself has no
real conflict semantics. This is intentional, not a gap to "fix"; call it
out in the README rather than trying to work around it.

## Naming conventions

- Use cases: `VerbNounUseCase` (e.g. `CreateTaskUseCase`,
  `ToggleTaskCompletionUseCase`).
- Repository protocols: `NounRepository` (e.g. `TaskRepository`); Core
  Data-backed implementations: `CoreDataTaskRepository`; remote sources:
  `RemoteTaskDataSource` / `DummyJSONTaskDataSource` style.
- ViewModels: `ScreenNameViewModel` (e.g. `TaskListViewModel`), paired
  1:1 with a `ScreenNameView`.
- Coordinators: `FeatureNameCoordinator`.

## Testing conventions

- Test target naming: `CoreTests`, `TaskManagementTests` — one per SPM
  package, mirroring `Sources/`.
- Test method naming: `test_<unitOfWork>_<scenario>_<expectedResult>`
  (e.g. `test_createTask_withEmptyTitle_throwsValidationError`).
- Use cases and ViewModels are tested against **mocked repository
  protocols** — never a real Core Data store or live network call in
  `TaskManagementTests`/`CoreTests`. `CoreTests` covers the networking
  client via mocked `URLProtocol` and the Core Data stack via an
  in-memory `NSPersistentContainer`.
- Required scenarios per use case, where applicable: happy path, network
  failure, sync conflict (inject a fake clock/timestamps — don't rely on
  real time), invalid input.
- UI tests live in a separate UI test target: one end-to-end primary-flow
  test, and a standalone accessibility audit test
  (`app.performAccessibilityAudit()`) that must fail the build on any
  finding — findings get fixed, not suppressed.

## Styling

Tokens live in `Core/Sources/Core/Styling/Styling.swift`, transcribed
from `taskflow-styling-tokens.md`. Note: the medium-priority amber hex
(`#B98D4B`) is a pixel-sampled approximation pending confirmation from the
prototype's CSS export — flagged in code, don't silently "fix" it without
that confirmation.

## Open questions already resolved (don't re-litigate)

Sync API (DummyJSON `/todos`), shared UI approach (`Styling.swift` in
`Core`, no standalone DesignKit package), second localized language
(pt-BR) — all locked in `taskflow-plan.md` intro. Only flag a divergence
here if something *newly* discovered contradicts these, not to reopen the
decision itself.
