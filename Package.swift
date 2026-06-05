// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PersonalTrainer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PersonalTrainer", targets: ["PersonalTrainerApp"])
    ],
    targets: [
        .executableTarget(
            name: "PersonalTrainerApp",
            path: "Sources/PersonalTrainerApp"
        )
    ]
)
