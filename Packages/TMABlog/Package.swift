// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TMABlog",
    platforms: [.iOS(.v18)],
    products: [.library(name: "TMABlog", targets: ["TMABlog"])],
    dependencies: [.package(path: "../TMACore")],
    targets: [
        .target(name: "TMABlog", dependencies: ["TMACore"])
    ]
)
