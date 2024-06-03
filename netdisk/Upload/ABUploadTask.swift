//
//  ABUploadTask.swift
//  ABCloud
//
//  Created by Zackary on 2024/5/27.
//

import Foundation

enum ABUploadState: Codable {
    case waiting
    case running
    case succeeded
    case failed
    case canceled
}

class ABUploadTask: NSObject, Codable {
    static func == (lhs: ABUploadTask, rhs: ABUploadTask) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    static var uploadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    let filePath: URL
    let driveID: String
    let parentFileID: String
    var progressHandler: ((Progress) -> ())?
    var completionHandler: ((Error?) -> ())?
    var state: ABUploadState = .waiting {
        didSet {
            if state == .running {
                NotificationCenter.default.post(name: UploadManager.RunningCountChangeNotificationName, object: nil)
            }
        }
    }
    let identifier: String
    let speedCalculator = SpeedCalculator()
    var speed = 0
    lazy var fileSize: Int = {
        guard let fileSize = ABUploadOperation.GetFileSize(for: self.filePath) else { return 0 }
        return fileSize
    }()
    
    lazy var progress: Progress = {
        let p = Progress(totalUnitCount: Int64(self.fileSize))
        return p
    }()
    
    weak var operation: ABUploadOperation?
    
    private enum CodingKeys: CodingKey {
            case filePath, driveID, parentFileID, state, identifier
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filePath = try container.decode(URL.self, forKey: .filePath)
        driveID = try container.decode(String.self, forKey: .driveID)
        parentFileID = try container.decode(String.self, forKey: .parentFileID)
        state = try container.decode(ABUploadState.self, forKey: .state)
        identifier = try container.decode(String.self, forKey: .identifier)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(filePath, forKey: .filePath)
        try container.encode(driveID, forKey: .driveID)
        try container.encode(parentFileID, forKey: .parentFileID)
        try container.encode(state, forKey: .state)
        try container.encode(identifier, forKey: .identifier)
    }
    
    init(filePath: URL, driveID: String, parentFileID: String) {
        self.filePath = filePath
        self.driveID = driveID
        self.parentFileID = parentFileID
        self.identifier = UUID().uuidString
    }
    
    func start() {
        guard let uploadOperation = ABUploadOperation(fileURL: filePath, parentID: parentFileID, driveID: driveID) else {
            ABLog.Upload.log(level: .error, "ABUploadOperation 创建失败")
            state = .failed
            return
        }
        operation = uploadOperation
        operation?.progressHandler = { [weak self] progress in
            guard let self = self else { return }
            if self.state != .running {
                self.state = .running
                UploadManager.shared.storeTasks()
                self.speedCalculator.delegate = self
                self.speedCalculator.start()
            }
            self.progressHandler?(progress)
            self.speedCalculator.updateCurrentCompletedUnitCount(count: progress.completedUnitCount)
        }
        operation?.completionHandler = { [weak self] error  in
            self?.state = error == nil ? .succeeded : .failed
            self?.completionHandler?(error)
            self?.speedCalculator.stop()
            UploadManager.shared.storeTasks()
        }
        Self.uploadQueue.addOperation(uploadOperation)
    }
    
    func cancel() {
        state = .canceled
        operation?.cancel()
        speedCalculator.stop()
    }
}

extension ABUploadTask: SpeedCalculatorDelegate {
    func speedCalculator(speedDidUpdate speed: Int) {
        self.speed = speed
        ABLog.Upload.log(level: .info, "上传速度:\(speed.decimalSizeString) / s")
    }
}
