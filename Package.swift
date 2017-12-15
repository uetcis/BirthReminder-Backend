import PackageDescription

let package = Package(
	name: "BirthReminderBackend", targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Notifications.git", majorVersion: 3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", majorVersion: 3)
	]
)
