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
            make.trailing.lessThanOrEqualTo(fileSizeLabel.snp.leading).offset(-30)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func updateRowView(with fileInfo: FileInfo?) {
        if let info = fileInfo {
            titleLabel.stringValue = info.serverFileName ?? ""
            if let intSize = info.size, intSize > 0 {
                fileSizeLabel.stringValue = Double(intSize).binarySizeString
            } else {
                fileSizeLabel.stringValue = ""
            }
            if info.isDir == 1 {
                thumbImageView.image = NSImage(named: "icon_folder")
            } else {
                if info.category == 1 {
                    thumbImageView.image = NSImage(named: "icon_video")
                } else if info.category == 2 {
                    thumbImageView.image = NSImage(named: "icon_audio")
                } else if info.category == 3 {
                    if let imageUrl = fileInfo?.thumbs?["url3"] as? String {
                        thumbImageView.kf.setImage(with: URL(string: imageUrl), placeholder: NSImage(named: "icon_photo"))
                    } else if let imageUrl = fileInfo?.thumbs?["url2"] as? String {
                        thumbImageView.kf.setImage(with: URL(string: imageUrl), placeholder: NSImage(named: "icon_photo"))
                    } else if let imageUrl = fileInfo?.thumbs?["url1"] as? String {
                        thumbImageView.kf.setImage(with: URL(string: imageUrl), placeholder: NSImage(named: "icon_photo"))
                    } else {
                        debugPrint(info.serverFileName ?? "")
                        thumbImageView.image = NSImage(named: "icon_unknown")
                    }
                } else if info.category == 4 {
                    if info.serverFileName?.hasSuffix(".docx") == true ||
                        info.serverFileName?.hasSuffix(".doc") == true {
                        thumbImageView.image = NSImage(named: "icon_word")
                    } else if info.serverFileName?.hasSuffix(".xlsx") == true ||
                                info.serverFileName?.hasSuffix(".xls") == true {
                        thumbImageView.image = NSImage(named: "icon_excel")
                    } else if info.serverFileName?.hasSuffix(".pptx") == true ||
                                info.serverFileName?.hasSuffix(".ppt") == true {
                        thumbImageView.image = NSImage(named: "icon_ppt")
                    } else if info.serverFileName?.hasSuffix(".pdf") == true {
                        thumbImageView.image = NSImage(named: "icon_pdf")
                    } else if info.serverFileName?.hasSuffix(".txt") == true {
                        thumbImageView.image = NSImage(named: "icon_txt")
                    } else {
                        debugPrint(info.serverFileName ?? "")
                        thumbImageView.image = NSImage(named: "icon_unknown")
                    }
                } else if info.category == 5 {
                    if info.serverFileName?.hasSuffix(".exe") == true {
                        thumbImageView.image = NSImage(named: "icon_windows")
                    } else {
                        debugPrint(info.serverFileName ?? "")
                        thumbImageView.image = NSImage(named: "icon_unknown")
                    }
                } else if info.category == 7 {
                    if info.serverFileName?.hasSuffix(".torrent") == true {
                        thumbImageView.image = NSImage(named: "icon_bt")
                    } else {
                        debugPrint(info.serverFileName ?? "")
                        thumbImageView.image = NSImage(named: "icon_unknown")
                    }
                } else {
                    if info.serverFileName?.hasSuffix(".zip") == true ||
                        info.serverFileName?.hasSuffix(".rar") == true {
                        thumbImageView.image = NSImage(named: "icon_zip")
                    } else if info.serverFileName?.hasSuffix(".psd") == true {
                        thumbImageView.image = NSImage(named: "icon_psd")
                    } else if info.serverFileName?.hasSuffix(".dmg") == true {
                        thumbImageView.image = NSImage(named: "icon_apple")
                    } else {
                        debugPrint(info.serverFileName ?? "")
                        thumbImageView.image = NSImage(named: "icon_unknown")
                    }
                }
            }
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
