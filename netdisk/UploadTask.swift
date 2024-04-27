//
//  UploadTask.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/22.
//

import Cocoa
import AppKit
import Foundation
import Tiercel

enum UploadState: Codable {
    case waiting
    case running
    case suspended
    case succeeded
    case failed
    case canceled
}

class UploadTask: Equatable, Codable {
    let url: String
    let pathURL: URL
    let identifier: String
    var state: UploadState = .waiting {
        didSet {
            if oldValue != state {
                NotificationCenter.default.post(name: UploadManager.RunningCountChangeNotificationName, object: nil)
            }
        }
    }
    var progressHandler: ((Double) -> ())?
    var completionHandler: ((Error?) -> ())?
    var uploadTask: URLSessionUploadTask?
    var progress: Double = 0.0 {
        didSet {
            self.progressHandler?(progress)
        }
    }
    var lastFinishedCount = 0.0
    var speed = 0.0
    
    var fileSize: Int {
        get {
            if let filePath = filePath,
               let attribute = try? FileManager.default.attributesOfItem(atPath: filePath),
               let length = attribute[.size] as? Int {
                return length
            }
            return 0
        }
    }
    
    var filePath: String? {
        get {
            pathURL.path().removingPercentEncoding
        }
    }
    
    var fileName: String? {
        get {
            (filePath as? NSString)?.lastPathComponent
        }
    }
    
    private enum CodingKeys: CodingKey {
            case url, pathURL, identifier, state, progress
        }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        pathURL = try container.decode(URL.self, forKey: .pathURL)
        identifier = try container.decode(String.self, forKey: .identifier)
        state = try container.decode(UploadState.self, forKey: .state)
        progress = try container.decode(Double.self, forKey: .progress)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(pathURL, forKey: .pathURL)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(state, forKey: .state)
        try container.encode(progress, forKey: .progress)
    }
    
    init(url: String, pathURL: URL, progressHandler: ((Double) -> ())?, completionHandler: ((Error?) -> ())?) {
        self.url = url
        self.pathURL = pathURL
        self.identifier = url.md5
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
    }
    
    static func == (lhs: UploadTask, rhs: UploadTask) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func startUpload() {
        guard let requestURL = URL(string: url),
              let filePath = pathURL.path().removingPercentEncoding,
              FileManager.default.fileExists(atPath: filePath) else {
            state = .failed
            return
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        let task = UploadManager.shared.session.uploadTask(with: request, from: (try? Data(contentsOf: pathURL, options: .mappedIfSafe))!)
        task.resume()
        uploadTask = task
        state = .running
        NotificationCenter.default.post(name: UploadManager.RunningCountChangeNotificationName, object: nil)
    }
    
    func suspend() {
        self.uploadTask?.suspend()
        self.state = .suspended
    }
    
    func resume() {
        self.uploadTask?.resume()
        self.state = .running
    }
    
    func cancel() {
        self.uploadTask?.cancel()
        self.state = .canceled
    }
}
