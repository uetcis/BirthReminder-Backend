//
//  Logging.swift
//  BirthReminderBackendPackageDescription
//
//  Created by Captain雪ノ下八幡 on 2018/2/9.
//

import PerfectLogger
import PerfectHTTP
import PerfectLib
import Foundation

public func logInvalid(request: HTTPRequest, eventID: String, description: String? = nil) {
    LogFile.info("Invalid request at \(request.path), with description: \(description ?? "No")", eventid: eventID, logFile: logFilePath)
}

public func logInternalError(with request: HTTPRequest, eventID: String, description: String? = nil) {
    LogFile.error("Internal error at \(request.path), with description: \(description ?? "No")", eventid: eventID, logFile: logFilePath)
}

public func log(error: Error, description: String? = nil) {
    LogFile.error(error.localizedDescription, logFile: logFilePath)
}

public func log(errorDescription: String) {
    LogFile.error(errorDescription, logFile: logFilePath)
}

public func log(info: String) {
    LogFile.info(info, logFile: logFilePath)
}

fileprivate extension Array where Element == UInt8 {
    var string: String? {
        let data = Data(bytes: self)
        return String(data: data, encoding: .utf8)
    }
}
