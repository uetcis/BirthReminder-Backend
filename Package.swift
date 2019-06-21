// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "BirthReminderBackend",
    products: [
        .executable(name: "App", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-Notifications.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", from: "3.0.0"),
        .package(url: "https://github.com/CaptainYukinoshitaHachiman/PerfectSlackAPIClient.git", from: "1.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App",
                dependencies: [
                    "Perfect-Notifications",
                    "Perfect-Logger",
                    "Perfect-MySQL",
                    "PerfectSlackAPIClient",
                    "Perfect-RequestLogger"])
    ]
)
