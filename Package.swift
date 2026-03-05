// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SpeakSmart",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "SpeakSmart",
            targets: ["SpeakSmart"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "SpeakSmart",
            path: "SpeakSmart",
            exclude: ["Resources", "Info.plist"]
        )
    ]
)
