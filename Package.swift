import PackageDescription

let package = Package(
    name: "BirthReminderBackend", targets: [],
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Notifications.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", majorVersion: 3),
        .Package(url: "https://github.com/SvenTiigi/PerfectSlackAPIClient.git", majorVersion: 1)
    ]
)
