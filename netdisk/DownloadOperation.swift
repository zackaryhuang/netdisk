//
//  DownloadOperation.swift
//  netdisk
//
//  Created by Zackary on 2023/9/7.
//

import Cocoa
import Alamofire

class DownloadOperation: Operation {

    var zh_isCanceled: Bool = false {
        willSet {
            willChangeValue(forKey: "isCanceled")
        }
        
        didSet {
            didChangeValue(forKey: "isCanceled")
        }
    }
    
    var zh_isFinished: Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    var zh_isExecuting: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    var downloadItem: DownloadItem
    
    init(downloadItem: DownloadItem) {
        self.downloadItem = downloadItem
    }
    
    override func start() {
        if zh_isCanceled {
            zh_isExecuting = false
            zh_isFinished = true
            return
        }
        
        zh_isExecuting = true
        startDownloadTask()
    }
    
    func startDownloadTask() {
        guard let downloadLink = downloadItem.fileDetail.downloadLink else {
            debugPrint("DLink 获取失败")
            downloadItem.state = .failed
            downloadItem.delegate?.stateDidUpdate(item: downloadItem)
            zh_isExecuting = false
            zh_isFinished = true
            return
        }
        
        AF.download(downloadLink, parameters: ["access_token" : UserDefaults.standard.object(forKey: "UserAccessToken") as! String], headers: ["User-Agent" : "pan.baidu.com"] ,to: DownloadRequest.suggestedDownloadDestination(for: .downloadsDirectory)).downloadProgress { progress in
            if self.downloadItem.state != .downloaded {
                self.downloadItem.state = .downloading
                self.downloadItem.delegate?.stateDidUpdate(item: self.downloadItem)
            }
            let nowInterval = Date.now.timeIntervalSince1970
            let lastInterval = self.downloadItem.lastTime
            if self.downloadItem.lastTime == 0 || nowInterval - lastInterval >= 0.25 {
                let speed = Double(self.downloadItem.fileDetail.size ?? 0) * (progress.fractionCompleted - self.downloadItem.lastProgress) / (self.downloadItem.lastTime > 0 ? (Date.now.timeIntervalSince1970 - self.downloadItem.lastTime) : 1)
                self.downloadItem.lastProgress = progress.fractionCompleted
                self.downloadItem.speed = speed
                self.downloadItem.progress = progress.fractionCompleted
                self.downloadItem.lastTime = nowInterval
                self.downloadItem.delegate?.progressDidUpdate(item: self.downloadItem)
            }
            debugPrint("下载中 \((Double(self.downloadItem.fileDetail.size!) * progress.fractionCompleted).binarySizeString) / \(Double(self.downloadItem.fileDetail.size!).binarySizeString)")
        }.response { response in
            switch response.result {
            case .success:
                debugPrint("下载完成")
                self.downloadItem.state = .downloaded
                self.downloadItem.progress = 1.0
            case let .failure(err):
                debugPrint("下载失败\(err.localizedDescription)")
                self.downloadItem.state = .failed
            }
            
            self.downloadItem.speed = 0.0
            
            self.downloadItem.delegate?.stateDidUpdate(item: self.downloadItem)
            self.downloadItem.delegate?.progressDidUpdate(item: self.downloadItem)
            
            self.zh_isExecuting = false
            self.zh_isFinished = true
        }
    }
    
    override var isFinished: Bool {
        return zh_isFinished
    }
    
    override var isExecuting: Bool {
        return zh_isExecuting
    }
    
    override var isCancelled: Bool {
        return zh_isCanceled
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    deinit {
        debugPrint("DownloadOperation 释放")
    }
    
}
