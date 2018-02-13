//
//  main.swift
//  BirthReminderBackendPackageDescription
//
//  Created by Captain雪ノ下八幡 on 16/12/2017.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectSlackAPIClient
import PerfectLogger

let server = HTTPServer()

// Private info Configuration
// MySQL Database
let host: String
let user: String
let password: String
let database: String

// Log file
let logFilePath: String

// SSL Cert
let port: UInt16
let documentRoot: String?
let caCertPath: String?
let sslCertPath: String?
let sslKeyPath: String?

/// Running host, e.g. https://www.tcwq.tech
let localhost: String

// APNS Pushing
let notificationsAppId: String
let apnsKeyIdentifier: String
let apnsTeamIdentifier: String
let apnsPrivateKey: String

do {
    let file = File("/.BirthReminder.json")
    try file.open()
    let config = try file.readString()
    let json = try config.jsonDecode() as! [String:String]
    host = json["host"]!
    user = json["user"]!
    password = json["password"]!
    database = json["database"]!
    SlackAPIClient.webhookURL = json["slack"]!
    logFilePath = json["logPath"] ?? "/BirthReminderBackend.log"
    port = UInt16(json["port"]!)!
    caCertPath = json["caCertPath"]
    sslCertPath = json["sslCertPath"]
    sslKeyPath = json["sslKeyPath"]
    documentRoot = json["documentRoot"]
    localhost = json["localhost"]!
    notificationsAppId = json["notificationsAppId"]!
    apnsKeyIdentifier = json["apnsKeyIdentifier"]!
    apnsTeamIdentifier = json["apnsTeamIdentifier"]!
    apnsPrivateKey = json["apnsPrivateKey"]!
    defer {
        file.close()
    }
} catch {
    Log.logger = ConsoleLogger()
    Log.terminal(message: "Cannot read configuration: \(error.localizedDescription)")
}

// HTTPS Configuration
server.serverPort = port
if let documentRoot = documentRoot {
    server.documentRoot = documentRoot
}
if let caCertPath = caCertPath,
    let sslCertPath = sslCertPath,
    let sslKeyPath = sslKeyPath {
    server.caCert = caCertPath
    server.ssl = (sslCert: sslCertPath, sslKey: sslKeyPath)
}

//API
var routes = Routes([
    animeRoute,
    animePicRoute,
    personRoute,
    personalPicRoute,
    animePurePicRoute,
    personalPurePicRoute,
    notificationCollectingRoute,
    contributionRoute,
    contributionSlack
    ])

server.addRoutes(routes)
do{
    try server.start()
}catch{
    LogFile.terminal(error.localizedDescription, eventid: UUID().string, logFile: logFilePath)
}

