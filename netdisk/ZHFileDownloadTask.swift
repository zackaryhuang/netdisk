//
//  ZHFileDownloadTask.swift
//  netdisk
//
//  Created by Zackary on 2023/9/27.
//

import Cocoa

class ZHFileDownloadTask: NSObject {

    let URL: String
    let sliceMode: Bool
    let sliceSize: Int
    var progress: ((_ URL: String, _ finished: Int, _ expected: Int) -> Void)?
    var completion: ((_ URL: String, _ filePath: String, _ error: NSError) -> Void)?
    private var uniqueKey: String?
    
    init(URL: String, 
         sliceMode: Bool,
         sliceSize: Int,
         progress: ( (_: String, _: Int, _: Int) -> Void)? = nil,
         completion: ( (_: String, _: String, _: NSError) -> Void)? = nil,
         uniqueKey: String? = nil) {
        self.URL = URL
        self.sliceMode = sliceMode
        self.sliceSize = sliceSize
        self.progress = progress
        self.completion = completion
        self.uniqueKey = uniqueKey
    }
    
    func getUniqueKey() -> String {
        return self.uniqueKey ?? self.URL
    }
    
}
