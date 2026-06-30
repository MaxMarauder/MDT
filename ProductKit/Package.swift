// swift-tools-version: 5.9
import PackageDescription

// MARK: - ProductKit
//
// `ProductKit` is the app's reusable domain + data module, as a local Swift Package.
//
// Why a local SwiftPM package:
//  - Hard module boundary: the app target can only see the package's `public` API,
//    so layering can't be violated by accident (a View literally cannot import a
//    SwiftData `@Model` that is `internal` to this package).
//  - Faster, isolated incremental builds and independent unit testing.
//  - An explicit dependency direction: the app depends on ProductKit, never the
//    reverse.
//
// The single `ProductKit` library is internally layered into `Domain/` and `Data/`
// folders (see Sources/ProductKit). Domain is framework-free; Data hosts the
// DTOs, async networking, and SwiftData persistence.
let package = Package(
    name: "ProductKit",
    // SwiftData + the Observation framework require iOS 17. The app target was
    // raised to 17.0 to match. macOS 14 is declared only so the package also
    // compiles for the host toolchain (`swift build`) as a fast standalone check.
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ProductKit", targets: ["ProductKit"]),
    ],
    targets: [
        .target(name: "ProductKit"),
        .testTarget(name: "ProductKitTests", dependencies: ["ProductKit"]),
    ]
)
