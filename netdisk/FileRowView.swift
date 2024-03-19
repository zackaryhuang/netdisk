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
import Tiercel

class FileRowView: NSTableRowView {
    
    let thumbImageView = {
        let imageView = NSImageView()
        return imageView
    }()
    
    var data: FileData?
    
    let titleLabel = {
       let titleLabel = NSTextField()
        titleLabel.isEditable = false
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.drawsBackground = false
        titleLabel.isSelectable = false
        titleLabel.font = NSFont(LXGWRegularSize: 16)
        titleLabel.isBordered = false
        return titleLabel
    }()
    
    let fileSizeLabel = {
        let titleLabel = NSTextField()
         titleLabel.isEditable = false
         titleLabel.drawsBackground = false
         titleLabel.isSelectable = false
         titleLabel.font = NSFont(LXGWRegularSize: 12)
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
        if !ZigBookmark.bookmarkStartAccessing(filePath: ZigDownloadManager.downloadPath) {
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.allowsMultipleSelection = false
            openPanel.begin { [weak self] result in
                if result == .OK,
                   let downloadPath = openPanel.urls.first {
                    if !(ZigBookmark.saveBookmark(filePath: downloadPath.absoluteString)) || !ZigBookmark.bookmarkStartAccessing(filePath: downloadPath.absoluteString) { return }
                    ZigDownloadManager.downloadPath = downloadPath.absoluteString
                    self?.startDownload()
                }
            }
        } else {
            startDownload()
        }
    }
    
    func startDownload() {
        if let fileID = data?.fileID {
            Task {
                if let downloadInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID) {
                    debugPrint(downloadInfo.downloadURL ?? "未知链接")
                    let manager = ZigDownloadManager.shared.downloadSessionManager
                    let task = manager.download(downloadInfo.downloadURL!, fileName: data?.fileName)
                    task?.progress { (task) in
                        debugPrint("progress:\(task.progress.fractionCompleted)")
                    }.success { (task) in
                        debugPrint("下载完成")
                    }.failure { (task) in
                        debugPrint("下载失败")
                    }
                }
            }
        }
    }
    
    func updateRowView(with fileData: any FileData) {
        data = fileData
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
            thumbImageView.image = Utils.thumbForFile(info: fileData)
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
