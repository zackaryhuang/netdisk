//
//  ZHDownloadThreads.swift
//  netdisk
//
//  Created by Zackary on 2023/9/27.
//

import Cocoa

class ZHDownloadThreads: NSObject {

    public static let actionQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "com.thatisawesome.actionQueue"
        return queue
    }()
    
    public static let networkQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        queue.name = "com.thatisawesome.networkQueue"
        return queue
    }()
    
    public static let outputkQueue = {
        let queue = OperationQueue()
        queue.name = "com.thatisawesome.outputkQueue"
        return queue
    }()
}
