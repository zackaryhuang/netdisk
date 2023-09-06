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
    public static let shared = DownloadManager()
    private override init() {}
    
    func download(with file: FileInfo) {
        let downloadItem = DownloadItem(fileDetail: FileDetailInfo(fileInfo: file), progress: 0.0, state: .pending)
        pendingList.append(downloadItem)
        if let fsID = file.fsID {
            requestFileDetail(fsid: fsID) { fileDetail in
                for (idx, value) in self.pendingList.enumerated() {
                    if value.fileDetail.md5 == downloadItem.fileDetail.md5 {
                        self.pendingList.remove(at: idx)
                        break
                    }
                }
                if let detail = fileDetail {
                    downloadItem.state = .downloading
                    downloadItem.fileDetail = detail
                    self.downloadingList.append(downloadItem)
                    self.downloadFile(with: downloadItem)
                } else {
                    downloadItem.state = .failed
                    self.failedList.append(downloadItem)
                }
                downloadItem.delegate?.stateDidUpdate(item: downloadItem)
            }
        }
    }
    
    func requestFileDetail(fsid: UInt64, completion: @escaping(_ fileDetail: FileDetailInfo?) -> Void) {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String {
            AF.request("http://pan.baidu.com/rest/2.0/xpan/multimedia", method: .get, parameters: [
                "method" : "filemetas",
                "access_token" : accessToken,
                "fsids" : "[" + String(fsid) + "]",
                "dlink" : 1
            ], encoding: NOURLEncoding()).responseDecodable(of: FileDetailInfoResponse.self) { result in
                if let fileDetailResponse = result.value,
                    let fileDetail = fileDetailResponse.list?.first {
                    completion(fileDetail)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
        
    }
    
    func downloadFile(with downloadItem: DownloadItem) {
        if let downloadLink = downloadItem.fileDetail.dlink {
            AF.download(downloadLink, parameters: ["access_token" : UserDefaults.standard.object(forKey: "UserAccessToken") as! String], headers: ["User-Agent" : "pan.baidu.com"] ,to: DownloadRequest.suggestedDownloadDestination(for: .downloadsDirectory)).downloadProgress { progress in
                downloadItem.state = .downloading
                let nowInterval = Date.now.timeIntervalSince1970
                let lastInterval = downloadItem.lastTime
                if downloadItem.lastTime == 0 || nowInterval - lastInterval >= 0.25 {
                    let speed = Double(downloadItem.fileDetail.size ?? 0) * (progress.fractionCompleted - downloadItem.lastProgress) / (downloadItem.lastTime > 0 ? (Date.now.timeIntervalSince1970 - downloadItem.lastTime) : 1)
                    downloadItem.lastProgress = progress.fractionCompleted
                    downloadItem.speed = speed
                    downloadItem.progress = progress.fractionCompleted
                    downloadItem.delegate?.progressDidUpdate(item: downloadItem)
                    downloadItem.lastTime = nowInterval
                }
                debugPrint("下载中 \((Double(downloadItem.fileDetail.size!) * progress.fractionCompleted).binarySizeString) / \(Double(downloadItem.fileDetail.size!).binarySizeString)")
            }.response { response in
                for (idx, value) in self.downloadingList.enumerated() {
                    if value.fileDetail.dlink == downloadLink && value.fileDetail.filename == downloadItem.fileDetail.filename {
                        self.downloadingList.remove(at: idx)
                        break
                    }
                }
                switch response.result {
                case .success:
                    debugPrint("下载完成")
                    downloadItem.state = .downloaded
                    downloadItem.progress = 1.0
                    self.downloadedList.append(downloadItem)
                case .failure:
                    debugPrint("下载失败")
                    
                    downloadItem.state = .failed
                    self.failedList.append(downloadItem)
                }
                
                downloadItem.speed = 0.0
                downloadItem.delegate?.progressDidUpdate(item: downloadItem)
                downloadItem.delegate?.stateDidUpdate(item: downloadItem)
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
