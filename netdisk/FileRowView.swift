//
//  FileRowView.swift
//  netdisk
//
//  Created by Zackary on 2023/8/31.
//

import Cocoa
import SnapKit
import SwiftUI
import Kingfisher

class FileRowView: NSTableRowView {
    
    let thumbImageView = {
        let imageView = NSImageView()
        return imageView
    }()
    
    let titleLabel = {
       let titleLabel = NSTextField()
        titleLabel.isEditable = false
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.drawsBackground = false
        titleLabel.isSelectable = false
        titleLabel.font = NSFont(PingFang: 16)
        titleLabel.isBordered = false
        return titleLabel
    }()
    
    let fileSizeLabel = {
        let titleLabel = NSTextField()
         titleLabel.isEditable = false
         titleLabel.drawsBackground = false
         titleLabel.isSelectable = false
         titleLabel.font = NSFont(PingFang: 12)
         titleLabel.isBordered = false
         return titleLabel
    }()
    
    var isFocused = false
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func configUI() {
        addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.centerY.equalTo(self)
            make.width.height.equalTo(28)
        }
        
        addSubview(fileSizeLabel)
        fileSizeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
            
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbImageView.snp.trailing).offset(20)
            make.centerY.equalTo(self)
//            make.trailing.lessThanOrEqualTo(fileSizeLabel.snp.leading).offset(-30)
            make.width.lessThanOrEqualTo(350)
        }
    }

    @objc func downloadFile() {
        debugPrint("Download file:")
    }
    
    func updateRowView(with fileData: any FileData) {
        titleLabel.stringValue = fileData.fileName
        if let size = fileData.size, size > 0 {
            fileSizeLabel.isHidden = false
            fileSizeLabel.stringValue = Double(size).binarySizeString
        } else {
            fileSizeLabel.isHidden = true
            fileSizeLabel.stringValue = ""
        }
        if fileData.isDir {
            thumbImageView.image = NSImage(named: "icon_folder")
        } else {
            if fileData.category == .Video {
                thumbImageView.image = NSImage(named: "icon_video")
            } else if fileData.category == .Audio {
                thumbImageView.image = NSImage(named: "icon_audio")
            } else if fileData.category == .Picture {
                if let imageUrl = fileData.thumbnail {
                    thumbImageView.kf.setImage(with: imageUrl, placeholder: NSImage(named: "icon_photo"))
                } else if let imageUrl = fileData.thumbnail {
                    thumbImageView.kf.setImage(with: imageUrl, placeholder: NSImage(named: "icon_photo"))
                } else if let imageUrl = fileData.thumbnail {
                    thumbImageView.kf.setImage(with: imageUrl, placeholder: NSImage(named: "icon_photo"))
                } else {
                    debugPrint(fileData.fileName)
                    thumbImageView.image = NSImage(named: "icon_unknown")
                }
            } else if fileData.category == .Document {
                if fileData.fileName.hasSuffix(".docx") == true ||
                    fileData.fileName.hasSuffix(".doc") == true {
                    thumbImageView.image = NSImage(named: "icon_word")
                } else if fileData.fileName.hasSuffix(".xlsx") == true ||
                            fileData.fileName.hasSuffix(".xls") == true {
                    thumbImageView.image = NSImage(named: "icon_excel")
                } else if fileData.fileName.hasSuffix(".pptx") == true ||
                            fileData.fileName.hasSuffix(".ppt") == true {
                    thumbImageView.image = NSImage(named: "icon_ppt")
                } else if fileData.fileName.hasSuffix(".pdf") == true {
                    thumbImageView.image = NSImage(named: "icon_pdf")
                } else if fileData.fileName.hasSuffix(".txt") == true {
                    thumbImageView.image = NSImage(named: "icon_txt")
                } else {
                    debugPrint(fileData.fileName)
                    thumbImageView.image = NSImage(named: "icon_unknown")
                }
            } else if fileData.category == .Application {
                if fileData.fileName.hasSuffix(".exe") == true {
                    thumbImageView.image = NSImage(named: "icon_windows")
                } else {
                    debugPrint(fileData.fileName)
                    thumbImageView.image = NSImage(named: "icon_unknown")
                }
            } else if fileData.category == .Torrent {
                if fileData.fileName.hasSuffix(".torrent") == true {
                    thumbImageView.image = NSImage(named: "icon_bt")
                } else {
                    debugPrint(fileData.fileName)
                    thumbImageView.image = NSImage(named: "icon_unknown")
                }
            } else {
                if fileData.fileName.hasSuffix(".zip") == true ||
                    fileData.fileName.hasSuffix(".rar") == true {
                    thumbImageView.image = NSImage(named: "icon_zip")
                } else if fileData.fileName.hasSuffix(".psd") == true {
                    thumbImageView.image = NSImage(named: "icon_psd")
                } else if fileData.fileName.hasSuffix(".dmg") == true {
                    thumbImageView.image = NSImage(named: "icon_apple")
                } else {
                    debugPrint(fileData.fileName)
                    thumbImageView.image = NSImage(named: "icon_unknown")
                }
            }
        }
        
        if fileData.isDir {
            self.menu = nil
        } else {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "下载", action: #selector(downloadFile), keyEquivalent: ""))
            self.menu = menu
        }
    }
    
    
    
    override func updateTrackingAreas() {
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self)
        addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        isFocused = true
        display()
    }
    
    override func mouseExited(with event: NSEvent) {
        isFocused = false
        display()
    }
    
    override func drawBackground(in dirtyRect: NSRect) {
        super.drawBackground(in: dirtyRect)
        if !isFocused {
            return
        }
        
        NSColor(hex: 0x2C2C2C).setFill()
        let hoverPath = NSBezierPath(roundedRect: dirtyRect, xRadius: 10, yRadius: 10)
        hoverPath.fill()
    }
}
