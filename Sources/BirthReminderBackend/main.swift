//
//  main.swift
//  BirthReminderBackendPackageDescription
//
//  Created by Captain雪ノ下八幡 on 16/12/2017.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMySQL
import Foundation
import PerfectNotifications

let sslServer = HTTPServer()
sslServer.documentRoot = "/webroot"

// HTTPS Configuration
sslServer.serverPort = 443 //Port defination
sslServer.caCert = "/certificates/www.tcwq.tech.ca-bundle"
sslServer.ssl = (sslCert: "/certificates/www.tcwq.tech.crt", sslKey: "/certificates/www.tcwq.tech.key")
// Database Configuration
let host: String
let user: String
let password: String
let database: String

do {
    let file = File("/.BirthReminder.json")
    try file.open()
    let config = try file.readString()
    let json = try config.jsonDecode() as! [String:String]
    host = json["host"]!
    user = json["user"]!
    password = json["password"]!
    database = json["database"]!
    defer {
        file.close()
    }
} catch {
    fatalError(error.localizedDescription)
}

//API
var routes = Routes()

routes.add([
    animeRoute,
    animePicRoute,
    personRoute,
    personalPicRoute,
    notificationCollectingRoute
    ])

sslServer.addRoutes(routes)
do{
    try sslServer.start()
}catch{
    print(error)
}

