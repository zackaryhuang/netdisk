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
    
    static let DidFinishUploadNotificationName = Notification.Name(rawValue: "com.ABCloud.notification.name.uploadTask.didFinishUpload")
    
    lazy var allUploadTask = fetchTasks()
    
    let multiUploadCount = 3
    
    static let documentsDirectory =  try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let uploadListsURL = ZigFileManager.documentsDirectory.appendingPathComponent("upload_tasks_\(ZigClientManager.shared.identifier).plist", conformingTo: .url)
    
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
    func upload(filePath: URL, driveID: String, parentFileID: String) -> ABUploadTask {
        let newTask = ABUploadTask(filePath: filePath, driveID: driveID, parentFileID: parentFileID)
        allUploadTask.append(newTask)
        newTask.start()
        storeTasks()
        return newTask
    }
    
    func removeTask(task: ABUploadTask) {
        if task.state != .succeeded {
            task.cancel()
        }
        allUploadTask.removeAll(where: { $0.identifier == task.identifier })
        storeTasks()
        NotificationCenter.default.post(name: Self.RunningCountChangeNotificationName, object: nil)
    }
    
    func cancelTask(task: ABUploadTask) {
        task.cancel()
        allUploadTask.removeAll(where: { $0.identifier == task.identifier })
        storeTasks()
    }
    
    func storeTasks() {
        if let data = try? PropertyListEncoder().encode(allUploadTask) {
            try? data.write(to: uploadListsURL)
        }
    }
    
    private func fetchTasks() -> [ABUploadTask] {
        if let data = try? Data(contentsOf: uploadListsURL) {
            let tasks = (try? PropertyListDecoder().decode([ABUploadTask].self, from: data)) ?? [ABUploadTask]()
            tasks.forEach { task in
                if task.state == .running {
                    task.state = .waiting
                }
            }
            return tasks
        }
        return [ABUploadTask]()
    }
    
}
