//
//  Slack.swift
//  BirthReminderBackend
//
//  Created by Captain雪ノ下八幡 on 2018/2/13.
//

import PerfectSlackAPIClient
import PerfectMySQL
import PerfectHTTP
import PerfectNotifications

let contributionSlack = Route(method: .post, uri: "/api/BirthReminder/contributionSlack") { request,response in
    guard let payload = request.param(name: "payload"),
        let jsonConvertible = try? payload.jsonDecode(),
        let json = jsonConvertible as? [String:Any],
        let actions = json["actions"] as? [[String:Any]],
        let firstActionName = actions.first?["name"] as? String,
        let user = json["user"] as? [String:Any],
        let username = user["name"] as? String,
        let callbackID = json["callback_id"] as? String,
        let animeID = Int(callbackID) else {
            response.completed(status: .badRequest)
            return
    }
    let message = SlackMessage()
    switch firstActionName {
    case "accept":
        releaseAnime(at: animeID)
        message.text = "Accepted by \(username), with id: \(animeID)"
    case "decline":
        declineAnime(at: animeID)
        message.text = "Declined by \(username), with id: \(animeID)"
    default:
        break
    }
    let responseBody = message.toJSON()
    let _ = try? response.setBody(json: responseBody)
    response.completed(status: .ok)
}



@discardableResult
public func sendContributionNotice(for id: Int) -> Bool {
    let mysql = MySQL()
    guard mysql.connect(host: host, user: user, password: password, db: database) else { return false }
    defer {
        mysql.close()
    }
    guard mysql.query(statement: "SELECT `name`,`picCopyright`,`contributionInfo` FROM `Animes` WHERE `id` = \(id);") else {
        return false
    }
    guard let _animes = mysql.storeResults() else { return false }
    var animes: [Anime] = []
    _animes.forEachRow { row in
        if let name = row[0],
            let picCopyright = row[1],
            let contributionInfo = row[2] {
            animes += [Anime(id: id, name: name, copyright: picCopyright, contributionInfo: contributionInfo)]
        }
    }
    guard let anime = animes.first else { return false }
    
    guard mysql.query(statement: "SELECT `id`,`name`,`birth`,`picCopyright` FROM `Characters` WHERE `anime` = \(id);") else {
        return false
    }
    guard let _characters = mysql.storeResults() else { return false }
    var characters: [Character] = []
    _characters.forEachRow { row in
        if let stringID = row[0],
            let id = Int(stringID),
            let name = row[1],
            let birth = row[2],
            let picCopyright = row[3] {
            characters += [Character(id: id, name: name, birth: birth, copyright: picCopyright)]
        }
    }
    sendSlackMessage(anime: anime, characters: characters)
    return true
}

fileprivate typealias Path = String

fileprivate struct Character {
    let id: Int
    let name: String
    /// Date formatted in MM-dd, e.g. 01-03
    let birth: String
    let copyright: String
    
    var imagePath: Path {
        return localhost + "/api/BirthReminder/pureImage/character/\(id)"
    }
}

fileprivate struct Anime {
    let id: Int
    let name: String
    let copyright: String
    let contributionInfo: String
    
    var imagePath: Path {
        return localhost + "/api/BirthReminder/pureImage/anime/\(id)"
    }
}

fileprivate func sendSlackMessage(anime: Anime, characters: [Character]) {
    let message = SlackMessage()
    message.text = "New contributio named: \(anime.name)".toMarkdown(format: .pre)
    
    let basicInfoAttachment = SlackAttachment()
    basicInfoAttachment.title = "Basics"
    
    let nameField = SlackAttachment.Field()
    nameField.title = "Name"
    nameField.value = anime.name
    nameField.short = true
    
    let rowField = SlackAttachment.Field()
    rowField.title = "Row"
    rowField.value = "\(anime.id)"
    rowField.short = true
    
    let contributorField = SlackAttachment.Field()
    contributorField.title = "Contributor"
    contributorField.value = anime.contributionInfo
    contributorField.short = false
    
    basicInfoAttachment.fields = [nameField,rowField,contributorField]
    
    let animeImageAttachment = SlackAttachment()
    animeImageAttachment.title = "Set Image"
    animeImageAttachment.thumbnailURL = anime.imagePath
    animeImageAttachment.text = "Copyright Info: \(anime.copyright)"
    
    let characterSeparatingAttachment = SlackAttachment()
    characterSeparatingAttachment.title = "Characters"
    
    
    let characterAttachments: [SlackAttachment] = characters.map { character in
        let characterAttachment = SlackAttachment()
        characterAttachment.title = character.name
        characterAttachment.text = "Birth: \(character.birth)\nCopyright Info: \(character.copyright)"
        characterAttachment.thumbnailURL = character.imagePath
        return characterAttachment
    }
    
    let actionAttachment = SlackAttachment()
    actionAttachment.title = "不要听风就是雨，你自己也要有个判断"
    actionAttachment.callbackId = "\(anime.id)"
    actionAttachment.color = SlackAttachment.Color.warning
    
    let agreeAction = SlackAttachment.Action(name: "accept", text: "Accept", type: .button)
    agreeAction.style = .primary
    
    let declineAction = SlackAttachment.Action(name: "decline", text: "Decline", type: .button)
    declineAction.style = .danger
    
    actionAttachment.actions = [agreeAction,declineAction]
    
    message.attachments = [basicInfoAttachment,animeImageAttachment,characterSeparatingAttachment] + characterAttachments + [actionAttachment]
    
    message.send()
}

@discardableResult
public func releaseAnime(at id: Int) -> Bool {
    let mysql = MySQL()
    guard mysql.connect(host: host, user: user, password: password, db: database) else { return false }
    guard mysql.query(statement: "UPDATE `Animes` SET `isReleased` = TRUE WHERE `id` = \(id);") else { return false }
    guard mysql.query(statement: "SELECT `token` FROM `Animes` WHERE `id` = \(id);"),
        let result = mysql.storeResults() else { return false }
    var tokens: [String] = []
    result.forEachRow { row in
        if let token = row[0] {
            tokens += [token]
        }
    }
    let notificationItems: [APNSNotificationItem] = [.alertTitle("Thank you."),.alertBody("Your contribution is now accepted")]
    notify(users: tokens, with: notificationItems)
    return true
}

@discardableResult
public func declineAnime(at id: Int) -> Bool {
    let mysql = MySQL()
    guard mysql.connect(host: host, user: user, password: password, db: database) else { return false }
    guard mysql.query(statement: "SELECT `token` FROM `Animes` WHERE `id` = \(id);"),
        let result = mysql.storeResults() else { return false }
    var tokens: [String] = []
    result.forEachRow { row in
        if let token = row[0] {
            tokens += [token]
        }
    }
    let notificationItems: [APNSNotificationItem] = [.alertTitle("Your contribution is declined"),.alertBody("Please check the contributing guide and submit again.\nFor more, contact us at CaptainYukinoshitaHachiman@tcwq.tech")]
    notify(users: tokens, with: notificationItems)
    return true
}
