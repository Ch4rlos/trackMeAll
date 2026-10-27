// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMABonanzas",
    platforms: [.iOS(.v18)],
    products: [.library(name: "TMABonanzas", targets: ["TMABonanzas"])],
    dependencies: [.package(path: "../TMACore")],
    targets: [
        .target(name: "TMABonanzas", dependencies: ["TMACore"])
    ]
)
