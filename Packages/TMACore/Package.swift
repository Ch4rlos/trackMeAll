// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMACore",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "TMACore", targets: ["TMACore"])
    ],
    targets: [
        .target(name: "TMACore"),
        .testTarget(name: "TMACoreTests", dependencies: ["TMACore"])
    ]
)
