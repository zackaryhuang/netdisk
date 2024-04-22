//
//  UploadTask.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/22.
//

import Cocoa
import AppKit

enum UploadState {
    case waiting
    case uploading
    case pending
    case finished
    case failed
    case canceled
}

class UploadTask: Equatable {
    let url: String
    let filePath: String
    let identifier: String
    var state: UploadState = .waiting
    var progressHandler: ((Double) -> ())?
    
    init(url: String, filePath: String) {
        self.url = url
        self.filePath = filePath
        self.identifier = url.md5
    }
    
    static func == (lhs: UploadTask, rhs: UploadTask) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func startUpload() {
        guard let requestURL = URL(string: url),
                let pathURL = URL(string: filePath),
              let accessToken = ZigClientManager.shared.accessToken,
              FileManager.default.fileExists(atPath: filePath) else {
            state = .failed
            return
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        let task = UploadManager.shared.session.uploadTask(with: request, fromFile: pathURL)
        task.resume()
    }
}
