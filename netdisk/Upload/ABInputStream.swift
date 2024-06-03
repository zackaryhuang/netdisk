//
//  ABInputStream.swift
//  ABCloud
//
//  Created by Zackary on 2024/5/30.
//

import Cocoa

import Foundation

class ABInputStream: InputStream {
    private let fileHandle: FileHandle
    private let startOffset: UInt64
    private let length: Int
    private var bytesRead: Int = 0
    private var status: Stream.Status = .notOpen

    init?(fileURL: URL, startOffset: UInt64, length: Int) {
        guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else {
            return nil
        }
        self.fileHandle = fileHandle
        self.startOffset = startOffset
        self.length = length
        super.init(data: Data())
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        guard bytesRead < length else {
            return 0
        }
        
        let bytesToRead = min(len, length - bytesRead)
        let data = fileHandle.readData(ofLength: bytesToRead)
        data.copyBytes(to: buffer, count: data.count)
        bytesRead += data.count
        return data.count
    }

    override var hasBytesAvailable: Bool {
        return bytesRead < length
    }

    override func close() {
        fileHandle.closeFile()
        status = .closed
    }
    
    override func open() {
        status = .opening
        self.fileHandle.seek(toFileOffset: startOffset)
        status = .open
    }
    
    override var streamStatus: Stream.Status {
        return status
    }
    
    override func schedule(in aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
        
    }
    
    override func remove(from aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
        
    }
    
    override var delegate: (any StreamDelegate)? {
        set {
            
        }
        get {
            return nil
        }
    }
}
