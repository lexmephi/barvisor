// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Barvisor",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "Barvisor",
            path: "Sources/Barvisor"
        )
    ]
)
