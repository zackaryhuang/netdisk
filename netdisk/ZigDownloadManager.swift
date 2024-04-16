//
//  ZigDownloadManager.swift
//  netdisk
//
//  Created by Zackary on 2024/3/17.
//

import Foundation
import Tiercel

class ZigDownloadManager {
    static var downloadPath: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "ZigDownloadPath")
        }
        get {
            var homeDir = FileManager.default.homeDirectoryForCurrentUser.absoluteString
            homeDir.removeFirst(7)
            return UserDefaults.standard.string(forKey: "ZigDownloadPath") ?? (homeDir + "Downloads")
        }
    }
    static let shared = ZigDownloadManager()
    let downloadSessionManager = {
        var path = ZigDownloadManager.downloadPath
        if path.starts(with: "file") {
            path.removeFirst(7)
        }
        let s = SessionManager("download.aliyun", configuration: SessionConfiguration(), cache: Cache("download.aliyun", downloadTmpPath: path, downloadFilePath: path))
        return s
    }()
}
