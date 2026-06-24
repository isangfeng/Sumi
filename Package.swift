// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Sumi",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Sumi", targets: ["Sumi"])
    ],
    targets: [
        .target(name: "SumiCore"),
        .executableTarget(
            name: "Sumi",
            dependencies: ["SumiCore"],
            resources: [.copy("Resources")]
        ),
        .testTarget(
            name: "SumiCoreTests",
            dependencies: ["SumiCore"]
        )
    ]
)
