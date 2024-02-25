//
//  ZHFileDownloader.swift
//  netdisk
//
//  Created by Zackary on 2023/9/26.
//

import Cocoa

class ZHFileDownloader: NSObject, ZHFileDownloadOperationDelegate {
    
    var operationMap = [String: ZHFileDownloadOperation]()
    
    public static let sharedDownloader = {
        let downloader = ZHFileDownloader()
        return downloader
    }()
    
    class func addTask(task: ZHFileDownloadTask) {
        sharedDownloader.addTask(task: task)
    }
    
    class func removeTask(task: ZHFileDownloadTask) {
        sharedDownloader.removeTask(task: task)
    }
    
    class func startTask(with URL: String) {
        sharedDownloader.startTask(with: URL)
    }
    
    private func addTask(task: ZHFileDownloadTask) {
        ZHDownloadThreads.actionQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let uniqueKey = task.getUniqueKey()
            var operation = strongSelf.operationMap[uniqueKey]
            if operation == nil {
                operation = ZHFileDownloadOperation()
                operation!.delegate = strongSelf
                strongSelf.operationMap[uniqueKey] = operation!
            }
            operation?.addTask(task: task)
        }
    }
    
    private func removeTask(task: ZHFileDownloadTask) {
        ZHDownloadThreads.actionQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let uniqueKey = task.getUniqueKey()
            if let operation = strongSelf.operationMap[uniqueKey] {
                operation.removeTask(task: task)
            }
        }
    }
    
    private func startTask(with URL: String) {
        ZHDownloadThreads.actionQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if let operation = strongSelf.operationMap[URL] {
                operation.start()
            }
        }
    }
    
    func fileDownloadOperationDidFinished(operation: ZHFileDownloadOperation, error: NSError?) {
        //
    }
}
