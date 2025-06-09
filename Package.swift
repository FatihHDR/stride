// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "RandomWalkApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "RandomWalkApp",
            targets: ["RandomWalkApp"]
        )
    ],
    dependencies: [
        // Add any external dependencies here
        // For example, if you want to add networking or other utilities:
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "RandomWalkApp",
            dependencies: [],
            path: ".",
            sources: [
                "main.swift",
                "Models",
                "ViewModels", 
                "Views",
                "Services",
                "Utils"
            ]
        ),
        .testTarget(
            name: "RandomWalkAppTests",
            dependencies: ["RandomWalkApp"],
            path: "Tests"
        )
    ]
)
