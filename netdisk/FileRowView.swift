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

protocol FileRowViewDelegate: NSObjectProtocol {
    func fileRowViewDidClickDownload(fileID: String, fileName: String)
    func fileRowViewDidClickRename(fileID: String, originalName: String)
    func fileRowViewDidClickDelete(fileID: String)
    func fileRowViewDidClickCopyDownloadLink(fileID: String)
    func fileRowViewDidClickCreateFolder()
    func fileRowViewDidClickTrash(fileID: String)
    func fileRowViewDidClickCopy(fileID: String)
    func fileRowViewDidClickMove(fileID: String)
}


class FileRowView: NSTableRowView {
    static var shouldHandleTracking = true
    weak var delegate: FileRowViewDelegate?
    weak var lastHighligtItem: ZigMenuItem?
    
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
        titleLabel.font = NSFont(LXGWRegularSize: 14)
        titleLabel.isBordered = false
        return titleLabel
    }()
    
    let fileSizeLabel = {
        let titleLabel = NSTextField()
         titleLabel.isEditable = false
         titleLabel.drawsBackground = false
         titleLabel.isSelectable = false
         titleLabel.font = NSFont(LXGWRegularSize: 10)
         titleLabel.isBordered = false
         return titleLabel
    }()
    
    var isFocused = false
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
        updateTrackingAreas()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func configUI() {
        addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(50)
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
            make.width.lessThanOrEqualTo(350)
        }
        
        let sepLine = NSView()
        sepLine.wantsLayer = true
        sepLine.layer?.backgroundColor = NSColor(hex: 0x1A1A1C).cgColor
        addSubview(sepLine)
        sepLine.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(24)
            make.trailing.equalTo(self).offset(-24)
            make.bottom.equalTo(self)
            make.height.equalTo(1)
        }
    }

    @objc func copyDownloadLink() {
        if let fileID = data?.fileID {
            Task {
                if let downloadInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID) {
                    if let downloadURL = downloadInfo.downloadURL {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(downloadURL.absoluteString, forType: .string)
                        let alert = NSAlert()
                        alert.messageText = "已拷贝下载链接"
                        alert.runModal()
                    }
                } else {
                    let alert = NSAlert()
                    alert.messageText = "获取下载链接失败"
                    alert.runModal()
                }
            }
        }
    }
    
    @objc func createFolder() {
        self.delegate?.fileRowViewDidClickCreateFolder()
    }
    
    @objc func renameFile() {
        guard let fileID = data?.fileID else { return }
        guard let originalName = data?.fileName else { return }
        self.delegate?.fileRowViewDidClickRename(fileID: fileID, originalName: originalName)
    }
    
    @objc func downloadFile() {
        guard let fileID = data?.fileID, let fileName = data?.fileName else { return }
        self.delegate?.fileRowViewDidClickDownload(fileID: fileID, fileName: fileName)
    }
    
    @objc func trashFile() {
        guard let fileID = data?.fileID else { return }
        self.delegate?.fileRowViewDidClickTrash(fileID: fileID)
    }
    
    @objc func copyFile() {
        guard let fileID = data?.fileID else { return }
        self.delegate?.fileRowViewDidClickCopy(fileID: fileID)
    }
    
    @objc func moveFile() {
        guard let fileID = data?.fileID else { return }
        self.delegate?.fileRowViewDidClickMove(fileID: fileID)
    }
    
    @objc func deleteFile() {
        guard let fileID = data?.fileID else { return }
        self.delegate?.fileRowViewDidClickDelete(fileID: fileID)
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
        self.menu = getMenu()
    }
    
    override func updateTrackingAreas() {
        trackingAreas.forEach { area in
            removeTrackingArea(area)
        }
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways], owner: self)
        addTrackingArea(trackingArea)
        let mouseLocation = self.window?.mouseLocationOutsideOfEventStream
        if let location = mouseLocation {
            let newLocation = self.convert(location, from: nil)
            
            if NSPointInRect(newLocation, bounds) {
                self.mouseEntered(with: NSEvent())
            } else {
                self.mouseExited(with: NSEvent())
            }
        }
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        if !FileRowView.shouldHandleTracking { return }
        isFocused = true
        display()
    }
    
    override func mouseExited(with event: NSEvent) {
        if !FileRowView.shouldHandleTracking { return }
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
    
    private func getMenu() -> NSMenu? {
        guard let fileData = data else { return nil }
        let menu = NSMenu()
        if fileData.isDir {
            
        } else {
            menu.addItem(ZigMenuItem(title: "下载", target:self, action: #selector(downloadFile), keyEquivalent: ""))
            #if DEBUG
            menu.addItem(ZigMenuItem(title: "拷贝下载链接", target:self, action: #selector(copyDownloadLink), keyEquivalent: ""))
            #endif
        }
        menu.addItem(ZigMenuItem(title: "新建文件夹", target:self, action: #selector(createFolder), keyEquivalent: ""))
        menu.addItem(ZigMenuItem(title: "重命名", target:self, action: #selector(renameFile), keyEquivalent: ""))
//        menu.addItem(ZigMenuItem(title: "移动", target:self, action: #selector(moveFile), keyEquivalent: ""))
//        menu.addItem(ZigMenuItem(title: "复制", target:self, action: #selector(copyFile), keyEquivalent: ""))
        menu.addItem(ZigMenuItem(title: "放入回收站", target:self, action: #selector(trashFile), keyEquivalent: ""))
//        menu.addItem(ZigMenuItem(title: "直接删除", target:self, action: #selector(deleteFile), keyEquivalent: ""))
        menu.delegate = self
        return menu
    }
}

extension FileRowView: NSMenuDelegate {
    
//    func menuDidClose(_ menu: NSMenu) {
////        FileRowView.shouldHandleTracking = true
//        isFocused = false
//        mouseExited(with: NSEvent())
//    }
//    
//    func menuWillOpen(_ menu: NSMenu) {
////        FileRowView.shouldHandleTracking = false
//        isFocused = true
//        updateTrackingAreas()
//    }
    
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if let last = lastHighligtItem {
            last.zig_isHiglight = false
        }
        
        if let zigMenuItem = item as? ZigMenuItem {
            zigMenuItem.zig_isHiglight = true
            lastHighligtItem = zigMenuItem
        }
    }
    
}
