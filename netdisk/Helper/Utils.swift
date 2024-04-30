//
//  Utils.swift
//  netdisk
//
//  Created by Zackary on 2023/9/6.
//

import Foundation
import Cocoa

class Utils {
    static func thumbForFile(info: any FileData) -> NSImage? {
        if info.isDir {
            return NSImage(named: "icon_folder")
        } else {
            if info.category == .Video {
                return NSImage(named: "icon_video")
            }
            
            if info.category == .Audio {
                return NSImage(named: "icon_audio")
            }
            
            if info.category == .Picture {
                return NSImage(named: "icon_photo")
            }
            
            if info.category == .Document {
                if info.fileName.hasSuffix(".docx") == true ||
                    info.fileName.hasSuffix(".doc") == true {
                    return NSImage(named: "icon_word")
                } 
                
                if info.fileName.hasSuffix(".xlsx") == true ||
                            info.fileName.hasSuffix(".xls") == true {
                    return NSImage(named: "icon_excel")
                }
                
                if info.fileName.hasSuffix(".pptx") == true ||
                            info.fileName.hasSuffix(".ppt") == true {
                    return NSImage(named: "icon_ppt")
                }
                
                if info.fileName.hasSuffix(".pdf") == true {
                    return NSImage(named: "icon_pdf")
                }
                
                if info.fileName.hasSuffix(".txt") == true {
                    return NSImage(named: "icon_txt")
                }
                
                if info.fileName.hasSuffix(".epub") == true {
                    return NSImage(named: "icon_epub")
                }
                
                debugPrint(info.fileName)
                return NSImage(named: "icon_unknown")
            }
            
            if info.category == .Application {
                if info.fileName.hasSuffix(".exe") == true {
                    return NSImage(named: "icon_windows")
                } 
                debugPrint(info.fileName)
                return NSImage(named: "icon_unknown")
            } 
            
            if info.category == .Torrent {
                if info.fileName.hasSuffix(".torrent") == true {
                    return NSImage(named: "icon_bt")
                } 
                debugPrint(info.fileName)
                return NSImage(named: "icon_unknown")
            } 
            
            if info.fileName.hasSuffix(".zip") == true ||
                info.fileName.hasSuffix(".rar") == true {
                return NSImage(named: "icon_zip")
            }
            
            if info.fileName.hasSuffix(".psd") == true {
                return NSImage(named: "icon_psd")
            }
            
            if info.fileName.hasSuffix(".dmg") == true {
                return NSImage(named: "icon_apple")
            }
            
            debugPrint(info.fileName)
            return NSImage(named: "icon_unknown")
        }
    }
    
    static func thumbForFile(fileName: String) -> NSImage? {
        let lowercasedFileName = fileName.lowercased()
        if lowercasedFileName.hasSuffix(".docx") == true ||
            lowercasedFileName.hasSuffix(".doc") == true {
            return NSImage(named: "icon_word")
        }
        
        if lowercasedFileName.hasSuffix(".png") == true ||
            lowercasedFileName.hasSuffix(".jpg") == true ||
            lowercasedFileName.hasSuffix(".jpeg") == true ||
            lowercasedFileName.hasSuffix(".gif") == true {
            return NSImage(named: "icon_photo")
        }
        
        if lowercasedFileName.hasSuffix(".mp4") == true ||
            lowercasedFileName.hasSuffix(".mov") == true ||
            lowercasedFileName.hasSuffix(".avi") == true ||
            lowercasedFileName.hasSuffix(".3gp") == true ||
            lowercasedFileName.hasSuffix(".m4v") == true ||
            lowercasedFileName.hasSuffix(".mkv") == true ||
            lowercasedFileName.hasSuffix(".flv") == true {
            return NSImage(named: "icon_video")
        }
        
        if lowercasedFileName.hasSuffix(".wav") == true ||
            lowercasedFileName.hasSuffix(".flac") == true ||
            lowercasedFileName.hasSuffix(".ape") == true ||
            lowercasedFileName.hasSuffix(".mp3") == true ||
            lowercasedFileName.hasSuffix(".aac") == true {
            return NSImage(named: "icon_audio")
        }
        
        if lowercasedFileName.hasSuffix(".xlsx") == true ||
            lowercasedFileName.hasSuffix(".xls") == true {
            return NSImage(named: "icon_excel")
        }
        
        if lowercasedFileName.hasSuffix(".pptx") == true ||
            lowercasedFileName.hasSuffix(".ppt") == true {
            return NSImage(named: "icon_ppt")
        }
        
        if lowercasedFileName.hasSuffix(".pdf") == true {
            return NSImage(named: "icon_pdf")
        }
        
        if lowercasedFileName.hasSuffix(".txt") == true {
            return NSImage(named: "icon_txt")
        }
        
        if lowercasedFileName.hasSuffix(".exe") == true {
            return NSImage(named: "icon_windows")
        }
        
        if lowercasedFileName.hasSuffix(".torrent") == true {
            return NSImage(named: "icon_bt")
        }
        
        if lowercasedFileName.hasSuffix(".zip") == true ||
            fileName.hasSuffix(".rar") == true {
            return NSImage(named: "icon_zip")
        }
        
        if lowercasedFileName.hasSuffix(".psd") == true {
            return NSImage(named: "icon_psd")
        }
        
        if lowercasedFileName.hasSuffix(".dmg") == true {
            return NSImage(named: "icon_apple")
        }
        
        if lowercasedFileName.hasSuffix(".epub") == true {
            return NSImage(named: "icon_epub")
        }
        
        debugPrint(lowercasedFileName)
        return NSImage(named: "icon_unknown")
    }
}
