//
//  notificationTokenCollecting.swift
//  BirthReminder Backend
//
//  Created by Captain雪ノ下八幡 on 08/12/2017.
//

import PerfectHTTP
import PerfectMySQL
import PerfectLogger
import PerfectLib

let notificationCollectingRoute = Route(method: .post, uri: "/api/BirthReminder/notification") { request,response in
    let eventId = UUID().string
    guard let body = request.postBodyBytes,
        let string = String(bytes: body, encoding: .utf8),
        let json = try? string.jsonDecode() else {
            response.completed(status: HTTPResponseStatus.badRequest)
            logInvalid(request: request, eventID: eventId, description: "Cannot read request body")
            return
    }
    guard let token = (json as? [String:String])?["token"] else {
        response.completed(status: HTTPResponseStatus.badRequest)
        logInvalid(request: request, eventID: eventId, description: "Not containing a device token")
        return
    }
    let mysql = MySQL()
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        response.completed(status: HTTPResponseStatus.internalServerError)
        logInternalError(with: request, eventID: eventId, description: "Failed to connect to the database")
        return
    }
    let statement = """
    INSERT INTO `RemoteTokens` (`token`)
    SELECT t.* FROM(
    SELECT "\(token)"
    ) t
    WHERE NOT EXISTS (
    SELECT * FROM `RemoteTokens` RT WHERE RT.token = "\(token)"
    );
    """
    guard mysql.query(statement: statement) else {
        response.completed(status: HTTPResponseStatus.internalServerError)
        logInternalError(with: request, eventID: eventId, description: mysql.errorMessage())
        return
    }
    response.completed(status: HTTPResponseStatus.ok)
    defer{
        mysql.close()
    }
}
