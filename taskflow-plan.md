# TaskFlow — Plan

Decisions locked from spec.md open questions:
- Sync API: **DummyJSON `/todos`**
- Shared UI: **`Styling.swift` inside `Core`** (no standalone DesignKit
  package for now)
- Second localized language: **Portuguese (pt-BR)**

## 1. Repository structure

```
TaskFlow/
├── TaskFlow.xcodeproj
├── TaskFlow/                      # App target (composition root, App/Scene, DI wiring)
├── Packages/
│   ├── Core/                      # SPM package
│   │   ├── Sources/Core/
│   │   │   ├── Networking/        # URLSession client behind a protocol, DummyJSON DTOs
│   │   │   ├── Persistence/       # Core Data stack, NSManagedObject contracts
│   │   │   ├── DI/                # Factory-pattern container
│   │   │   └── Styling/           # Styling.swift — colors, type scale, spacing (from prototype)
│   │   └── Tests/CoreTests/
│   └── TaskManagement/            # SPM package
│       ├── Sources/TaskManagement/
│       │   ├── Domain/            # Entities, use cases, repository protocols
│       │   ├── Data/              # Repository implementations, sync engine
│       │   └── Presentation/      # SwiftUI views, ViewModels, Coordinators
│       └── Tests/TaskManagementTests/
├── .github/workflows/tests.yml
├── CLAUDE.md
└── README.md
```

## 2. Domain model (initial)

- `Task`: id, title, description, dueDate, priority (enum: low/medium/
  high), tags ([String]), projectID, subtasks ([Subtask]), isCompleted,
  syncStatus (enum: synced/pending/conflict), lastModified
- `Project`: id, name, colorTag, taskIDs
- `Subtask`: id, title, isCompleted
- Repository protocols: `TaskRepository`, `ProjectRepository` (each with
  local + remote-aware methods; sync engine sits behind the repository, not
  exposed to ViewModels)

## 3. Sync engine

- `SyncTasksUseCase`: pulls remote DummyJSON todos, diffs against local
  Core Data state by `lastModified`, applies last-write-wins with a
  surfaced conflict banner in Task Detail when both local and remote
  changed since last sync (demonstrates conflict handling deliberately,
  since DummyJSON itself has no real conflict semantics — conflicts are
  simulated client-side by comparing timestamps)
- Runs via `BGTaskScheduler` background sync + manual pull-to-refresh
- Mapping layer: DummyJSON `Todo` DTO ↔ domain `Task` (DummyJSON's model is
  minimal — `todo`, `completed`, `userId` — so most TaskFlow fields
  (priority, tags, project, subtasks, due date) live authoritatively in
  Core Data and only completion state + title round-trip through the API;
  this will be called out explicitly in the README as a deliberate,
  documented trade-off of using a public mock API for a demo sync layer)

## 4. Concurrency split

- async/await + actor (`SyncActor`) for the sync pipeline and Core Data
  writes
- Combine for search: `@Published var searchQuery` → `.debounce(for:
  .milliseconds(300))` → `.removeDuplicates()` → triggers
  `SearchTasksUseCase`

## 5. Navigation

- `AppCoordinator` (UIKit `UINavigationController`-based) owns:
  `TaskListCoordinator`, `ProjectListCoordinator`, `SettingsCoordinator`
- Each wraps its SwiftUI root view in `UIHostingController`; child
  navigation (task detail, add/edit) pushed via the coordinator, not
  `NavigationLink` state, to keep navigation testable and centralized

## 6. Biometric lock

- `LocalAuthentication` (`LAContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)`)
  on app foreground
- Passcode fallback: 4-6 digit code hashed and stored in Keychain
  (`kSecClassGenericPassword`), never stored in plaintext or UserDefaults

## 7. Testing plan

- `CoreTests`: networking client (mocked URLProtocol), Core Data stack
  (in-memory store), Keychain wrapper
- `TaskManagementTests`: use cases (happy path, network failure, sync
  conflict via injected clock/timestamps, invalid input — e.g. empty
  title, past due date on create), ViewModels (state transitions)
- UI test target: primary flow (create project → add task → complete →
  stats reflect it) + accessibility audit test
  (`app.performAccessibilityAudit()`) as its own test, failing on any
  finding

## 8. CI

`.github/workflows/tests.yml`: on `pull_request` to `main` — checkout,
select Xcode version, `xcodebuild test` for unit test plan, `xcodebuild
test` for UI test plan (or a combined test plan if simpler), fail the job
on any test failure.

## 9. Localization

String Catalog (`Localizable.xcstrings`) with `en` (base) and `pt-BR`.
Applied across TaskManagement presentation layer strings; dates/numbers
via `Locale`-aware formatters (no hardcoded date strings).

## 10. Build order (maps to tasks.md)

1. Xcode project scaffold + SPM packages (empty, wired, building green)
2. `Core`: Persistence stack + Networking client + DI container + Styling
3. `TaskManagement` Domain layer (entities, use cases, protocols) + unit
   tests for use cases against mocked repositories
4. `TaskManagement` Data layer (Core Data repository impl, DummyJSON
   remote source, sync engine) + unit tests
5. Presentation: Task List/Board, Task Detail, Add/Edit Task (match
   prototype)
6. Presentation: Project List, Stats view (Swift Charts), Settings +
   biometric lock
7. Coordinators wiring full navigation flow
8. UI tests (primary flow + accessibility audit)
9. Localization pass (pt-BR)
10. GitHub Actions CI
11. README + CLAUDE.md finalization
