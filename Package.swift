// swift-tools-version: 6.0
//
// Manifiesto raíz: publica los 7 módulos como paquetes consumibles por URL.
//
// SwiftPM solo lee el `Package.swift` de la raíz de un repositorio remoto, así que sin
// este archivo otro proyecto no puede hacer `.package(url: "…/trackMeAll.git")` y usar
// `TMACore`. Los manifiestos de `Packages/*/Package.swift` siguen existiendo para correr
// `swift test --package-path` de forma aislada; este solo declara los productos.
//
// Uso desde otro repo:
//   .package(url: "https://github.com/Ch4rlos/trackMeAll.git", from: "0.1.0")
//   .product(name: "TMACore", package: "trackMeAll")

import PackageDescription

let package = Package(
    name: "trackMeAll",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "TMACore", targets: ["TMACore"]),
        .library(name: "TMASalud", targets: ["TMASalud"]),
        .library(name: "TMAFinanzas", targets: ["TMAFinanzas"]),
        .library(name: "TMAActividades", targets: ["TMAActividades"]),
        .library(name: "TMABlog", targets: ["TMABlog"]),
        .library(name: "TMASecurity", targets: ["TMASecurity"]),
        .library(name: "TMABonanzas", targets: ["TMABonanzas"])
    ],
    targets: [
        .target(
            name: "TMACore",
            path: "Packages/TMACore/Sources/TMACore"
        ),
        .target(
            name: "TMASalud",
            dependencies: ["TMACore"],
            path: "Packages/TMASalud/Sources/TMASalud"
        ),
        .target(
            name: "TMAFinanzas",
            dependencies: ["TMACore"],
            path: "Packages/TMAFinanzas/Sources/TMAFinanzas"
        ),
        .target(
            name: "TMAActividades",
            dependencies: ["TMACore"],
            path: "Packages/TMAActividades/Sources/TMAActividades"
        ),
        .target(
            name: "TMABlog",
            dependencies: ["TMACore"],
            path: "Packages/TMABlog/Sources/TMABlog"
        ),
        .target(
            name: "TMASecurity",
            dependencies: ["TMACore"],
            path: "Packages/TMASecurity/Sources/TMASecurity"
        ),
        .target(
            name: "TMABonanzas",
            dependencies: ["TMACore"],
            path: "Packages/TMABonanzas/Sources/TMABonanzas"
        )
    ]
)
