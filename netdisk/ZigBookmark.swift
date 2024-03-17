//
//  ZIgBookmark.swift
//  netdisk
//
//  Created by Zackary on 2024/3/17.
//

import Foundation

class ZigBookmark {
    static func saveBookmark(filePath: String) -> Bool {
        guard let filePathURL = try? filePath.asURL() else { return false }
        guard let data = try? filePathURL.bookmarkData(options: .withSecurityScope) else { return false }
        UserDefaults.standard.setValue(data, forKey: filePath)
        return true
    }
    
    static func removeBookmark(filePath: String) -> Bool {
        guard let filePathURL = try? filePath.asURL() else { return false }
        guard (try? filePathURL.bookmarkData(options: .withSecurityScope)) != nil else { return false }
        UserDefaults.standard.removeObject(forKey: filePath)
        return true
    }
    
    static func bookmarkStartAccessing(filePath: String) -> Bool {
        guard let data = UserDefaults.standard.object(forKey: filePath) as? Data else { return false }
        var isStable = false
        guard let url = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &isStable) else { return false }
        return url.startAccessingSecurityScopedResource()
    }
    
    static func bookmarkStopAccessing(filePath: String) -> Bool {
        guard let data = UserDefaults.standard.object(forKey: filePath) as? Data else { return false }
        var isStable = false
        guard let url = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &isStable) else { return false }
        url.stopAccessingSecurityScopedResource()
        return true
    }
}
