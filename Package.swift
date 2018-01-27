import PackageDescription
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

let repos: [String] 
	= ["Perfect-HTTPServer", "Perfect-Notifications", "Perfect-MySQL"]
let urls: [String]

if let cache = getenv("URL_PERFECT") {
	let local = String(cString: cache)
	urls = repos.map { "\(local)/\($0)" }
} else {
	urls = repos.map { "https://github.com/PerfectlySoft/\($0).git" }
}


let package = Package(
	name: "BirthReminderBackend", targets: [],
	dependencies: urls.map { .Package(url: $0, majorVersion: 3)} + [.Package(url: "https://github.com/SvenTiigi/PerfectSlackAPIClient.git", majorVersion: 1)]
)
