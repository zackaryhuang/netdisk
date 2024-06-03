//
//  ABMultiPartUploadOperation.swift
//  ABCloud
//
//  Created by Zackary on 2024/5/31.
//

import Cocoa
import Alamofire

protocol MultiPartUploadDelegate: NSObjectProtocol {
    func uploadOperation(operation: ABMultiPartUploadOperation, failedWith error: Error)
    func uploadOperation(operation: ABMultiPartUploadOperation, progress: Progress)
}

class ABMultiPartUploadOperation: ABAsyncOperation {
    let fileURL: URL
    let uploadUrl: String
    let offset: Int
    let length: Int
    let partNumber: Int
    var uploadRequest: UploadRequest?
    weak var delegate: MultiPartUploadDelegate?
    
    init(fileURL: URL, uploadUrl: String, offset: Int, length: Int, partNumber: Int) {
        self.fileURL = fileURL
        self.uploadUrl = uploadUrl
        self.offset = offset
        self.length = length
        self.partNumber = partNumber
    }
    
    override func main() {
        ab_isExecuting = true
        do {
            let handle = try FileHandle(forReadingFrom: fileURL)
            try handle.seek(toOffset: UInt64(offset))
            guard let data = try handle.read(upToCount: length) else {
                finish()
                return
            }
            var headers = HTTPHeaders()
            headers.add(name: "Content-Length", value: "\(length)")
            uploadRequest = AF.upload(data, to: uploadUrl, method: .put, headers: headers)
            uploadRequest?.uploadProgress { [weak self] progress in
                guard let self = self else { return }
                self.delegate?.uploadOperation(operation: self, progress: progress)
            }
            uploadRequest?.response { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success:
                    debugPrint("[Upload] - 分片\(self.partNumber)上传成功")
                case .failure(let error):
                    self.delegate?.uploadOperation(operation: self, failedWith: error)
                }
                self.finish()
            }
        } catch let error {
            debugPrint("[Upload] - \(error.localizedDescription)")
            finish()
        }
    }
    
    override func cancel() {
        uploadRequest?.cancel()
        ab_isCanceled = true
        finish()
    }
    
    func suspend() {
        ab_isExecuting = false
        uploadRequest?.suspend()
    }
    
    func resume() {
        uploadRequest?.resume()
        ab_isExecuting = true
    }
    
    override func finish() {
        uploadRequest = nil
        super.finish()
    }
}
