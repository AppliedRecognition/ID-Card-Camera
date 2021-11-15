// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "IDCardCamera",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "IDCardCamera",
            targets: ["IDCardCamera"]
        )
    ],
    dependencies: [
        .package(name: "AAMVABarcodeParser", url: "https://github.com/AppliedRecognition/AAMVA-Barcode-Parser-Apple.git", from: "1.4.1")
    ],
    targets: [
        .target(
            name: "IDCardCamera",
            exclude: ["BundleHelper.swift", "Resources/Info.plist", "Resources/Base.xcconfig"]
        ),
        .target(
            name: "TestApp",
            dependencies: [
                "IDCardCamera",
                "AAMVABarcodeParser"
            ],
            exclude: ["Resources/Info.plist"]
        )
    ]
)
