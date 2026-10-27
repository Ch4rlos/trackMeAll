// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMASecurity",
    platforms: [.iOS(.v18)],
    products: [.library(name: "TMASecurity", targets: ["TMASecurity"])],
    dependencies: [.package(path: "../TMACore")],
    targets: [
        .target(name: "TMASecurity", dependencies: ["TMACore"])
    ]
)
