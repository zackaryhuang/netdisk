//
//  UploadManager.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/22.
//

import Foundation

class UploadManager: NSObject {
    static let shared = UploadManager()
    
    var allUploadTask = [UploadTask]()
    
    let multiUploadCount = 3
    
    lazy var session = {
        var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        return session
    }()
    
    var uploadingCount: Int {
        get {
            var count = 0
            allUploadTask.forEach { task in
                if task.state == .uploading {
                    count += 1
                }
            }
            return count
        }
    }
    
    @discardableResult
    func upload(url: String, fileName: String) -> UploadTask? {
        let newTask = UploadTask(url: url, filePath: fileName)
        if allUploadTask.contains(where: { $0 == newTask }) {
            return nil
        }
        allUploadTask.append(newTask)
        if (uploadingCount < multiUploadCount) {
            newTask.startUpload()
        }
        return newTask
    }
    
}

extension UploadManager: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let uploadUrl = task.originalRequest?.url?.absoluteString else { return }
        guard let task = allUploadTask.first(where: { $0.url == uploadUrl }) else { return }
        task.state = error == nil ? .finished : .failed
        if error == nil {
            task.progressHandler?(1.0)
            debugPrint("上传完成")
        } else {
            debugPrint("上传失败")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let uploadUrl = task.originalRequest?.url?.absoluteString else { return }
        guard let task = allUploadTask.first(where: { $0.url == uploadUrl }) else { return }
        task.state = .uploading
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        if let handler = task.progressHandler {
            handler(progress)
        }
        debugPrint("上传进度 \(progress)")
    }
    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
//        <#code#>
//    }
//    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        debugPrint("data: \(NSString(data: data, encoding: NSUTF8StringEncoding))")
    }
}
