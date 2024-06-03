//
//  ABCreateFileOperation.swift
//  ABCloud
//
//  Created by Zackary on 2024/5/27.
//

import Foundation

class ABCreateFileOperation: ABAsyncOperation {
    
    let driveID: String
    let parentFileID: String
    let fileName: String
    let preHash: String?
    let multiPartNumber: Int
    var fileCreateResp: AliFileCreateResp?
    
    init(driveID: String, parentFileID: String, fileName: String, preHash: String?, multiPartNumber: Int = 1) {
        self.driveID = driveID
        self.parentFileID = parentFileID
        self.fileName = fileName
        self.preHash = preHash
        self.multiPartNumber = multiPartNumber
    }
    
    override func main() {
        ab_isExecuting = true
        Task {
            self.fileCreateResp = try? await WebRequest.requestCreateFile(driveID: driveID,
                                                                          parentFileID: parentFileID,
                                                                          name: fileName,
                                                                          preHash: preHash,
                                                                          multiPartNumber: multiPartNumber)
            finish()
        }
    }
    
}
