// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMACore",
    // macOS se declara solo para poder correr los tests del dominio en el host,
    // sin simulador. La app sigue siendo iOS.
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "TMACore", targets: ["TMACore"])
    ],
    targets: [
        .target(name: "TMACore"),
        .testTarget(name: "TMACoreTests", dependencies: ["TMACore"])
    ]
)
