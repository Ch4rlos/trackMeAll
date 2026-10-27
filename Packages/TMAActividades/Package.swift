// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMAActividades",
    platforms: [.iOS(.v18)],
    products: [.library(name: "TMAActividades", targets: ["TMAActividades"])],
    dependencies: [.package(path: "../TMACore")],
    targets: [
        .target(name: "TMAActividades", dependencies: ["TMACore"])
    ]
)
