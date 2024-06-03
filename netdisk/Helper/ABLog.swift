//
//  ABLog.swift
//  ABCloud
//
//  Created by Zackary Huang on 2024/6/3.
//

import Foundation
import OSLog

enum Module: String {
    case upload = "upload"
}

class ABLog {
    static let Upload = Logger(subsystem: "com.abcloud.\(Module.upload.rawValue)", category: Module.upload.rawValue)
    static func log(module: Module, level: OSLogType, message: String) {
        var logger = Logger(subsystem: "com.abcloud.\(module.rawValue)", category: module.rawValue)
        logger.log(level: level, "\(message)")
    }
}
