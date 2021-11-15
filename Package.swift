// switf-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "IDCardCamera",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "IDCardCamera",
            targets: ["IDCardCamera"]
        )
    ],
    targets: [
        .target(
            name: "IDCardCamera",
            resources: [
                .process("BarcodeDetectionViewController.xib"),
                .process("CardDetectionViewController.xib"),
                .process("Media.xcassets")
            ]
        )
    ]
)
