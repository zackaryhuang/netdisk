//
//  UploadManager.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/22.
//

import Foundation

class UploadManager: NSObject {
    static let shared = UploadManager()
    static let RunningCountChangeNotificationName = Notification.Name(rawValue: "com.ABCloud.notification.name.uploadTask.statusDidChange")
    
    lazy var allUploadTask = fetchTasks()
    
    let multiUploadCount = 3
    
    static let documentsDirectory =  try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let uploadListsURL = ZigFileManager.documentsDirectory.appendingPathComponent("listOfUpload.plist", conformingTo: .url)
    
    private var timer: DispatchSourceTimer?
    
    lazy var session = {
        var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        return session
    }()
    
    var uploadingCount: Int {
        get {
            var count = 0
            allUploadTask.forEach { task in
                if task.state == .running {
                    count += 1
                }
            }
            return count
        }
    }
    
    @discardableResult
    func upload(url: String, pathURL: URL, progress: ((Double) -> ())? = nil, completion: ((Error?) -> ())? = nil) -> UploadTask? {
        let newTask = UploadTask(url: url, pathURL: pathURL, progressHandler: progress, completionHandler: completion)
        if allUploadTask.contains(where: { $0 == newTask }) {
            completion?(NSError(code: -6, description: "文件已在上传队列"))
            return nil
        }
        allUploadTask.append(newTask)
        if (uploadingCount < multiUploadCount) {
            createTimer()
            newTask.startUpload()
        }
        storeTasks()
        completion?(nil)
        return newTask
    }
    
    func removeTask(task: UploadTask) {
        if task.state != .succeeded {
            task.uploadTask?.cancel()
        }
        allUploadTask.removeAll(where: { $0.identifier == task.identifier })
        storeTasks()
        NotificationCenter.default.post(name: Self.RunningCountChangeNotificationName, object: nil)
    }
    
    func suspendTask(task: UploadTask) {
        task.suspend()
    }
    
    func resumeTask(task: UploadTask) {
        task.resume()
    }
    
    func cancelTask(task: UploadTask) {
        task.cancel()
    }
    
    private func storeTasks() {
        if let data = try? PropertyListEncoder().encode(allUploadTask) {
            try? data.write(to: uploadListsURL)
        }
    }
    
    private func fetchTasks() -> [UploadTask] {
        if let data = try? Data(contentsOf: uploadListsURL) {
            let tasks = (try? PropertyListDecoder().decode([UploadTask].self, from: data)) ?? [UploadTask]()
            tasks.forEach { task in
                if task.state == .running {
                    task.state = .failed
                }
            }
            return tasks
        }
        return [UploadTask]()
    }
    
}

extension UploadManager: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let uploadUrl = task.originalRequest?.url?.absoluteString else { return }
        guard let task = allUploadTask.first(where: { $0.url == uploadUrl }) else { return }
        task.state = error == nil ? .succeeded : .failed
        if error == nil {
            task.progress = 1.0
            task.completionHandler?(nil)
            debugPrint("上传完成")
        } else {
            debugPrint("上传失败")
            task.completionHandler?(error)
        }
        if uploadingCount < multiUploadCount {
            if let task = allUploadTask.first(where: { $0.state == .waiting }) {
                task.startUpload()
            } else {
                invalidateTimer()
            }
        }
        storeTasks()
        NotificationCenter.default.post(name: Self.RunningCountChangeNotificationName, object: nil)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let uploadUrl = task.originalRequest?.url?.absoluteString else { return }
        guard let task = allUploadTask.first(where: { $0.url == uploadUrl }) else { return }
        task.state = .running
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        task.progress = progress
        debugPrint("上传进度 \(progress)")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        debugPrint("data: \(String(describing: NSString(data: data, encoding: NSUTF8StringEncoding)))")
    }
}

extension UploadManager {
    static let refreshInterval: Double = 1
    
    private func createTimer() {
        if timer == nil {
            timer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue(label: "com.ABCloud.UploadManager.TimerQueue",
                                                                                        autoreleaseFrequency: .workItem))
            timer?.schedule(deadline: .now(), repeating: Self.refreshInterval)
            timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.updateSpeed()
            })
            timer?.resume()
        }
    }
    
    private func invalidateTimer() {
        timer?.cancel()
        timer = nil
    }
    
    internal func updateSpeed() {
        allUploadTask.forEach { task in
            if (task.state == .running) {
                let currentCount = Double(task.fileSize) * task.progress
                task.speed = currentCount - task.lastFinishedCount
                task.lastFinishedCount = currentCount
            }
        }
    }
}
