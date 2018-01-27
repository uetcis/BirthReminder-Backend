//
//  Contributing.swift
//  BirthReminderBackend
//
//  Created by Captain雪ノ下八幡 on 21/01/2018.
//

import Foundation
import PerfectHTTP
import PerfectMySQL
import PerfectSlackAPIClient

let contributionRoute = Route(method: .post, uri: "/api/BirthReminder/contribution") { request,response in
    guard let body = request.postBodyBytes,
        let string = String(bytes: body, encoding: .utf8),
        let _json = try? string.jsonDecode() as? [String:Any],
        let json = _json else {
            response.completed(status: HTTPResponseStatus.badRequest)
            return
    }
    
    guard let anime = json["anime"] as? [String:Any],
        let characters = json["people"] as? [[String:Any]] else{
            response.completed(status: HTTPResponseStatus.badRequest)
            return
    }
    
    guard let animeId = insert(anime: anime),
        insert(characters: characters, anime: animeId) else {
            response.completed(status: HTTPResponseStatus.internalServerError)
            return
    }
    
    let message = SlackMessage()
    let contributorInfo = json["contributorInfo"] as? String
    message.text = "New contribution at row \(animeId) from \(contributorInfo ?? "Undefined")".toMarkdown(format: .italic)
    Thread.detachNewThread {
        message.send()
    }
    response.completed(status: HTTPResponseStatus.ok)
}

fileprivate func insert(anime: [String:Any]) -> Int? {
    let mysql = MySQL()
    guard mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8") else {
        return nil
    }
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        return nil
    }
    defer {
        mysql.close()
    }
    guard let name = anime["name"] as? String,
        let picPack = anime["picPack"] as? [String:Any],
        let pic = picPack["base64"] as? String,
        let picCopyright = picPack["copyright"] as? String else {
            return nil
    }
    let statement = """
    INSERT INTO `Animes` (`name`,`pic`,`picCopyright`) VALUES ('\(name)','\(pic)','\(picCopyright)');
    """
    guard mysql.query(statement: statement) else {
        return nil
    }
    guard mysql.query(statement: "SELECT last_insert_id();") else {
        print("\(statement)\n\(mysql.errorMessage())")
        return nil
    }
    guard let id = mysql.storeResults()?.next()?[0] else { return nil }
    return Int(id)
}

fileprivate func insert(characters charactersDictionary: [[String:Any]], anime: Int) -> Bool {
    let mysql = MySQL()
    guard mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8") else {
        return false
    }
    guard mysql.connect(host: host, user: user, password: password, db: database) else {
        return false
    }
    defer {
        mysql.close()
    }
    
    let characters:[(name: String, birth: String, pic: String, picCopyright: String)] = charactersDictionary.flatMap { character in
        guard let name = character["name"] as? String,
            let birth = character["birth"] as? String,
            let picPack = character["picPack"] as? [String:Any],
            let pic = picPack["base64"] as? String,
            let picCopyright = picPack["copyright"] as? String else { return nil }
        return (name,birth,pic,picCopyright)
    }
    guard !characters.isEmpty else { return false }
    var statement = characters.reduce("INSERT INTO `Characters` (`name`,`anime`,`birth`,`pic`,`picCopyright`) VALUES") { result,character in
        return result + """
        ('\(character.name)',\(anime),'\(character.birth)','\(character.pic)','\(character.picCopyright)'),
        """
    }
    statement.removeLast()
    statement += ";"
    guard mysql.query(statement: statement) else {
        return false
    }
    return true
}
