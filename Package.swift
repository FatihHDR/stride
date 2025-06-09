// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Stride",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "Stride",
            targets: ["Stride"]
        )
    ],
    dependencies: [
        // Add any external dependencies here
        // For example, if you want to add networking or other utilities:
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
    ],    targets: [
        .executableTarget(
            name: "Stride",
            dependencies: [],
            path: ".",
            sources: [
                "main.swift",
                "Models",
                "ViewModels", 
                "Views",
                "Services",
                "Utils"
            ]        ),
        .testTarget(
            name: "StrideTests",
            dependencies: ["Stride"],
            path: "Tests"
        )
    ]
)
