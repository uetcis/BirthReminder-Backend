//
//  notificationTokenCollecting.swift
//  BirthReminder Backend
//
//  Created by Captain雪ノ下八幡 on 08/12/2017.
//

import Foundation
import PerfectHTTP
import PerfectMySQL

let notificationCollectingRoute = Route(method: .post, uri: "/api/birthdayReminder/notification") { request,response in
    guard let json = try? request.postParams.first?.0.jsonDecode() else {
        response.completed(status: HTTPResponseStatus.badRequest)
        return
    }
    guard let token = (json as? [String:String])?["token"] else {
        return
    }
    guard !(token.contains(string: ")") || token.contains(string: ";")) else {
        response.completed(status: HTTPResponseStatus.badRequest)
        return
    }
    let mysql = MySQL()
    guard mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8") else {
        print("Failed to set the charset")
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
    }
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
    }
    defer {
        mysql.close()
    }
    guard mysql.query(statement: "SELECT token FROM RemoteTokens WHERE token = '\(token)';") else {
        print(mysql.errorMessage())
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
    }
    let results = mysql.storeResults()
    results?.forEachRow() { _ in
        response.completed(status: HTTPResponseStatus.ok)
        return
    }
    guard mysql.query(statement: "INSERT INTO RemoteTokens (token) values ('\(token)');") else {
        print(mysql.errorMessage())
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
    }
    response.completed(status: HTTPResponseStatus.ok)
    defer{
        mysql.close()
    }
}
