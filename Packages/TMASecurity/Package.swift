// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMASecurity",
    // macOS se declara para poder correr los tests de la máquina de estados del
    // bloqueo en el host, sin simulador ni biometría real.
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [.library(name: "TMASecurity", targets: ["TMASecurity"])],
    dependencies: [.package(path: "../TMACore")],
    targets: [
        .target(name: "TMASecurity", dependencies: ["TMACore"]),
        .testTarget(name: "TMASecurityTests", dependencies: ["TMASecurity", "TMACore"])
    ]
)
