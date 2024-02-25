////
////  DownloadManager.swift
////  netdisk
////
////  Created by Zackary on 2023/9/5.
////
//
//import Cocoa
//import Alamofire
//
//protocol DownloadManagerDelegate: NSObjectProtocol {
//    func downloadManager(fileDownloaded: DownloadItem);
//}
//
//class DownloadManager: NSObject, DownloadItemStateObserver {
//    var downloadingList = [DownloadItem]()
//    var downloadedList = [DownloadItem]()
//    var failedList = [DownloadItem]()
//    var pendingList = [DownloadItem]()
//    var pausedList = [DownloadItem]()
//    var lock = NSLock()
//    weak var delegate: DownloadManagerDelegate?
//    let downloadQueue = {
//        let operationQueue = OperationQueue()
//        operationQueue.maxConcurrentOperationCount = 3
//        return operationQueue
//    }()
//    public static let shared = DownloadManager()
//    private override init() {}
//    
//    func download(with file: FileInfo) {
//        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String,
//           let fsid = file.fsID {
//            AF.request("http://pan.baidu.com/rest/2.0/xpan/multimedia", method: .get, parameters: [
//                "method" : "filemetas",
//                "access_token" : accessToken,
//                "fsids" : "[" + String(fsid) + "]",
//                "dlink" : 1
//            ], encoding: NOURLEncoding()).responseDecodable(of: FileDetailInfoResponse.self) { result in
//                if let fileDetailResponse = result.value,
//                    let fileDetail = fileDetailResponse.list?.first {
//                    let downloadItem = DownloadItem(fileDetail: fileDetail)
//                    downloadItem.stateObserver = self
//                    self.pendingList.append(downloadItem)
//                    let downloadOperation = DownloadOperation(downloadItem: downloadItem)
//                    self.downloadQueue.addOperation(downloadOperation)
//                } else {
//                    debugPrint("fileDetail 请求失败")
//                }
//            }
//        }
//    }
//    
//    func downloadItemStateDidUpdate(downloadItem: DownloadItem, fromState: DownloadState, toState: DownloadState) {
//        self.lock.lock()
//        switch fromState {
//        case .pending:
//            self.pendingList.removeAll { obj in
//                obj.fileDetail.fsID == downloadItem.fileDetail.fsID
//            }
//        case .downloading:
//            self.downloadingList.removeAll { obj in
//                obj.fileDetail.fsID == downloadItem.fileDetail.fsID
//            }
//        case .downloaded:
//            self.downloadedList.removeAll { obj in
//                obj.fileDetail.fsID == downloadItem.fileDetail.fsID
//            }
//        case .failed:
//            self.failedList.removeAll { obj in
//                obj.fileDetail.fsID == downloadItem.fileDetail.fsID
//            }
//        case .paused:
//            self.pausedList.removeAll { obj in
//                obj.fileDetail.fsID == downloadItem.fileDetail.fsID
//            }
//        }
//        
//        switch toState {
//        case .pending:
//            self.pendingList.append(downloadItem)
//        case .downloading:
//            self.downloadingList.append(downloadItem)
//        case .downloaded:
//            self.downloadedList.append(downloadItem)
//            self.delegate?.downloadManager(fileDownloaded: downloadItem)
//        case .failed:
//            self.failedList.append(downloadItem)
//        case .paused:
//            self.pausedList.append(downloadItem)
//        }
//        
//        self.lock.unlock()
//    }
//}
//
