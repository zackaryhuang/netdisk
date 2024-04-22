//
//  File.swift
//  netdisk
//
//  Created by Zackary on 2024/4/12.
//

import Foundation
import AppKit

class ZigFileManager {
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
    
    func download(driveID: String, fileID: String, fileName: String) {
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
                    self?.startDownload(driveID: driveID, fileID: fileID, fileName: fileName)
                }
            }
        } else {
            startDownload(driveID: driveID, fileID: fileID, fileName: fileName)
        }
    }
    
    private func startDownload(driveID: String, fileID: String, fileName: String) {
        Task {
            if let downloadInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID, driveID: driveID) {
                debugPrint(downloadInfo.downloadURL ?? "未知链接")
                let manager = ZigDownloadManager.shared.downloadSessionManager
                let task = manager.download(downloadInfo.downloadURL!, fileName: fileName)
                task?.progress { (task) in
                    debugPrint("progress:\(task.progress.fractionCompleted)")
                }.success { (task) in
                    debugPrint("下载完成")
                }.failure { (task) in
                    debugPrint("下载失败")
                }
            }
        }
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
    
    func uploadFile(driveID: String, parentFileID: String, filePath: URL) {
        guard let data = try? Data(contentsOf: filePath) else { return }
        
        debugPrint("正在上传文件\(filePath.lastPathComponent), 文件大小\(Double(data.count).binarySizeString)")
        
        Task {
            
            guard let createFileResp = try? await WebRequest.requestCreateFile(driveID: driveID, 
                                                                               parentFileID: parentFileID,
                                                                               name: filePath.lastPathComponent,
                                                                               preHash: nil),
                  let uploadUrl = createFileResp.partInfoList.first?.uploadUrl,
                  let uploadID = createFileResp.uploadID else {
                return
            }
            
//            WebRequest.uploadFile(data: data, uploadUrl: uploadUrl) { progress in
//                debugPrint("已上传:\((Double(data.count) * Double(progress)).binarySizeString) / \(Double(data.count).binarySizeString)")
//            } completion: { success in
//                debugPrint("上传\(success ? "成功": "失败")")
//                Task {
//                    let res = try? await WebRequest.uploadFileComplete(driveID: driveID, fileID: createFileResp.fileID, uploadID: uploadID)
//                    
//                }
//            }
            if let task = UploadManager.shared.upload(url: uploadUrl, fileName: filePath.path()) {
                task.progressHandler = { progress in
                    if progress == 1.0 {
                        Task {
                            let res = try? await WebRequest.uploadFileComplete(driveID: driveID, fileID: createFileResp.fileID, uploadID: uploadID)
                        }
                    }
                }
            }
        }
    }
}
