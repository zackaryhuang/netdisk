//
//  ZHFIleDownloadCache.swift
//  netdisk
//
//  Created by Zackary on 2023/9/27.
//

import Cocoa

enum ZHFileDownloadCacheState {
    case Null
    case PartDownloaded
    case DownloadComplete
}

class ZHFileDownloadCache: NSObject {
    let state = ZHFileDownloadCacheState.Null
    let URL: String
    init(URL: String) {
        self.URL = URL
    }
}
