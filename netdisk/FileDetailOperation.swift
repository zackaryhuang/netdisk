////
////  FileDetailOperation.swift
////  netdisk
////
////  Created by Zackary on 2023/9/7.
////
//
//import Cocoa
//import Alamofire
//
//class FileDetailOperation: Operation {
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
//    var fileInfo: FileInfo
//    
//    var fileDetailInfo: FileDetailInfo
//    
//    init(fileInfo: FileInfo, fileDetailInfo: inout FileDetailInfo) {
//        self.fileInfo = fileInfo
//        self.fileDetailInfo = fileDetailInfo
//    }
//    
//    
//    override func start() {
//        if zh_isCanceled {
//            zh_isExecuting = false
//            zh_isFinished = true
//            return
//        }
//        zh_isExecuting = true
//        requestFileDetail()
//    }
//    
//    func requestFileDetail() {
//        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String,
//           let fsid = fileInfo.fsID {
//            AF.request("http://pan.baidu.com/rest/2.0/xpan/multimedia", method: .get, parameters: [
//                "method" : "filemetas",
//                "access_token" : accessToken,
//                "fsids" : "[" + String(fsid) + "]",
//                "dlink" : 1
//            ], encoding: NOURLEncoding()).responseDecodable(of: FileDetailInfoResponse.self) { result in
//                if let fileDetailResponse = result.value,
//                    let fileDetail = fileDetailResponse.list?.first {
//                    self.fileDetailInfo = fileDetail
//                }
//                self.finishOperation()
//            }
//        } else {
//            self.finishOperation()
//        }
//    }
//    
//    func finishOperation() {
//        zh_isExecuting = false
//        zh_isFinished = true
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
//}
