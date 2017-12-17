import PackageDescription

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

var HTTPServer = "https://github.com/PerfectlySoft/Perfect-HTTPServer.git"
var Notifications = "https://github.com/PerfectlySoft/Perfect-Notifications.git"
var MySQL = "https://github.com/PerfectlySoft/Perfect-MySQL.git"

if let envHTTPServer = getenv("URL_PERFECT_HTTPSERVER") {
    HTTPServer = String(cString: envHTTPServer)
}
if let envNotifications = getenv("URL_PERFECT_NOTIFICATIONS") {
    Notifications = String(cString: envNotifications)
}
if let envMySQL = getenv("URL_PERFECT_MYSQL") {
    MySQL = String(cString: envMySQL)
}

let package = Package(
    name: "BirthReminderBackend", targets: [],
    dependencies: [
        .Package(url: HTTPServer, majorVersion: 3),
        .Package(url: Notifications, majorVersion: 3),
        .Package(url: MySQL, majorVersion: 3)
    ]
)
