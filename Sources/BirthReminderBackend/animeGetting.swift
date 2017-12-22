//
//  animeGetting.swift
//  BirthReminder Backend
//
//  Created by Captain雪ノ下八幡 on 08/12/2017.
//

import Foundation
import PerfectMySQL
import PerfectHTTP

let personRoute = Route(method: .get, uri: "/api/birthdayReminder/Config/*") { request,response in
    let caoNiMa = "<html><head><title>Fuck you</title><meta charset=\"utf8\"></head><body><h1>总有刁民想害朕</h1></body></html>"
    if let animeId = Int(request.pathComponents[4]) {
        let result = getDetailedData(withAnimeID: animeId)
        do{
            response.setHeader(.contentType, value: "text/html; charset=utf-8")
            try response.setBody(json: result)
        }catch{
            response.setBody(string: "\(error)")
        }
    } else {
        response.setBody(string: caoNiMa)
    }
    response.completed()
}

let animeRoute = Route(method: .get, uri: "/api/birthdayReminder/animes/*") { request,response in
    let requirements: String?
    if request.pathComponents.count == 5 {
        requirements = request.pathComponents[4]
    } else { requirements = nil }
    let result = getAnimes(searchText: requirements)
    do{
        response.setHeader(.contentType, value: "text/html; charset=utf-8")
        try response.setBody(json: result)
    }catch{
        response.setBody(string: "\(error)")
    }
    response.completed()
}

func getDetailedData(withAnimeID id:Int) -> Array<[String:Any]> {
    let mysql = MySQL()
    guard mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8") else {
        return []
    }
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        return []
    }
    defer{
        mysql.close()
    }
    guard mysql.query(statement: "SELECT id,name,birth FROM Characters WHERE anime = \(id);") else {
        print(mysql.errorMessage())
        return []
    }
    var results = mysql.storeResults()!
    var finalResult = [[String:Any]]()
    results.forEachRow { result in
        let id = result[0]!
        let name = result[1]!
        let birth = result[2]!
        finalResult.append(["name":name,"birth":birth,"id": Int(id)!])
    }
    guard mysql.query(statement: "select startCharacter from Animes where id = \(id);") else {
        return []
    }
    results = mysql.storeResults()!
    results.forEachRow { result in
        let startChracter = Int(result[0]!)!
        for times in 0..<finalResult.count {
            let id = finalResult[times]["id"] as! Int
            let realId = id - startChracter + 1
            finalResult[times]["id"]! = realId
        }
    }
    return finalResult
}

func getAnimes(searchText: String?) -> [[String:Any]] {
    var finalResult = [[String:Any]]()
    let mysql = MySQL()
    guard mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8") else {
        return []
    }
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        return []
    }
    defer{
        mysql.close()
    }
    let statement: String
    if let searchingText = searchText, searchingText != "/" {
        statement = "SELECT id,name FROM Animes WHERE name like \'%\(searchingText)%\';"
    } else {
        statement = "SELECT id,name FROM Animes;"
    }
    guard mysql.query(statement: statement) else {
        return []
    }
    let results = mysql.storeResults()!
    results.forEachRow { result in
        let id = result[0]!
        let name = result[1]!
        finalResult.append(["id": Int(id)!,"name":name])
    }
    return finalResult
}
