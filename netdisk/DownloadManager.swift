//
//  DownloadManager.swift
//  netdisk
//
//  Created by Zackary on 2023/9/5.
//

import Cocoa
import Alamofire

class DownloadManager: NSObject {
    var downloadingList = [DownloadItem]()
    var downloadedList = [DownloadItem]()
    var failedList = [DownloadItem]()
    var pendingList = [DownloadItem]()
    let downloadQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        return operationQueue
    }()
    public static let shared = DownloadManager()
    private override init() {}
    
    func download(with file: FileInfo) {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String,
           let fsid = file.fsID {
            AF.request("http://pan.baidu.com/rest/2.0/xpan/multimedia", method: .get, parameters: [
                "method" : "filemetas",
                "access_token" : accessToken,
                "fsids" : "[" + String(fsid) + "]",
                "dlink" : 1
            ], encoding: NOURLEncoding()).responseDecodable(of: FileDetailInfoResponse.self) { result in
                if let fileDetailResponse = result.value,
                    let fileDetail = fileDetailResponse.list?.first {
                    let downloadItem = DownloadItem(fileDetail: fileDetail)
                    self.pendingList.append(downloadItem)
                    let downloadOperation = DownloadOperation(downloadItem: downloadItem)
                    self.downloadQueue.addOperation(downloadOperation)
                } else {
                    debugPrint("fileDetail 请求失败")
                }
            }
        }
    }
}

extension Double {
    var binarySizeString: String {
        get {
            let KB = pow(Double(1024.0), 1)
            let MB = pow(Double(1024.0), 2)
            let GB = pow(Double(1024.0), 3)
            let TB = pow(Double(1024.0), 4)
            if self >= TB {
                return String(format: "%.2fTB", self / TB)
            }
            if self >= GB {
                return String(format: "%.2fGB", self / GB)
            }
            if self >= MB {
                return String(format: "%.2fMB", self / MB)
            }
            if self >= KB {
                return String(format: "%.2fKB", self / KB)
            }
            return String(format: "%.2fByte", self)
        }
    }
}
