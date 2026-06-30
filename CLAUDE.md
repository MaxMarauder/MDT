# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

MDT (Mobile Developer Test) is a SwiftUI iOS app and a reusable senior-iOS code-challenge template. It fetches a list of products from a Mockaroo-mocked backend, persists them with **SwiftData**, lists them with debounced search and pull-to-refresh, and opens a detail screen with a fullscreen zoomable image and an editable per-product note. It is deliberately built as a **showcase of modern Swift** (SwiftUI state/lifecycle, Combine, structured concurrency) — most types carry teaching comments explaining the technique.

Minimum deployment target is **iOS 17** (required by SwiftData and the Observation `@Observable` macro).

## Build & Test

Prefer the `xcode-tools` MCP commands over `xcodebuild` from the shell:
- **Build**: `BuildProject`
- **Live diagnostics** for a single file (fast, no full build): `XcodeRefreshCodeIssuesInFile`
- **Run app tests**: `RunAllTests`, or `GetTestList` + `RunSomeTests` for a subset.
- **Run package tests** (`ProductKit`): `cd ProductKit && swift test` (fast, host toolchain) — these are *not* in the app scheme's test plan.

The Xcode project is `MDT.xcodeproj` (scheme `MDT`). Test targets: `MDTTests` (unit) and `MDTUITests` (UI, XCUIAutomation). All tests use the **Swift Testing** framework (`import Testing`, `@Test`, `#expect`/`#require`) except the legacy XCTest-based `MDTUITests`.

When creating/deleting/moving **app-target** files, use the `xcode-tools` MCP file ops (`XcodeWrite`/`XcodeRM`/`XcodeMV`) — the project uses classic groups (not synchronized folders), so plain filesystem writes would not be added to the target. `ProductKit` is a Swift Package, so its files are managed with ordinary filesystem tools.

## Architecture

The codebase is split across a **local Swift package** (`ProductKit`, the domain + data layers) and the **app target** (presentation + composition). The dependency arrow points one way: **Presentation → Domain ← Data**. Four distinct "Product" representations exist and must not be conflated.

### `ProductKit` package — domain + data
Local SwiftPM package (`ProductKit/`). It is linked into the MDT target as a **local package reference**; if re-adding it, use Xcode *File ▸ Add Package Dependencies ▸ Add Local…*. Public API surface is intentionally tiny: `Product`, `ProductImage`, the `ProductsRepository` port, `DefaultProductsRepository`, and the networking protocols. Everything data-specific stays `internal`.

- **Domain** (`Sources/ProductKit/Domain/`) — framework-free value types and ports.
  - `Product` / `ProductImage`: immutable `struct`s, `Sendable`/`Hashable` (so they cross actors and serve as `NavigationStack` values). Holds derived rules like `isDiscounted`.
  - `ProductsRepository`: the `@MainActor` repository **port** — the single boundary the presentation layer depends on. Exposes a Combine `productsPublisher` plus async `load()`/`refresh()`/`updateNote(_:productID:)`.
- **Data** (`Sources/ProductKit/Data/`) — implements the ports.
  - `DTO/ProductDTO`: `internal` `Decodable` wire model; `CodingKeys` map snake_case (`original_price`). Never leaves the package.
  - `Network/`: async/await networking. `Service` (declarative request spec with Mockaroo `baseURL`/`X-API-Key` defaults) → `Resource: Service` (adds `Payload` + throwing `parse`, free when `Decodable`) → `HTTPClient`/`APIClient` (`func request(_:) async throws` over `URLSession.data(for:)`). Add an endpoint by declaring a `Resource` (see `ProductsEndpoint` → `cars` → `[ProductDTO]`).
  - `Persistence/`: `ProductModel` (`@Model`, `internal`, `@Attribute(.unique)` on `identifier`) and `SwiftDataProductsStore` (a `@ModelActor` actor behind the `ProductsLocalStore` port). The actor confines a non-`Sendable` `ModelContext` to its own executor — the race-free replacement for the old CoreData private-queue child context. `upsert` does match/insert/prune while preserving user notes.
  - `Mapping/`: DTO→Domain (`Product(dto:)`); Model↔Domain lives on `ProductModel`.
  - `DefaultProductsRepository` (`@MainActor`): composes `HTTPClient` + the store behind a `CurrentValueSubject<[Product], Never>`. Internal designated init (full DI for tests) + public `init(inMemory:)` that builds the `ModelContainer`.

### App target — presentation + composition
- **Composition root** (`MDTApp`): the one place that constructs concretes — `DefaultProductsRepository`, a `Router`, and a `RouteFactory` — and injects them. `Router` is shared via `.environmentObject`.
- **Navigation** (`Navigation/`) — the SRP-correct flow: a View emits an *intent* → the ViewModel decides → `Router` (an `ObservableObject` owning a `NavigationPath`) mutates the path → `NavigationStack(path:)` + `.navigationDestination(for: Route.self)` renders the destination, which `RouteFactory` builds. Views never construct destinations themselves.
- **Presentation models** (`Presentation/`): `ProductListItem` / `ProductDetailViewState` hold *formatted, render-ready* values built from a domain `Product`, so views contain no formatting/business logic.
- **ViewModels** — two observation styles, on purpose (each commented to contrast them):
  - `ProductListViewModel`: `@MainActor` + `ObservableObject` + **Combine**. A pipeline combines `$searchText` (`.debounce`/`.removeDuplicates`) with `repository.productsPublisher` via `combineLatest` → filtered `[ProductListItem]`. `didSelect` pushes a route via the `Router`.
  - `ProductDetailsViewModel`: `@MainActor` + `@Observable` (Observation framework, no `@Published`), `@ObservationIgnored` for collaborators; persists the note with a `Task` from the view's `.onChange`.
- **Views** showcase SwiftUI wrappers/lifecycle: `@StateObject`/`@EnvironmentObject` (list) vs `@State`/`@Bindable` (detail), and `.task`/`.refreshable`/`.searchable`/`.onChange`. Image loading/zoom use the remote packages below.

### Remote Swift package dependencies
`Zoomable` (pinch/pan zoom modifier) and `CachedAsyncImage` (caching `AsyncImage`) are **remote** SPM dependencies (`XCRemoteSwiftPackageReference`, GitHub) — not vendored in-repo. The Xcode navigator shows their checked-out sources, which is why folders may appear in the project tree that don't exist at the repo root.

## Conventions

- **Testing seam**: every layer is behind a protocol (`HTTPClient`, `ProductsLocalStore`, `ProductsRepository`) so tests inject mocks. Package tests (`ProductKitTests`) use `@testable import ProductKit` + an in-memory `ModelConfiguration(isStoredInMemoryOnly: true)` and a `MockHTTPClient`; app tests (`MDTTests`) mock the `ProductsRepository` port. When adding a layer, add its port and a mock.
- **Concurrency**: ViewModels and the repository are `@MainActor`; heavy work is delegated to the `@ModelActor` store and awaited. Domain models are `Sendable` so they cross actor boundaries; DTOs and `@Model`s never leave the package.
- **Async/await over closures** for all networking. Debug logging is wrapped in `#if DEBUG`.
- The Mockaroo `X-API-Key` is hardcoded in `Service`'s extension (`ProductKit/Data/Network/Service.swift`); the `cars` endpoint is the mock products source.
