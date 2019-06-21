//
//  APNSNotifications.swift
//  BirthReminderBackend
//
//  Created by Captain雪ノ下八幡 on 2018/2/13.
//

import PerfectNotifications

public func notify(users tokens: [String], with items: [APNSNotificationItem]) {
    NotificationPusher.addConfigurationAPNS(
        name: notificationsAppId,
        production: true,
        keyId: apnsKeyIdentifier,
        teamId: apnsTeamIdentifier,
        privateKeyPath: apnsPrivateKey)
    let n = NotificationPusher(apnsTopic: notificationsAppId)
    n.pushAPNS(configurationName: notificationsAppId, deviceTokens: tokens, notificationItems: items) { responses in
        responses.forEach { response in
            log(info: "Sent notify with response: \((try? response.jsonObjectBody.jsonEncodedString()) ?? "No")")
        }
    }
}
