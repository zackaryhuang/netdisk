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
    func fileRowViewDidClickUpload()
}

class MenuItemModel {
    let title: String
    let action: Selector
    let target: AnyObject
    init(title: String, action: Selector, target: AnyObject) {
        self.title = title
        self.action = action
        self.target = target
    }
}

class FileRowView: NSTableRowView {
    static var shouldHandleTracking = true
    weak var delegate: FileRowViewDelegate?
    weak var lastHighligtItem: ZigMenuItem?
    
    var contentView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.layer?.backgroundColor = NSColor(hex: 0x2C2C2C, alpha: 0).cgColor
        return view
    }()
    
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
//        updateTrackingAreas()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func configUI() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        contentView.addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(50)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(28)
        }
        
        contentView.addSubview(fileSizeLabel)
        fileSizeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-20)
            make.centerY.equalTo(contentView)
            
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbImageView.snp.trailing).offset(20)
            make.centerY.equalTo(contentView)
            make.width.lessThanOrEqualTo(350)
        }
        
        let sepLine = NSView()
        sepLine.wantsLayer = true
        sepLine.layer?.backgroundColor = NSColor(hex: 0x1A1A1C).cgColor
        contentView.addSubview(sepLine)
        sepLine.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(24)
            make.trailing.equalTo(contentView).offset(-24)
            make.bottom.equalTo(contentView)
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
    
    @objc func uploadFile() {
        self.delegate?.fileRowViewDidClickUpload()
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
            fileSizeLabel.stringValue = Double(size).decimalSizeString
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
    
//    override func updateTrackingAreas() {
//        trackingAreas.forEach { area in
//            removeTrackingArea(area)
//        }
//        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways], owner: self)
//        addTrackingArea(trackingArea)
//        let mouseLocation = self.window?.mouseLocationOutsideOfEventStream
//        if let location = mouseLocation {
//            let newLocation = self.convert(location, from: nil)
//            
//            if NSPointInRect(newLocation, bounds) {
//                self.mouseEntered(with: NSEvent())
//            } else {
//                self.mouseExited(with: NSEvent())
//            }
//        }
//        super.updateTrackingAreas()
//    }
    
//    override func mouseEntered(with event: NSEvent) {
//        if !FileRowView.shouldHandleTracking { return }
//        isFocused = true
//        display()
//    }
//    
//    override func mouseExited(with event: NSEvent) {
//        if !FileRowView.shouldHandleTracking { return }
//        isFocused = false
//        display()
//    }
    
//    override func drawBackground(in dirtyRect: NSRect) {
//        super.drawBackground(in: dirtyRect)
//        if !isFocused {
//            return
//        }
//        
//        NSColor(hex: 0x2C2C2C).setFill()
//        let hoverPath = NSBezierPath(roundedRect: dirtyRect, xRadius: 10, yRadius: 10)
//        hoverPath.fill()
//    }
    
    private func getMenu() -> NSMenu? {
        guard let fileData = data else { return nil }
        let menu = NSMenu()
        var menuItems = [MenuItemModel]()
        if fileData.isDir {
            
        } else {
            menuItems.append(MenuItemModel(title: "下载", action: #selector(downloadFile), target: self))
            #if DEBUG
            menuItems.append(MenuItemModel(title: "拷贝下载链接", action: #selector(copyDownloadLink), target: self))
            #endif
        }
        menuItems.append(MenuItemModel(title: "新建文件夹", action: #selector(createFolder), target: self))
        menuItems.append(MenuItemModel(title: "重命名", action: #selector(renameFile), target: self))
        menuItems.append(MenuItemModel(title: "上传文件到当前目录", action: #selector(uploadFile), target: self))
//        menuItems.append(MenuItemModel(title: "移动", action: #selector(moveFile), target: self))
//        menuItems.append(MenuItemModel(title: "复制", action: #selector(copyFile), target: self))
        menuItems.append(MenuItemModel(title: "放入回收站", action: #selector(trashFile), target: self))
        menuItems.append(MenuItemModel(title: "直接删除", action: #selector(deleteFile), target: self))
        var itemWidth = 0.0
        menuItems.forEach { item in
            let attributedString = NSAttributedString(string: item.title, attributes: [
                NSAttributedString.Key.font: NSFont(PingFang: 16) as Any
            ])
            itemWidth = max(itemWidth, attributedString.size().width + 28)
        }
        menuItems.forEach { item in
            menu.addItem(ZigMenuItem(title: item.title, target: item.target, action: item.action, keyEquivalent: "", itemWidth: itemWidth))
        }
        menu.delegate = self
        return menu
    }
    
    override func rightMouseDown(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            contentView.layer?.backgroundColor = NSColor(hex: 0x2C2C2C, alpha: 1).cgColor
        })
        
        super.rightMouseDown(with: event)
    }
    
    func fadeAnimation() {
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            contentView.layer?.backgroundColor = NSColor(hex: 0x2C2C2C, alpha: 0).cgColor
        })
    }
}

extension FileRowView: NSMenuDelegate {
    
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if let last = lastHighligtItem {
            last.zig_isHiglight = false
        }
        
        if let zigMenuItem = item as? ZigMenuItem {
            zigMenuItem.zig_isHiglight = true
            lastHighligtItem = zigMenuItem
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        self.fadeAnimation()
    }
    
}
