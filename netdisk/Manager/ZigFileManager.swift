//
//  File.swift
//  netdisk
//
//  Created by Zackary on 2024/4/12.
//

import Foundation
import AppKit

struct ABDownloadRecordData: Codable {
    let identifier: String
    let fileID: String
    let driveID: String
    let fileName: String
}

struct ABUploadRecordData: Codable {
    let identifier: String
    let parentFileID: String
    let driveID: String
    let fielPath: URL
}

class ZigFileManager {
    static let documentsDirectory =  try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

    let downloadRecordsURL = ZigFileManager.documentsDirectory.appendingPathComponent("download_record_\(ZigClientManager.shared.identifier).plist", conformingTo: .url)
    
    let uploadRecordsURL = ZigFileManager.documentsDirectory.appendingPathComponent("upload_records_\(ZigClientManager.shared.identifier).plist", conformingTo: .url)

    var downloadRecords: [ABDownloadRecordData]? {
        get {
            if let data = try? Data(contentsOf: downloadRecordsURL) {
                return try? PropertyListDecoder().decode([ABDownloadRecordData].self, from: data)
            }
            return nil
        }
        set {
            if let data = try? PropertyListEncoder().encode(newValue) {
                try? data.write(to: downloadRecordsURL)
            }
        }
    }
    
    var uploadRecords: [ABUploadRecordData]? {
        get {
            if let data = try? Data(contentsOf: uploadRecordsURL) {
                return try? PropertyListDecoder().decode([ABUploadRecordData].self, from: data)
            }
            return nil
        }
        set {
            if let data = try? PropertyListEncoder().encode(newValue) {
                try? data.write(to: uploadRecordsURL)
            }
        }
    }
    
    static let shared = ZigFileManager()
    
    func rename(driveID: String, fileID: String, toName: String, completion: @escaping((Bool) -> ())) {
        Task {
            if let res = try? await WebRequest.rename(driveID: driveID, fileID: fileID, newName: toName) {
                completion(res)
            } else {
                completion(false)
            }
        }
    }
    
    func download(driveID: String, fileID: String, fileName: String, completion: @escaping((Error?) -> ())) {
        if !ZigBookmark.bookmarkStartAccessing(filePath: ZigDownloadManager.downloadPath) {
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.allowsMultipleSelection = false
            openPanel.begin { [weak self] result in
                if result == .OK,
                   let downloadPath = openPanel.urls.first {
                    if !(ZigBookmark.saveBookmark(filePath: downloadPath.absoluteString)) || !ZigBookmark.bookmarkStartAccessing(filePath: downloadPath.absoluteString) { return }
                    ZigDownloadManager.downloadPath = downloadPath.absoluteString
                    self?.startDownload(driveID: driveID, fileID: fileID, fileName: fileName, completion: completion)
                }
            }
        } else {
            startDownload(driveID: driveID, fileID: fileID, fileName: fileName, completion: completion)
        }
    }
    
    private func startDownload(driveID: String, fileID: String, fileName: String, completion: @escaping((Error?) -> ())) {
        Task {
            if let downloadInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID, driveID: driveID) {
                debugPrint(downloadInfo.downloadURL ?? "未知链接")
                let manager = ZigDownloadManager.shared.downloadSessionManager
                guard let task = manager.download(downloadInfo.downloadURL!, fileName: fileName) else {
                    completion(NSError(code: -2, description: "创建下载任务失败"))
                    return
                }
                task.progress { (task) in
                    debugPrint("progress:\(task.progress.fractionCompleted)")
                }.success { (task) in
                    debugPrint("下载完成")
                }.failure { (task) in
                    debugPrint("下载失败")
                }
                
                if let identifier = downloadInfo.downloadURL?.absoluteString.md5 {
                    insertDownloadRecord(ABDownloadRecordData(identifier: identifier, fileID: fileID, driveID: driveID, fileName: fileName))
                }
                completion(nil)
            } else {
                completion(NSError(code: -1, description: "获取下载链接失败"))
            }
        }
    }
    
    func retryDownload(downloadUrl: String, completion:@escaping((Error?) -> ())) {
        guard let downloadRecord = getDownloadRecord(identifier: downloadUrl.md5) else {
            completion(NSError(code: -3, description: "未知错误"))
            return
        }
        download(driveID: downloadRecord.driveID, fileID: downloadRecord.fileID, fileName: downloadRecord.fileName, completion: completion)
    }
    
    func retryUpload(uploadUrl: String, completion:@escaping((Error?) -> ())) {
        guard let uploadRecord = getUploadRecord(identifier: uploadUrl.md5) else {
            completion(NSError(code: -3, description: "未知错误"))
            return
        }
        uploadFile(driveID: uploadRecord.driveID, parentFileID: uploadRecord.parentFileID, filePath: uploadRecord.fielPath, completion: completion)
    }
    
    func delete(driveID: String, fileID: String) {
        
    }
    
    func trash(driveID: String, fileID: String, completion: @escaping((Bool) -> ())) {
        Task {
            if let res = try? await WebRequest.trash(driveID:driveID, fileID: fileID) {
                completion(res)
            } else {
                completion(false)
            }
        }
    }
    
    func move(driveID: String, fileID: String) {
        
    }
    
    func copy(driveID: String, fileID: String) {
        
    }
    
    func createFolder(driveID: String, parentFileID: String, folderName: String, completion: @escaping((Bool) -> ())) {
        Task {
            if let res = try? await WebRequest.createFolder(driveID:driveID, parentFileID:parentFileID, folderName:folderName) {
                completion(res)
            } else {
                completion(false)
            }
        }
    }
    
    func uploadFile(driveID: String, parentFileID: String, filePath: URL, completion: @escaping ((Error?) -> ())) {
        guard let att = try? FileManager.default.attributesOfItem(atPath: filePath.path()),
              let size = att[.size] as? Int else { return }
        
        if size > 5.D_GB {
            // 大于 5G 应该分片，暂未实现
            guard let contentView = NSApplication.shared.windows.first?.contentView else { return }
            let alert = ZigTextAlertView(title: "提示", message: "当前文件大小为 \(Double(size).decimalSizeString)，暂不支持上传大于 5G 的文件")
            alert.showInView(contentView)
            return
        }
        
        debugPrint("正在上传文件\(filePath.lastPathComponent), 文件大小\(Double(size).decimalSizeString)")
        
        Task {
            
            guard let createFileResp = try? await WebRequest.requestCreateFile(driveID: driveID, 
                                                                               parentFileID: parentFileID,
                                                                               name: filePath.lastPathComponent,
                                                                               preHash: nil),
                  let uploadUrl = createFileResp.partInfoList.first?.uploadUrl,
                  let uploadID = createFileResp.uploadID else {
                completion(NSError(code: -4, description: "创建文件失败"))
                return
            }
            
            if let task = UploadManager.shared.upload(url: uploadUrl, pathURL: filePath, completion: { err in
                guard let error = err else {
                    self.insertUploadRecord(ABUploadRecordData(identifier: uploadUrl.md5, parentFileID: parentFileID, driveID: driveID, fielPath: filePath))
                    completion(err)
                    return
                }
                debugPrint(error.localizedDescription)
                completion(error)
            }) {
                task.completionHandler = { error in
                    if error == nil {
                        Task {
                            if let _ = try? await WebRequest.uploadFileComplete(driveID: driveID, fileID: createFileResp.fileID, uploadID: uploadID) {
                                debugPrint("上传成功")
                                NotificationCenter.default.post(name: UploadManager.DidFinishUploadNotificationName, object: parentFileID)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 更新本地记录的 downloadUrl 对应的 fileID、driveID
    /// - Parameter record: 下载记录
    func updateDownloadRecord(_ record: ABDownloadRecordData) {
        var newRecords = downloadRecords ?? [ABDownloadRecordData]()
        newRecords.removeAll(where: { $0.identifier == record.identifier })
        newRecords.insert(record, at: 0)
        downloadRecords = newRecords
    }
    
    /// 插入本地记录的 downloadUrl 对应的 fileID、driveID
    /// - Parameter record: 下载记录
    func insertDownloadRecord(_ record: ABDownloadRecordData) {
        var newRecords = downloadRecords ?? [ABDownloadRecordData]()
        newRecords.insert(record, at: 0)
        downloadRecords = newRecords
    }
    
    /// 删除本地记录的 downloadUrl 对应的 fileID、driveID
    /// - Parameter identifier: 唯一标识符
    func deleteDownloadRecord(identifier: String) {
        var newRecords = downloadRecords ?? [ABDownloadRecordData]()
        newRecords.removeAll(where: { $0.identifier == identifier })
        downloadRecords = newRecords
    }
    
    /// 获取本地记录的 downloadUrl 对应的 fileID、driveID
    /// - Parameter record: 下载记录
    func getDownloadRecord(identifier: String) -> ABDownloadRecordData? {
        return downloadRecords?.first(where: { $0.identifier == identifier })
    }
    
    /// 更新本地记录的 uploadUrl 对应的 fileID、driveID
    /// - Parameter record: 下载记录
    func updateUploadRecord(_ record: ABUploadRecordData) {
        var newRecords = uploadRecords ?? [ABUploadRecordData]()
        newRecords.removeAll(where: { $0.identifier == record.identifier })
        newRecords.insert(record, at: 0)
        uploadRecords = newRecords
    }
    
    /// 插入本地记录的 uploadUrl 对应的 fileID、driveID
    /// - Parameter record: 下载记录
    func insertUploadRecord(_ record: ABUploadRecordData) {
        var newRecords = uploadRecords ?? [ABUploadRecordData]()
        newRecords.insert(record, at: 0)
        uploadRecords = newRecords
    }
    
    /// 删除本地记录的 uploadUrl 对应的 fileID、driveID
    /// - Parameter record: 下载记录
    func deleteUploadRecord(identifier: String) {
        var newRecords = uploadRecords ?? [ABUploadRecordData]()
        newRecords.removeAll(where: { $0.identifier == identifier })
        uploadRecords = newRecords
    }
    
    /// 获取本地记录的 uploadUrl 对应的 fileID、driveID
    /// - Parameter record: 下载记录
    func getUploadRecord(identifier: String) -> ABUploadRecordData? {
        return uploadRecords?.first(where: { $0.identifier == identifier })
    }
}
