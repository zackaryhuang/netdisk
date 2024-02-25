////
////  DownloadOperation.swift
////  netdisk
////
////  Created by Zackary on 2023/9/7.
////
//
//import Cocoa
//import Alamofire
//
//class DownloadOperation: Operation {
//    static let ProgressCallbackDuration = 0.5
//    
//    var progressBuffer = [Double]()
//    
//    var zh_isCanceled: Bool = false {
//        willSet {
//            willChangeValue(forKey: "isCanceled")
//        }
//        
//        didSet {
//            didChangeValue(forKey: "isCanceled")
//        }
//    }
//    
//    var zh_isFinished: Bool = false {
//        willSet {
//            willChangeValue(forKey: "isFinished")
//        }
//        
//        didSet {
//            didChangeValue(forKey: "isFinished")
//        }
//    }
//    
//    var zh_isExecuting: Bool = false {
//        willSet {
//            willChangeValue(forKey: "isExecuting")
//        }
//        
//        didSet {
//            didChangeValue(forKey: "isExecuting")
//        }
//    }
//    var downloadItem: DownloadItem
//    
//    var downloadPath: URL
//    
//    var downloadRequest: DownloadRequest?
//    
//    init(downloadItem: DownloadItem, downloadPath: URL) {
//        self.downloadItem = downloadItem
//        self.downloadPath = downloadPath
//    }
//    
//    override func start() {
//        if zh_isCanceled {
//            zh_isExecuting = false
//            zh_isFinished = true
//            return
//        }
//        
//        zh_isExecuting = true
//        startDownloadTask()
//    }
//    
//    func startDownloadTask() {
//        guard let downloadLink = downloadItem.fileDetail.downloadLink else {
//            debugPrint("DLink 获取失败")
//            downloadItem.state = .failed
//            downloadItem.delegate?.stateDidUpdate(item: downloadItem)
//            self.downloadItem.stateObserver?.downloadItemStateDidUpdate(downloadItem: self.downloadItem, fromState: .pending, toState: .failed)
//            zh_isExecuting = false
//            zh_isFinished = true
//            return
//        }
//        
//        let headers = ["User-Agent" : "pan.baidu.com"]
//        
//        if let data = downloadItem.resumeData,
//            let newData = data.resumeData(with: downloadLink) {
//            self.downloadRequest = AF.download(resumingWith: newData, to: { temporaryURL, response in
//                var url = self.downloadPath.appendingPathComponent(self.downloadItem.fileDetail.filename!)
//                if url.absoluteString.starts(with: "file://"),
//                   let string = url.absoluteString[7...].removingPercentEncoding,
//                   FileManager.default.fileExists(atPath: string) {
//                    let p_extension = url.pathExtension
//                    url.deletePathExtension()
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyyMMddHHmmss"
//                    url = URL(string: url.absoluteString + dateFormatter.string(from: Date.now) + "." + p_extension)!
//                }
//                self.downloadItem.destinationUrl = url.absoluteString
//                self.downloadItem.temporaryUrl = temporaryURL.absoluteString
//                return (url, .createIntermediateDirectories)
//            }).downloadProgress(closure: { progress in
//                if self.downloadItem.state != .downloading {
//                    self.downloadItem.state = .downloading
//                    self.downloadItem.delegate?.stateDidUpdate(item: self.downloadItem)
//                    self.downloadItem.stateObserver?.downloadItemStateDidUpdate(downloadItem: self.downloadItem, fromState: .pending, toState: .downloading)
//                }
//                let nowInterval = Date.now.timeIntervalSince1970
//                let lastInterval = self.downloadItem.lastTime == 0 ? (nowInterval + Self.ProgressCallbackDuration) : self.downloadItem.lastTime
//                if self.downloadItem.lastTime == 0 || nowInterval - lastInterval >= Self.ProgressCallbackDuration {
//                    let speed = Double(self.downloadItem.fileDetail.size ?? 0) * (progress.fractionCompleted - self.downloadItem.lastProgress) / (self.downloadItem.lastTime > 0 ? (nowInterval - lastInterval) : Self.ProgressCallbackDuration)
//                    self.progressBuffer.append(speed)
//                    if self.progressBuffer.count > 20 {
//                        self.progressBuffer.removeFirst()
//                    }
//                    let sum = self.progressBuffer.reduce(0) {$0 + $1}
//                    let average = sum / Double(self.progressBuffer.count)
//                    debugPrint("此次下载: \((Double(self.downloadItem.fileDetail.size ?? 0) * (progress.fractionCompleted - self.downloadItem.lastProgress)).binarySizeString), 用时: \(nowInterval - lastInterval)")
//                    debugPrint("速率: \(average.binarySizeString)")
//                    self.downloadItem.lastProgress = progress.fractionCompleted
//                    self.downloadItem.speed = average
//                    self.downloadItem.progress = progress.fractionCompleted
//                    self.downloadItem.lastTime = nowInterval
//                    self.downloadItem.delegate?.progressDidUpdate(item: self.downloadItem)
//                }
//            }).response(completionHandler: { response in
//                switch response.result {
//                case .success:
//                    debugPrint("下载完成")
//                    self.downloadItem.state = .downloaded
//                    self.downloadItem.progress = 1.0
//                case let .failure(err):
//                    if err.isExplicitlyCancelledError {
//                        debugPrint("取消下载")
//                        if self.downloadItem.state != .paused {
//                            self.downloadItem.state = .canceled
//                        }
//                    } else {
//                        debugPrint("下载失败\(err.localizedDescription)")
//                        self.downloadItem.state = .failed
//                    }
//                }
//                
//                self.downloadItem.speed = 0.0
//                
//                self.downloadItem.delegate?.stateDidUpdate(item: self.downloadItem)
//                self.downloadItem.delegate?.progressDidUpdate(item: self.downloadItem)
//                self.downloadItem.stateObserver?.downloadItemStateDidUpdate(downloadItem: self.downloadItem,
//                                                                            fromState: .downloading,
//                                                                            toState: self.downloadItem.state)
//                
//                self.zh_isExecuting = false
//                self.zh_isFinished = true
//            })
//        } else {
//            self.downloadRequest = AF.download(downloadLink,
//                        parameters: ["access_token" : UserDefaults.standard.object(forKey: "UserAccessToken") as! String],
//                        headers: HTTPHeaders(headers), to: { temporaryURL, response in
//                var url = self.downloadPath.appendingPathComponent(self.downloadItem.fileDetail.filename!)
//                if url.absoluteString.starts(with: "file://"),
//                   let string = url.absoluteString[7...].removingPercentEncoding,
//                   FileManager.default.fileExists(atPath: string) {
//                    let p_extension = url.pathExtension
//                    url.deletePathExtension()
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyyMMddHHmmss"
//                    url = URL(string: url.absoluteString + dateFormatter.string(from: Date.now) + "." + p_extension)!
//                }
//                self.downloadItem.destinationUrl = url.absoluteString
//                self.downloadItem.temporaryUrl = temporaryURL.absoluteString
//                return (url, .createIntermediateDirectories)
//            }).downloadProgress { progress in
//                if self.downloadItem.state != .downloading {
//                    self.downloadItem.state = .downloading
//                    self.downloadItem.delegate?.stateDidUpdate(item: self.downloadItem)
//                    self.downloadItem.stateObserver?.downloadItemStateDidUpdate(downloadItem: self.downloadItem, fromState: .pending, toState: .downloading)
//                }
//                let nowInterval = Date.now.timeIntervalSince1970
//                let lastInterval = self.downloadItem.lastTime == 0 ? (nowInterval + Self.ProgressCallbackDuration) : self.downloadItem.lastTime
//                if self.downloadItem.lastTime == 0 || nowInterval - lastInterval >= Self.ProgressCallbackDuration {
//                    let speed = Double(self.downloadItem.fileDetail.size ?? 0) * (progress.fractionCompleted - self.downloadItem.lastProgress) / (self.downloadItem.lastTime > 0 ? (nowInterval - lastInterval) : Self.ProgressCallbackDuration)
//                    self.progressBuffer.append(speed)
//                    if self.progressBuffer.count > 20 {
//                        self.progressBuffer.removeFirst()
//                    }
//                    let sum = self.progressBuffer.reduce(0) {$0 + $1}
//                    let average = sum / Double(self.progressBuffer.count)
//                    debugPrint("此次下载: \((Double(self.downloadItem.fileDetail.size ?? 0) * (progress.fractionCompleted - self.downloadItem.lastProgress)).binarySizeString), 用时: \(nowInterval - lastInterval)")
//                    debugPrint("速率: \(average.binarySizeString)")
//                    self.downloadItem.lastProgress = progress.fractionCompleted
//                    self.downloadItem.speed = average
//                    self.downloadItem.progress = progress.fractionCompleted
//                    self.downloadItem.lastTime = nowInterval
//                    self.downloadItem.delegate?.progressDidUpdate(item: self.downloadItem)
//                }
//            }.response { response in
//                switch response.result {
//                case .success:
//                    debugPrint("下载完成")
//                    self.downloadItem.state = .downloaded
//                    self.downloadItem.progress = 1.0
//                case let .failure(err):
//                    if err.isExplicitlyCancelledError {
//                        debugPrint("取消下载")
//                        if self.downloadItem.state != .paused {
//                            self.downloadItem.state = .canceled
//                            self.downloadItem.resumeData = response.resumeData
//                        }
//                    } else {
//                        debugPrint("下载失败\(err.localizedDescription)")
//                        self.downloadItem.state = .failed
//                    }
//                }
//                
//                self.downloadItem.speed = 0.0
//                
//                self.downloadItem.delegate?.stateDidUpdate(item: self.downloadItem)
//                self.downloadItem.delegate?.progressDidUpdate(item: self.downloadItem)
//                self.downloadItem.stateObserver?.downloadItemStateDidUpdate(downloadItem: self.downloadItem,
//                                                                            fromState: .downloading,
//                                                                            toState: self.downloadItem.state)
//                
//                self.zh_isExecuting = false
//                self.zh_isFinished = true
//            }
//        }
//    }
//    
//    override var isFinished: Bool {
//        return zh_isFinished
//    }
//    
//    override var isExecuting: Bool {
//        return zh_isExecuting
//    }
//    
//    override var isCancelled: Bool {
//        return zh_isCanceled
//    }
//    
//    override var isAsynchronous: Bool {
//        return true
//    }
//    
//    deinit {
//        debugPrint("DownloadOperation 释放")
//    }
//    
//    func pauseDownload() {
//        if let request = self.downloadRequest {
//            request.cancel(byProducingResumeData: { [weak self] data in
//                // Handle resume data
//                guard let strongSelf = self else { return }
//                strongSelf.downloadItem.resumeData = data
//                let fromState = strongSelf.downloadItem.state
//                strongSelf.downloadItem.state = .paused
//                strongSelf.downloadItem.stateObserver?.downloadItemStateDidUpdate(downloadItem: strongSelf.downloadItem,
//                                                                       fromState: fromState,
//                                                                       toState: .paused)
//            })
//        } else {
//            cancel()
//        }
//    }
//    
//    func cancelDownload() {
//        downloadRequest?.cancel()
//        let fromState = downloadItem.state
//        downloadItem.state = .canceled
//        downloadItem.stateObserver?.downloadItemStateDidUpdate(downloadItem: downloadItem, fromState: fromState, toState: .canceled)
//        
//    }
//}
