// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMASalud",
    platforms: [.iOS(.v18)],
    products: [.library(name: "TMASalud", targets: ["TMASalud"])],
    dependencies: [.package(path: "../TMACore")],
    targets: [
        .target(name: "TMASalud", dependencies: ["TMACore"])
    ]
)
