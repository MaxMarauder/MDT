# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

MDT (Mobile Developer Test) is a SwiftUI iOS app and a reusable senior-iOS code-challenge template. It fetches a list of products from a Mockaroo-mocked backend, persists them with CoreData, lists them with search and pull-to-refresh, and opens a detail screen with a fullscreen zoomable image and an editable per-product note.

## Build & Test

Prefer the `xcode-tools` MCP commands over `xcodebuild` from the shell:
- **Build**: `BuildProject`
- **Live diagnostics** for a single file (fast, no full build): `XcodeRefreshCodeIssuesInFile`
- **Run tests**: `RunAllTests`, or `RunSomeTests` / `GetTestList` for a single test or subset

The Xcode project is `MDT.xcodeproj` (scheme `MDT`). Test targets: `MDTTests` (unit, XCTest) and `MDTUITests` (UI, XCUIAutomation).

## Architecture

**MVVM + Coordinators over SwiftUI.** The pieces fit together top-down:

- `MDTApp` is the composition root. It builds the dependency graph once — `APIClient`, `CoreDataManager`, `ProductsRepository` → a `Repositories` struct — and hands it to the `AppCoordinator`, then renders `appCoordinator.rootView`.
- **Coordinators** own navigation and ViewModel creation. `CoordinatorType` exposes `rootView: AnyView` and `view(for: AppState) -> AnyView`. Navigation is state-driven: `AppState` enum cases (`.productList`, `.productDetails(product:)`) map to wrapped `AnyView`s. ViewModels hold a `weak var coordinator` and call `coordinator?.view(for:)` to push screens (see `ProductListView`'s `NavigationLink`). Child coordinators inherit `repositories` from their parent via the `ChildCoordinatorType` extension.
- **Repositories** (`Repositories` struct) are the single dependency surface passed through the coordinator chain. `ProductsRepository` mediates between `APIClient` (network) and `CoreDataManager` (persistence) — e.g. `requestProducts` fetches via the API then saves through CoreData.
- **ViewModels** are `ObservableObject`s created by coordinators and injected into views as `@StateObject`. They reach data only through `coordinator.repositories`. `ProductListViewModel` is an `NSObject` so it can be the `NSFetchedResultsControllerDelegate`; it calls `objectWillChange.send()` to drive SwiftUI updates rather than republishing the array.

**Networking** (`APICleint/` — note the misspelled directory). Endpoints are described declaratively, not imperatively:
- `Service` protocol = a request spec (method, baseURL, queryItems, body, headers, url), with protocol-extension defaults (GET, the Mockaroo `baseURL` + `X-API-Key`).
- `Resource: Service` adds an associated `Payload` and `parse`; when `Payload: Decodable`, parsing is free via the default `Data.parse()`.
- `APIClient.request(resource:)` runs the request and parses in one call. To add an endpoint, declare a `Resource` type (see `Products`, which hits the `cars` endpoint and returns `[APIPayload.Product]`) — no `APIClient` changes needed.

**Data model — two distinct "Product" types, do not conflate:**
- `APIPayload.Product` (`APIPayload.swift`) is the `Decodable` network DTO (uses snake_case JSON keys like `original_price`).
- `Product` is the CoreData `NSManagedObject` (defined in `MDT.xcdatamodeld`) and is the model passed through the app to views. `ProductExtension.swift` converts a DTO into/onto a `Product` via `init(with:context:)` / `set(data:context:)` and adds derived helpers (`isDiscounted`, `listID`).
- `ProductPreview` / `ProductImagePreview` subclass the CoreData entities with hardcoded getters for SwiftUI `#Preview`s without a live store.

**CoreData** (`CoreDataManager`). Uses a parent/child context pair: a main-queue `viewContext` for reads/UI and a private-queue `writeContext` (child of viewContext) for writes. `saveContext` saves the child then the parent. `save(products:)` performs an upsert+prune: match incoming DTOs to existing `Product`s by `identifier`, update matches, insert new ones, delete leftovers. The UI observes changes through `productsFetchedResultsController` (sorted by `name`).

**Local Swift packages** (SPM, vendored in-repo): `Zoomable` (pinch/pan zoom view modifier, used on the detail image) and `CachedAsyncImage` (caching `AsyncImage` replacement).

## Conventions

- **Testing seam**: every layer is behind a protocol (`APIClientType`, `CoreDataManagerType`, `ProductsRepositoryType`, `CoordinatorType`) so tests inject `Mock*` implementations (`MDTTests/Mock*.swift`). When adding a layer, add its protocol and a corresponding mock.
- Networking uses `Result` + completion closures, not async/await. Note: project style guidance prefers async/await for *new* APIs — follow the existing completion-handler style only when extending these existing types.
- Debug logging in `APIClient`/`Data.parse()` is wrapped in `#if DEBUG`.
- The Mockaroo `X-API-Key` is hardcoded in `APIService.swift`'s `Service` extension; the `cars` endpoint is the mock products source.
