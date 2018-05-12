//
//  animeGetting.swift
//  BirthReminder Backend
//
//  Created by Captain雪ノ下八幡 on 08/12/2017.
//

import Foundation
import PerfectMySQL
import PerfectHTTP
import PerfectLib

let personRoute = Route(method: .get, uri: "/api/BirthReminder/characters/*") { request,response in
    let eventID = UUID().string
    guard let animeId = Int(request.pathComponents[4]) else {
        response.completed(status: HTTPResponseStatus.badRequest)
        logInvalid(request: request, eventID: eventID, description: "Cannot get anime id")
        return
    }
    let result = getDetailedData(with: animeId)
    _ = try? response.setBody(json: result)
    response.setHeader(.contentEncoding, value: "utf8")
    response.completed()
}

let animeRoute = Route(method: .get, uri: "/api/BirthReminder/animes/*") { request,response in
    let eventID = UUID().string
    let requirements: String?
    if request.pathComponents.count == 5 {
        requirements = request.pathComponents[4]
    } else { requirements = nil }
    let result = getAnimes(searchText: requirements)
    _ = try? response.setBody(json: result)
    response.setHeader(.contentEncoding, value: "utf8")
    response.completed()
}

let animePicRoute = Route(method: .get, uri: "/api/BirthReminder/image/anime/*") { request, response in
    let eventID = UUID().string
    guard let stringID = request.pathComponents.last,
        let id = Int(stringID) else {
            response.completed(status: HTTPResponseStatus.badRequest)
            logInvalid(request: request, eventID: eventID, description: "Cannot get anime id")
            return
    }
    guard let result = getAnimePic(for: id) else {
        response.completed(status: HTTPResponseStatus.notFound)
        logInvalid(request: request, eventID: eventID, description: "Anime pic for id: \(id) not found")
        return
    }
    let json = ["pic":result.data,"copyright":result.copyright]
    _ = try? response.setBody(json: json)
    response.setHeader(.contentEncoding, value: "utf8")
    response.completed()
}

let personalPicRoute = Route(method: .get, uri: "/api/BirthReminder/image/character/*") { request, response in
    let eventID = UUID().string
    guard let stringID = request.pathComponents.last,
        let id = Int(stringID) else {
            response.completed(status: HTTPResponseStatus.badRequest)
            logInvalid(request: request, eventID: eventID, description: "Cannot get character id")
            return
    }
    guard let result = getPersonalPic(for: id) else {
        response.completed(status: HTTPResponseStatus.notFound)
        logInvalid(request: request, eventID: eventID, description: "Character pic for id: \(id) not found")
        return
    }
    let json = ["pic":result.data,"copyright":result.copyright]
    _ = try? response.setBody(json: json)
    response.setHeader(.contentEncoding, value: "utf8")
    response.completed()
}

let personalPurePicRoute = Route(method: .get, uri: "/api/BirthReminder/pureImage/character/*") { request, response in
    let eventID = UUID().string
    guard let stringID = request.pathComponents.last,
        let id = Int(stringID) else {
            response.completed(status: .badRequest)
            logInvalid(request: request, eventID: eventID, description: "Cannot get character id")
            return
    }
    guard let result = getPersonalPic(for: id) else {
        response.completed(status: .notFound)
        logInvalid(request: request, eventID: eventID, description: "Character pic for id: \(id) not found")
        return
    }
    response.setBody(bytes: result.data.binaryConverted ?? [])
    response.completed()
}

let animePurePicRoute = Route(method: .get, uri: "/api/BirthReminder/pureImage/anime/*") { request, response in
    let eventID = UUID().string
    guard let stringID = request.pathComponents.last,
        let id = Int(stringID) else {
            response.completed(status: .badRequest)
            logInvalid(request: request, eventID: eventID, description: "Cannot get anime id")
            return
    }
    guard let result = getAnimePic(for: id) else {
        response.completed(status: .notFound)
        logInvalid(request: request, eventID: eventID, description: "Anime pic for id: \(id) not found")
        return
    }
    guard let binary = result.data.binaryConverted else {
        response.completed(status: .internalServerError)
        logInternalError(with: request, eventID: eventID)
        return
    }
    response.setBody(bytes: binary)
    response.completed()
}

fileprivate func getDetailedData(with id:Int) -> [[String:Any]]? {
    let mysql = MySQL()
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        return nil
    }
    defer{
        mysql.close()
    }
    guard mysql.query(statement: "SELECT id,name,birth FROM Characters WHERE anime = \(id);") else {
        return nil
    }
    let results = mysql.storeResults()!
    var finalResult = [[String:Any]]()
    results.forEachRow { row in
        if let strID = row[0],
            let id = Int(strID),
            let name = row[1],
            let birth = row[2] {
            finalResult += [["name":name,"birth":birth,"id": id]]
        }
    }
    return finalResult
}

fileprivate func getAnimes(searchText: String?) -> [[String:Any]]? {
    var finalResult = [[String:Any]]()
    let mysql = MySQL()
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        return nil
    }
    defer{
        mysql.close()
    }
    let statement: String
    if let searchingText = searchText, searchingText != "/" {
        statement = "SELECT `id`,`name` FROM `Animes` WHERE `name` like \'%\(searchingText)%\'  && `isReleased` = TRUE;"
    } else {
        statement = "SELECT `id`,`name` FROM `Animes` WHERE `isReleased` = TRUE;"
    }
    guard mysql.query(statement: statement) else {
        return nil
    }
    guard let results = mysql.storeResults() else { return [] }
    results.forEachRow { row in
        if let strID = row[0],
            let id = Int(strID),
            let name = row[1] {
            finalResult += [["id": id,"name":name]]
        }
    }
    return finalResult
}

typealias Base64 = String
typealias PicPack = (data: Base64, copyright: String)

fileprivate func getAnimePic(for id: Int) -> PicPack? {
    let mysql = MySQL()
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        return nil
    }
    defer {
        mysql.close()
    }
    
    guard mysql.query(statement: "SELECT pic,picCopyright FROM Animes WHERE id = \(id);") else { return nil }
    guard let results = mysql.storeResults() else { return nil }
    guard let row = results.next() else { return nil }
    
    if let base64 = row[0],
        let copyright = row[1] {
        return (base64,copyright)
    } else {
        return nil
    }
}

fileprivate func getPersonalPic(for id: Int) -> PicPack? {
    let mysql = MySQL()
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        return nil
    }
    defer {
        mysql.close()
    }
    
    guard mysql.query(statement: "SELECT pic,picCopyright FROM Characters WHERE id = \(id);") else { return nil }
    guard let results = mysql.storeResults() else { return nil }
    guard let row = results.next() else { return nil }
    
    if let base64 = row[0],
        let copyright = row[1] {
        return (base64,copyright)
    } else {
        return nil
    }
}

extension Base64 {
    var binaryConverted: [UInt8]? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else { return nil }
        return [UInt8](data)
    }
}
