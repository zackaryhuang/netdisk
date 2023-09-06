//
//  Utils.swift
//  netdisk
//
//  Created by Zackary on 2023/9/6.
//

import Foundation
import Cocoa

class Utils {
    static func thumbForFile(info: FileDetailInfo) -> NSImage? {
        if info.isdir == 1 {
            return NSImage(named: "icon_folder")
        } else {
            if info.category == 1 {
                return NSImage(named: "icon_video")
            }
            
            if info.category == 2 {
                return NSImage(named: "icon_audio")
            }
            
            if info.category == 3 {
                return NSImage(named: "icon_photo")
            }
            
            if info.category == 4 {
                if info.filename?.hasSuffix(".docx") == true ||
                    info.filename?.hasSuffix(".doc") == true {
                    return NSImage(named: "icon_word")
                } 
                
                if info.filename?.hasSuffix(".xlsx") == true ||
                            info.filename?.hasSuffix(".xls") == true {
                    return NSImage(named: "icon_excel")
                }
                
                if info.filename?.hasSuffix(".pptx") == true ||
                            info.filename?.hasSuffix(".ppt") == true {
                    return NSImage(named: "icon_ppt")
                }
                
                if info.filename?.hasSuffix(".pdf") == true {
                    return NSImage(named: "icon_pdf")
                }
                
                if info.filename?.hasSuffix(".txt") == true {
                    return NSImage(named: "icon_txt")
                } 
                debugPrint(info.filename ?? "")
                return NSImage(named: "icon_unknown")
            }
            
            if info.category == 5 {
                if info.filename?.hasSuffix(".exe") == true {
                    return NSImage(named: "icon_windows")
                } 
                debugPrint(info.filename ?? "")
                return NSImage(named: "icon_unknown")
            } 
            
            if info.category == 7 {
                if info.filename?.hasSuffix(".torrent") == true {
                    return NSImage(named: "icon_bt")
                } 
                debugPrint(info.filename ?? "")
                return NSImage(named: "icon_unknown")
            } 
            
            if info.filename?.hasSuffix(".zip") == true ||
                info.filename?.hasSuffix(".rar") == true {
                return NSImage(named: "icon_zip")
            } 
            
            if info.filename?.hasSuffix(".psd") == true {
                return NSImage(named: "icon_psd")
            }
            
            if info.filename?.hasSuffix(".dmg") == true {
                return NSImage(named: "icon_apple")
            }
            
            debugPrint(info.filename ?? "")
            return NSImage(named: "icon_unknown")
        }
    }
}
