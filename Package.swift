// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ALIVE",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ALIVE",
            targets: ["ALIVE"]
        ),
    ],
    targets: [
        .target(
            name: "ALIVE",
            path: "ALIVE",
            exclude: [
                "Extension",
                "WatchApp",
                "App/ALIVEApp.swift",
                "Assets.xcassets",
                "Tests"
            ],
            sources: [
                "Models",
                "Services",
                "ViewModels",
                "Theme",
                "Views"
            ]
        ),
        .testTarget(
            name: "ALIVETests",
            dependencies: ["ALIVE"],
            path: "ALIVE/Tests"
        )
    ]
)
