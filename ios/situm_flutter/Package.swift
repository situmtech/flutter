// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "situm_flutter",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "situm-flutter", targets: ["situm_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/situmtech/situm-sdk-spm", .upToNextMinor(from: "3.40.0"))
    ],
    targets: [
        .target(
            name: "situm_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "SitumSDK", package: "situm-sdk-spm")
            ],
            cSettings: [
                .headerSearchPath("include/situm_flutter")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreLocation")
            ]
        )
    ]
)
