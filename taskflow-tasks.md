# TaskFlow — Tasks

Execute in order inside the project folder with Claude Code. Each task
should end in a green build (and green tests, once they exist) before
moving to the next. Flag any divergence from plan.md explicitly rather than
silently resolving it.

## T1 — Project scaffold
- [ ] Create Xcode project `TaskFlow` (iOS app target, SwiftUI lifecycle +
      minimal UIKit App Delegate hook if needed for coordinators)
- [ ] Create local SPM packages `Core` and `TaskManagement` under
      `Packages/`, add as local package dependencies to the app target
- [ ] Set up empty module folder structure per plan.md §1
- [ ] Create `CLAUDE.md` with project context (architecture summary, module
      boundaries, conventions: naming, DI pattern, test naming)
- [ ] Verify: project builds with empty packages wired in

## T2 — Core: Persistence
- [ ] Core Data model (`Task`, `Project`, `Subtask` entities matching
      plan.md §2)
- [ ] `NSPersistentContainer` stack wrapped behind a protocol
      (`PersistenceController`), with an in-memory mode for tests
- [ ] Verify: `CoreTests` — persistence stack saves/fetches in-memory

## T3 — Core: Networking
- [ ] `APIClient` protocol + `URLSession`-based implementation
- [ ] DummyJSON `Todo` DTO + endpoint methods (GET list, GET by id, POST,
      PUT, DELETE) against `https://dummyjson.com/todos`
- [ ] Verify: `CoreTests` — client tested against mocked `URLProtocol`,
      no live network calls in unit tests

## T4 — Core: DI + Styling
- [ ] Lightweight Factory-pattern DI container (`Container` /
      `ServiceLocator`-style, explicit registration, no reflection magic)
- [ ] `Styling.swift`: colors, type scale, spacing constants transcribed
      from the Claude Design prototype (palette, serif/grotesk pairing,
      hairline/shape tokens)
- [ ] Verify: `CoreTests` pass, `Core` package builds standalone

## T5 — Domain layer
- [ ] Entities: `Task`, `Project`, `Subtask`, `Priority`, `SyncStatus`
- [ ] Repository protocols: `TaskRepository`, `ProjectRepository`
- [ ] Use cases: `CreateTaskUseCase`, `UpdateTaskUseCase`,
      `DeleteTaskUseCase`, `ToggleTaskCompletionUseCase`,
      `CreateProjectUseCase`, `SearchTasksUseCase`, `SyncTasksUseCase`,
      `FetchStatsUseCase`
- [ ] Verify: `TaskManagementTests` — use cases tested against mocked
      repository protocols (happy path + invalid input, e.g. empty title)

## T6 — Data layer
- [ ] Core Data-backed `TaskRepository`/`ProjectRepository` implementations
- [ ] DummyJSON-backed remote source + DTO↔domain mapping (per plan.md §3
      — only title/completion round-trip; document the limitation inline)
- [ ] `SyncActor` implementing `SyncTasksUseCase`: pull, diff by
      `lastModified`, last-write-wins, conflict flag when both sides
      changed since last sync
- [ ] Verify: `TaskManagementTests` — sync engine tested for happy path,
      network failure, and simulated conflict (inject clock/timestamps)

## T7 — Presentation: Task List/Board + Detail + Add/Edit
- [ ] `TaskListViewModel` + `TaskListView` (List/Board segmented, matching
      prototype)
- [ ] `TaskDetailViewModel` + `TaskDetailView` (incl. sync-status
      indicator, conflict banner)
- [ ] `AddEditTaskViewModel` + `AddEditTaskView`
- [ ] Combine-based search: `@Published searchQuery` → debounce →
      `SearchTasksUseCase` (plan.md §4)
- [ ] Verify: ViewModel unit tests for state transitions

## T8 — Presentation: Projects, Stats, Settings
- [ ] `ProjectListViewModel` + `ProjectListView`
- [ ] `StatsViewModel` + `StatsView` (Swift Charts: completion ring +
      weekly bar chart)
- [ ] `SettingsView`: sync section, biometric lock toggle
      (`LocalAuthentication`), passcode fallback UI backed by Keychain,
      language display
- [ ] Verify: ViewModel unit tests; Keychain wrapper unit tests in `Core`

## T9 — Coordinators
- [ ] `AppCoordinator` + child coordinators (plan.md §5), wire all
      navigation through them instead of `NavigationLink` state
- [ ] Verify: manual smoke test of full navigation graph

## T10 — UI tests
- [ ] Primary flow UI test: create project → add task → mark complete →
      stats reflect it
- [ ] Accessibility audit UI test: `app.performAccessibilityAudit()` as
      its own failing test; fix every finding it surfaces (don't just
      report)
- [ ] Verify: both green locally

## T11 — Localization
- [ ] Convert all user-facing strings to `Localizable.xcstrings`
- [ ] Add `pt-BR` translations
- [ ] Verify: switch simulator language to Portuguese, spot-check every
      screen for layout breakage/truncation

## T12 — CI
- [ ] `.github/workflows/tests.yml`: build + unit test plan + UI test plan
      on every PR to `main`
- [ ] Verify: push a throwaway branch/PR, confirm the workflow runs green

## T13 — Documentation
- [ ] README.md (English): overview, architecture diagram/explanation,
      agentic workflow used (CLAUDE.md, Skills/subagents if used), test +
      accessibility results with real numbers, prototype screenshots, how
      to run
- [ ] Finalize `CLAUDE.md` with any conventions discovered during build
- [ ] Verify: README reviewed for parity with `superapp-agentic-workflow`
      depth
