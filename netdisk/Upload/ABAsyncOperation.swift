//
//  ABAsyncOperation.swift
//  ABCloud
//
//  Created by Zackary on 2024/5/27.
//

import Cocoa

class ABAsyncOperation: Operation {
    var ab_isCanceled: Bool = false {
        willSet {
            willChangeValue(for: \.isCancelled)
        }
        
        didSet {
            didChangeValue(for: \.isCancelled)
        }
    }
    
    var ab_isFinished: Bool = false {
        willSet {
            willChangeValue(for: \.isFinished)
        }
        
        didSet {
            didChangeValue(for: \.isFinished)
        }
    }
    
    var ab_isExecuting: Bool = false {
        willSet {
            willChangeValue(for: \.isExecuting)
        }
        
        didSet {
            didChangeValue(for: \.isExecuting)
        }
    }
    
    override var isExecuting: Bool {
        return ab_isExecuting
    }
    
    override var isFinished: Bool {
        return ab_isFinished
    }
    
    override var isCancelled: Bool {
        return ab_isCanceled
    }
    
    override func start() {
        if ab_isCanceled {
            ab_isExecuting = false
            ab_isFinished = true
            return
        }
        super.start()
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    deinit {
        debugPrint("deinit \(Self.Type.self)")
    }
    
    func finish() {
        ab_isExecuting = false
        ab_isFinished = true
    }
}
