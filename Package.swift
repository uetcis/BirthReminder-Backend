// swift-tools-version:4.0
// Generated automatically by Perfect Assistant 2
// Date: 2017-12-08 22:34:17 +0000
import PackageDescription

let package = Package(
	name: "BirthReminderBackend",
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-Notifications.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "BirthReminderBackend", dependencies: [])
	]
)
