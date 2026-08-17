# TaskFlow — Spec

## 1. Overview

TaskFlow is an offline-first task and project management app for
individuals and small teams, built as a standalone portfolio piece
demonstrating senior-level iOS engineering practices (Clean Architecture +
MVVM-C, modularized Swift Packages, Swift Concurrency + Combine, Core Data,
testable networking, CI, accessibility auditing, localization).

This is app 1 of a 4-app portfolio series. Unlike the prior
`superapp-agentic-workflow` project (a demonstration/redesign lab),
TaskFlow is a complete, real-use product from a blank slate.

## 2. Scope (in)

- Task CRUD: title, description, due date, priority (low/medium/high),
  tags, project association, subtasks/checklist
- Project CRUD: name, color/label, task count, completion progress
- Offline-first local persistence via Core Data; app is fully usable with
  no network
- Background sync against a public REST API (candidate: DummyJSON's
  `/todos` endpoints, or a similar JSONPlaceholder-style API that supports
  GET/POST/PUT/DELETE on a todo-like resource) — see Open Question #1
- Search and filter across tasks (by project, priority, tag, due date,
  completion state) and projects
- Stats view: completion rate, overdue count, simple weekly completed
  chart (Swift Charts) — intentionally lighter scope than FocusPath (app 2)
- Biometric app lock: Face ID via `LocalAuthentication`, passcode fallback
  stored in Keychain
- English default + one additional localized language (candidate:
  Portuguese, since it doubles as a real QA case for the author) via
  String Catalogs
- Unit tests (ViewModels, use cases — happy path + network failure + sync
  conflict + invalid input), UI tests for the primary flow, an
  accessibility audit UI test using
  `XCUIApplication().performAccessibilityAudit()` that fails the build on
  findings
- GitHub Actions: run unit + UI tests on every PR

## 3. Scope (out)

- Team/multi-user collaboration, real-time presence, or shared editing
- Push notifications
- Fastlane / App Store deployment automation
- A full custom design-system package (see Open Question #2)

## 4. Architecture

- **Clean Architecture + MVVM-C**
  - Domain: entities (`Task`, `Project`, `Tag`), use cases
    (`CreateTaskUseCase`, `SyncTasksUseCase`, etc.), repository protocols
  - Data: repository implementations (Core Data local source + REST
    remote source), sync engine reconciling local/remote state
  - Presentation: SwiftUI views + ViewModels (`@Observable` or
    `ObservableObject`, per Swift version decided in plan)
  - Coordinator: UIKit-based navigation coordinators wrapping SwiftUI views
    via `UIHostingController`
- **Modularization (local Swift Packages, single repo)**
  - `Core` — networking client, persistence contracts, DI container,
    shared utilities/extensions
  - `TaskManagement` — the core feature module (domain + data +
    presentation for tasks/projects)
  - Shared UI: see Open Question #2 — full `DesignKit` package vs. a
    lighter shared style file
- **Dependency Injection**: lightweight Factory-pattern container, no
  third-party DI framework
- **Concurrency**: async/await + actors for the primary sync/data-flow
  pipeline; Combine used deliberately in at least one place — search-bar
  debouncing is the natural fit (`@Published` query → `.debounce` →
  triggers use case)
- **Persistence**: Core Data
- **Networking**: protocol-based, mockable client (`URLSession` wrapped
  behind a testable protocol)

## 5. Testing & quality

- ViewModel/use-case unit tests: happy path, network failure, sync
  conflict (local edit vs. remote edit on same task), invalid input
  validation
- UI test: end-to-end primary flow (create project → add task → mark
  complete → verify stats update)
- Accessibility audit as a real, failing UI test
- Localization: String Catalog, en (default) + pt (candidate)

## 6. CI/CD

GitHub Actions workflow: build + run unit tests + run UI tests on every
pull request against `main`.

## 7. Open questions (need your decision before/while planning)

1. **Sync API choice**: DummyJSON `/todos` (supports full CRUD, no auth
   needed, closest to a real REST contract) vs. building a minimal local
   mock server (e.g., a small Vapor or `json-server`-style mock) if you
   want to control response shape/latency/errors more precisely for
   demonstrating conflict handling. Recommendation: DummyJSON first — it's
   simpler and still real over-the-wire, and error/conflict simulation can
   be injected client-side in the sync engine. Flag if you disagree.
2. **DesignKit package vs. lighter shared style file**: for a single-app
   project, a full `DesignKit` package (tokens, reusable components,
   previews) is more setup than payoff — it makes sense as its own package
   once ≥2 apps in the series actually share it. Recommendation: a single
   `Styling.swift`-style file inside `Core` (colors, type scale, spacing
   constants derived from the Claude Design prototype) for TaskFlow now;
   revisit extracting a real `DesignKit` package if app 2 (FocusPath) ends
   up needing the same tokens. Flag if you'd rather build the package now.
3. **Second localized language**: proposing Portuguese (real QA value for
   you) — confirm or override.

## 8. Deliverables

- Single GitHub repo, single Xcode project with local SPM packages
- README (English) matching the depth of `superapp-agentic-workflow`:
  overview, architecture, agentic workflow used (CLAUDE.md, Skills,
  subagents if used), test/accessibility results with real numbers,
  screenshots referencing the Claude Design prototype, how to run
- CLAUDE.md for persistent project context in Claude Code
- (Later, on request) private interview-prep study guide, outside the repo
