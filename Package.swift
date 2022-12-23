// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagiSwiftUIComponents",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(name: "RagiSwiftUIComponents", targets: ["RagiSwiftUIComponents"]),
    ],
    targets: [
        .target(name: "RagiSwiftUIComponents", path: "RagiSwiftUIComponents"),
    ],
    swiftLanguageVersions: [.v5]
)
