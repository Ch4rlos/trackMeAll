// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMAFinanzas",
    platforms: [.iOS(.v18)],
    products: [.library(name: "TMAFinanzas", targets: ["TMAFinanzas"])],
    dependencies: [.package(path: "../TMACore")],
    targets: [
        .target(name: "TMAFinanzas", dependencies: ["TMACore"])
    ]
)
