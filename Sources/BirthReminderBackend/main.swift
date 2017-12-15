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

//API
var routes = Routes()

routes.add([
    animeRoute,
    personRoute,
    notificationCollectingRoute
    ])

sslServer.addRoutes(routes)
do{
    try sslServer.start()
}catch{
    print(error)
}

