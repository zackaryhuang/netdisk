//
//  ABFinishUploadOperation.swift
//  ABCloud
//
//  Created by Zackary on 2024/5/27.
//

import Cocoa

class ABFinishUploadOperation: ABAsyncOperation {
    let driveID: String
    let fileID: String
    let uploadID: String
    
    var fileData: AliFileData?
    
    init(driveID: String, fileID: String, uploadID: String) {
        self.driveID = driveID
        self.fileID = fileID
        self.uploadID = uploadID
    }
    
    override func main() {
        ab_isExecuting = true
        debugPrint("调用文件上传完成接口...")
        Task {
            self.fileData = try? await WebRequest.uploadFileComplete(driveID: driveID, fileID: fileID, uploadID: uploadID)
            finish()
        }
    }
}
