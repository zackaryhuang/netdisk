//
//  ABUploadOperation.swift
//  ABCloud
//
//  Created by Zackary on 2024/5/27.
//

import Cocoa
import Alamofire

struct SegmentInfo {
    let size: Int
    let count: Int
}

class ABUploadOperation: ABAsyncOperation {
    static var uploadQueue = OperationQueue()
    let fileURL: URL
    let parentID: String
    let driveID: String
    let fileName: String!
    let segmentInfo: SegmentInfo
    var createFileResp: AliFileCreateResp!
    var partUploadOperations = [ABMultiPartUploadOperation]()
    var partUploadQueue: OperationQueue
    let fileSize: Int
    var progressHandler: ((Progress) -> ())?
    var completionHandler: ((Error?) -> ())?
    weak var task: ABUploadTask?
    
    init?(fileURL: URL, parentID: String, driveID: String, fileName: String? = nil) {
        self.fileURL = fileURL
        self.parentID = parentID
        self.driveID = driveID
        self.fileName = fileName ?? fileURL.lastPathComponent
        guard let fileSize = Self.GetFileSize(for: fileURL) else { return nil }
        self.fileSize = fileSize
        self.segmentInfo = Self.GetSegmentInfo(for: fileSize)
        self.partUploadQueue = OperationQueue()
        self.partUploadQueue.maxConcurrentOperationCount = 1
    }
    
    override func main() {
        ab_isExecuting = true
        Task {
            guard let createFileResp = try? await createFile() else {
                let error = NSError(code: -1, description: "调用文件创建接口失败")
                self.completionHandler?(error)
                finish()
                return
            }
            self.createFileResp = createFileResp
            
            multiPartUpload()
        }
    }
    
    private func multiPartUpload() {
        let partInfoList = createFileResp.partInfoList
        var lastOperation: ABMultiPartUploadOperation? = nil
        for partInfo in partInfoList {
            let offset = (partInfo.partNumber - 1) * segmentInfo.size
            let isLastSegment = partInfo.partNumber == partInfoList.count
            let length = isLastSegment ? fileSize - offset : segmentInfo.size
            let multiUploadOperation = ABMultiPartUploadOperation(fileURL: fileURL, uploadUrl: partInfo.uploadUrl, offset: offset, length: length, partNumber: partInfo.partNumber)
            multiUploadOperation.delegate = self
//            partUploadOperations.append(multiUploadOperation)
            partUploadQueue.addOperation(multiUploadOperation)
            lastOperation = multiUploadOperation
        }
        lastOperation?.completionBlock = {
            Task {
                if !self.ab_isCanceled {
                    _ = try await self.reportUploadComplete()
                    self.completionHandler?(nil)
                    self.finish()
                }
            }
        }
    }
    
    private func createFile() async throws -> AliFileCreateResp? {
        return try await WebRequest.requestCreateFile(driveID: driveID,
                                                      parentFileID: parentID,
                                                      name: fileName,
                                                      preHash: nil,
                                                      multiPartNumber: segmentInfo.count)
    }
    
    private func reportUploadComplete() async throws -> AliFileData? {
        let result = try await WebRequest.uploadFileComplete(driveID: driveID,
                                                             fileID: createFileResp.fileID,
                                                             uploadID: createFileResp.uploadID)
        return result
    }
    
    static func GetFileSize(for fileURL: URL) -> Int? {
        guard let fileSize = try? FileManager.default.attributesOfItem(atPath: fileURL.path())[FileAttributeKey.size] as? Int else { return nil }
        return fileSize
    }
    
    /// 根据文件路径获取分片大小和分片数量
    /// - Parameter fileURL: 文件路径
    /// - Returns: 分片信息
    static private func GetSegmentInfo(for fileSize: Int) -> SegmentInfo {
        if fileSize <= 100.D_MB {
            let segmentSize = 10.D_MB
            let segmentCount = Self.GetSegmentCount(segmentSize: segmentSize, fileSize: fileSize)
            return SegmentInfo(size: segmentSize, count: segmentCount)
        } else if fileSize <= 1.D_GB {
            let segmentSize = 20.D_MB
            let segmentCount = Self.GetSegmentCount(segmentSize: segmentSize, fileSize: fileSize)
            return SegmentInfo(size: segmentSize, count: segmentCount)
        } else if fileSize <= 10.D_GB {
            let segmentSize = 50.D_MB
            let segmentCount = Self.GetSegmentCount(segmentSize: segmentSize, fileSize: fileSize)
            return SegmentInfo(size: segmentSize, count: segmentCount)
        }
        let segmentSize = 100.D_MB
        let segmentCount = Self.GetSegmentCount(segmentSize: segmentSize, fileSize: fileSize)
        return SegmentInfo(size: segmentSize, count: segmentCount)
    }
    
    static private func GetSegmentCount(segmentSize: Int, fileSize: Int) -> Int {
        var segmentCount = fileSize / segmentSize
        if fileSize % segmentSize != 0 {
            segmentCount += 1
        }
        return segmentCount
    }
    
    override func finish() {
        self.partUploadOperations.removeAll()
        super.finish()
    }
    
    override func cancel() {
        self.partUploadOperations.forEach { operation in
            operation.cancel()
        }
        super.cancel()
    }
}

extension ABUploadOperation: MultiPartUploadDelegate {
    func uploadOperation(operation: ABMultiPartUploadOperation, failedWith error: any Error) {
        self.partUploadOperations.forEach{ operation in
            operation.cancel()
        }
        self.completionHandler?(error)
        finish()
    }
    
    func uploadOperation(operation: ABMultiPartUploadOperation, progress: Progress) {
        ABLog.Upload.log(level: .info, "分片\(operation.partNumber) 上传进度:\(progress.fractionCompleted)")
        var completedUnitCount: Int64 = 0
        for uploadOperation in self.partUploadOperations {
            if uploadOperation.partNumber < operation.partNumber {
                completedUnitCount += Int64(uploadOperation.length)
            }
        }
        completedUnitCount += progress.completedUnitCount
        let taskProgress = task?.progress ?? Progress(totalUnitCount: Int64(self.fileSize))
        taskProgress.completedUnitCount = Int64(completedUnitCount)
        self.progressHandler?(taskProgress)
        
    }
}
