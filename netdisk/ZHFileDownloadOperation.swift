//
//  ZHFileDownloadOperation.swift
//  netdisk
//
//  Created by Zackary on 2023/9/27.
//

import Cocoa

protocol ZHFileDownloadOperationDelegate: NSObjectProtocol {
    func fileDownloadOperationDidFinished(operation: ZHFileDownloadOperation, error: NSError?)
}

class ZHFileDownloadOperation: NSObject {
    weak var delegate: ZHFileDownloadOperationDelegate?
    var tasks = [ZHFileDownloadTask]()
    
    var URL: String!
    var uniqueKey: String!
    var sliceMode = false
    var sliceSize = 0
    var localCache: ZHFileDownloadCache!
    var isRunning = false
    var retryCount = 0
    
    func addTask(task: ZHFileDownloadTask) {
        if tasks.contains(task) {
            return
        }
        if tasks.count == 0 {
            URL = task.URL
            uniqueKey = task.getUniqueKey()
            sliceMode = task.sliceMode
            sliceSize = task.sliceSize
            localCache = ZHFileDownloadCache(URL: URL)
        }
        tasks.append(task)
    }
    
    func removeTask(task: ZHFileDownloadTask) {
        if !tasks.contains(task) {
            return
        }
        self.tasks.removeAll { inArrayTask in
            return inArrayTask == task
        }
    }
    
    func start() {
        if isRunning {
            return
        }
        
        isRunning = true
        retryCount += 1
        
    }
}
