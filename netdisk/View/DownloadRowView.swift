//
//  DownloadRowView.swift
//  netdisk
//
//  Created by Zackary on 2023/9/5.
//

import Cocoa
import SnapKit
import SwiftUI
import Tiercel
class DownloadRowView: NSTableRowView {
    
    static let ButtonWidth = 24
    
    let imageView = NSImageView()
    
    let contentView = {
        let contentView = NSView()
        return contentView
    }()
    
    var firstColumn: NSView!
    
    let fileNameLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.isEditable = false
        label.drawsBackground = false
        label.maximumNumberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.font = NSFont(LXGWRegularSize: 13)
        label.textColor = .white
        return label
    }()
    
    var task: DownloadTask?
    
    let pauseButton = {
        let btn = HoverButton(normalImage: NSImage(named: "btn_pause_trans"), hoveredImage: NSImage(named: "btn_pause_trans_hover"))
        btn.isBordered = false
        btn.tip = "暂停下载"
        btn.contentTintColor = .white
        btn.imagePosition = .imageOnly
        btn.isHidden = true
        return btn
    }()
    
    let resumeButton = {
        let btn = HoverButton(normalImage: NSImage(named: "btn_resume_trans"), hoveredImage: NSImage(named: "btn_resume_trans_hover"))
        btn.isBordered = false
        btn.tip = "继续下载"
        btn.contentTintColor = .white
        btn.isHidden = true
        return btn
    }()
    
    let cancelButton = {
        let btn = HoverButton(normalImage: NSImage(named: "btn_cancel_trans"), hoveredImage: NSImage(named: "btn_cancel_trans_hover"))
        btn.isBordered = false
        btn.tip = "取消下载"
        btn.contentTintColor = .white
        btn.isHidden = true
        return btn
    }()
    
    let deleteButton = {
        let btn = HoverButton(normalImage: NSImage(named: "btn_delete_record"), hoveredImage: NSImage(named: "btn_delete_record_hover"))
        btn.isBordered = false
        btn.tip = "删除记录"
        btn.contentTintColor = .white
        btn.isHidden = true
        return btn
    }()
    
    let retryButton = {
        let btn = HoverButton(normalImage: NSImage(named: "btn_retry_trans"), hoveredImage: NSImage(named: "btn_retry_trans_hover"))
        btn.isBordered = false
        btn.tip = "重试"
        btn.contentTintColor = .white
        btn.isHidden = true
        return btn
    }()
    
    let showInFinderButton = {
        let btn = HoverButton(normalImage: NSImage(named: "btn_show_in_finder"), hoveredImage: NSImage(named: "btn_show_in_finder_hover"))
        btn.isBordered = false
        btn.contentTintColor = .white
        btn.isHidden = true
        btn.tip = "在 Finder 中打开"
        return btn
    }()
    
    let fileSizeLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.isEditable = false
        label.drawsBackground = false
        label.font = NSFont(LXGWRegularSize: 13)
        label.textColor = NSColor(hex: 0xBABABB)
        return label
    }()
    
    let downloadStatueLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.isEditable = false
        label.drawsBackground = false
        label.font = NSFont(LXGWRegularSize: 13)
        label.textColor = NSColor(hex: 0xBABABB)
        return label
    }()
    
    let progressView = {
        let progress = NSProgressIndicator()
        progress.style = NSProgressIndicator.Style.bar
        progress.controlSize = .small
        progress.isIndeterminate = false
        progress.isDisplayedWhenStopped = true
        progress.minValue = 0.0
        progress.maxValue = 1.0
        progress.doubleValue = 0.8
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(CIColor(color: NSColor(hex: 0x6F6F71)), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: NSColor(hex: 0x6F6F71)), forKey: "inputColor1")
        progress.contentFilters = [colorFilter]
        return progress
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(NSEdgeInsets(top: 0, left: 41, bottom: 0, right: 41))
        }
        
        firstColumn = NSView()
        contentView.addSubview(firstColumn)
        firstColumn.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(contentView)
            make.width.equalTo(contentView).multipliedBy(0.46)
        }
        
        let secondColumn = NSView()
        contentView.addSubview(secondColumn)
        secondColumn.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.leading.equalTo(firstColumn.snp.trailing)
            make.width.equalTo(contentView).multipliedBy(0.21)
        }
        
        let thirdColumn = NSView()
        contentView.addSubview(thirdColumn)
        thirdColumn.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.leading.equalTo(secondColumn.snp.trailing)
            make.trailing.equalTo(contentView)
        }
        
        let sepLine = NSView()
        sepLine.wantsLayer = true
        sepLine.layer?.backgroundColor = NSColor(hex: 0x1A1A1C).cgColor
        contentView.addSubview(sepLine)
        sepLine.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(contentView)
            make.height.equalTo(1)
        }
        
        showInFinderButton.target = self
        showInFinderButton.action = #selector(showInFinder)
        firstColumn.addSubview(showInFinderButton)
        
        cancelButton.target = self
        cancelButton.action = #selector(cancelDownload)
        firstColumn.addSubview(cancelButton)
        
        pauseButton.target = self
        pauseButton.action = #selector(pauseDownload)
        firstColumn.addSubview(pauseButton)
        
        resumeButton.target = self
        resumeButton.action = #selector(resumeDownload)
        firstColumn.addSubview(resumeButton)
        
        deleteButton.target = self
        deleteButton.action = #selector(deleteRecord)
        firstColumn.addSubview(deleteButton)
        
        retryButton.target = self
        retryButton.action = #selector(retryDownload)
        firstColumn.addSubview(retryButton)
        
        firstColumn.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(34)
            make.centerY.equalTo(firstColumn)
            make.leading.equalTo(firstColumn).offset(22)
        }
        //
        firstColumn.addSubview(fileNameLabel)
        fileNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.centerY.equalTo(imageView)
            make.trailing.lessThanOrEqualTo(firstColumn).offset(-20)
        }
        //
        secondColumn.addSubview(fileSizeLabel)
        fileSizeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(secondColumn)
            make.centerY.equalTo(secondColumn)
        }
        //
        thirdColumn.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.height.equalTo(3)
            make.leading.equalTo(thirdColumn).offset(10)
            make.trailing.equalTo(thirdColumn)
            make.bottom.equalTo(thirdColumn).offset(-13)
        }
        
        contentView.addSubview(downloadStatueLabel)
        downloadStatueLabel.snp.makeConstraints { make in
            make.leading.equalTo(progressView)
            make.bottom.equalTo(progressView.snp.bottom).offset(-7)
        }
    }
    
    @objc func cancelDownload() {
        if let task = self.task {
            guard let contentView = self.window?.contentView else { return }
            let alertView = ZigTextAlertView(title: "取消任务", message: "确定要取消此下载任务吗?")
            alertView.confirmBlock = {
                ZigDownloadManager.shared.downloadSessionManager.remove(task)
            }
            alertView.showInView(contentView)
        }
    }
    
    @objc func retryDownload() {
        guard let task = task else { return }
        ZigFileManager.shared.retryDownload(downloadUrl: task.url.absoluteString) { error in
            guard let e = error else {
                debugPrint("正在重新下载")
                ZigDownloadManager.shared.downloadSessionManager.remove(task)
                return
            }
            
            debugPrint(e.localizedDescription)
        }
    }
    
    @objc func deleteRecord() {
        guard let task = task else { return }
        ZigDownloadManager.shared.downloadSessionManager.remove(task)
        ZigFileManager.shared.deleteDownloadRecord(identifier: task.url.absoluteString.md5)
    }
    
    @objc func pauseDownload() {
        if let task = self.task {
            ZigDownloadManager.shared.downloadSessionManager.suspend(task)
            updateRowView(with: task)
        }
    }
    
    @objc func resumeDownload() {
        if let task = self.task {
            ZigDownloadManager.shared.downloadSessionManager.start(task)
            updateRowView(with: task)
        }
    }
    
    @objc func showInFinder() {
        if let url = self.task?.filePath, let finderURL = URL(string: "file://" + url) {
            if FileManager.default.fileExists(atPath: url) {
                NSWorkspace.shared.activateFileViewerSelecting([finderURL])
            } else {
                guard let contentView = self.window?.contentView else { return }
                let alertView = ZigTextAlertView(title: "文件不存在", message: "当前文件已被删除或移动至其他目录，是否删除记录?")
                alertView.confirmBlock = { [weak self] in
                    guard let self = self else { return }
                    ZigDownloadManager.shared.downloadSessionManager.remove(self.task!)
                }
                alertView.showInView(contentView)
            }
        }
    }
    
    func updateRowView(with task: DownloadTask) {
        self.task = task
        imageView.image = Utils.thumbForFile(fileName: task.fileName)
        fileNameLabel.stringValue = task.fileName
        let downloadedSize = task.progress.completedUnitCount
        let totalSize = task.progress.totalUnitCount
        fileSizeLabel.stringValue = "\(Double(downloadedSize).decimalSizeString) / \(Double(totalSize).decimalSizeString)"
        
        updateStatus()
        
        if task.status == .running {
            task.progress { [weak self] (task) in
                guard let self = self else { return }
                let downloadedSize = task.progress.completedUnitCount
                let totalSize = task.progress.totalUnitCount
                self.downloadStatueLabel.stringValue = task.speedString
                self.fileSizeLabel.stringValue = "\(Double(downloadedSize).decimalSizeString) / \(Double(totalSize).decimalSizeString)"
                progressView.doubleValue = task.progress.fractionCompleted
            }
        } else {
            progressView.doubleValue = task.progress.fractionCompleted
        }
        
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(CIColor(color: task.status == .running ? NSColor(hex: 0x0F6FE3) : NSColor(hex: 0x6F6F71)), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: NSColor(hex: 0x6F6F71)), forKey: "inputColor1")
        progressView.contentFilters = [colorFilter]
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
        updateButtonStatus()
        var attribute = firstColumn.snp.trailing
        var offset = -16
        if !showInFinderButton.isHidden {
            showInFinderButton.snp.remakeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalTo(firstColumn)
                make.trailing.equalTo(attribute).offset(offset)
            }
            
            attribute = showInFinderButton.snp.leading
        }
        
        if !cancelButton.isHidden {
            cancelButton.snp.remakeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalTo(firstColumn)
                make.trailing.equalTo(attribute).offset(offset)
            }
            
            attribute = cancelButton.snp.leading
        }
        
        if !pauseButton.isHidden {
            pauseButton.snp.remakeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalTo(firstColumn)
                make.trailing.equalTo(attribute).offset(offset)
            }
            
            attribute = pauseButton.snp.leading
        }
        
        if !resumeButton.isHidden {
            resumeButton.snp.remakeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalTo(firstColumn)
                make.trailing.equalTo(attribute).offset(offset)
            }
            
            attribute = resumeButton.snp.leading
            offset = -16
        }
        
        if !deleteButton.isHidden {
            deleteButton.snp.remakeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalTo(firstColumn)
                make.trailing.equalTo(attribute).offset(offset)
            }
            
            attribute = deleteButton.snp.leading
            offset = -16
        }
        
        if !retryButton.isHidden {
            retryButton.snp.remakeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalTo(firstColumn)
                make.trailing.equalTo(attribute).offset(offset)
            }
            
            attribute = retryButton.snp.leading
            offset = -16
        }
        
        fileNameLabel.snp.remakeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.centerY.equalTo(imageView)
            make.trailing.lessThanOrEqualTo(attribute).offset(offset)
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        fileNameLabel.snp.remakeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.centerY.equalTo(imageView)
            make.trailing.lessThanOrEqualTo(firstColumn).offset(-20)
        }
        
        pauseButton.isHidden = true
        resumeButton.isHidden = true
        cancelButton.isHidden = true
        showInFinderButton.isHidden = true
        retryButton.isHidden = true
        deleteButton.isHidden = true
    }
    
    func updateStatus() {
        guard let task = self.task else { return }
        switch task.status {
        case .suspended:
            downloadStatueLabel.stringValue = "已暂停"
        case .failed:
            downloadStatueLabel.stringValue = "失败"
        case .waiting:
            downloadStatueLabel.stringValue = "等待下载"
        case .running:
            downloadStatueLabel.stringValue = task.speedString
        case .succeeded:
            downloadStatueLabel.stringValue = "已完成"
        case .canceled:
            downloadStatueLabel.stringValue = "已取消"
        default:
            debugPrint("【Error】错误逻辑")
        }
        
        updateButtonStatus()
    }
    
    func updateButtonStatus() {
        guard let task = task else { return }
        switch task.status {
        case .suspended:
            pauseButton.isHidden = true
            resumeButton.isHidden = false
            cancelButton.isHidden = false
            retryButton.isHidden = true
            deleteButton.isHidden = true
            showInFinderButton.isHidden = true
        case .failed:
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            cancelButton.isHidden = true
            deleteButton.isHidden = false
            retryButton.isHidden = false
            showInFinderButton.isHidden = true
        case .waiting:
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            cancelButton.isHidden = false
            deleteButton.isHidden = true
            retryButton.isHidden = true
            showInFinderButton.isHidden = true
        case .running:
            pauseButton.isHidden = false
            resumeButton.isHidden = true
            cancelButton.isHidden = false
            deleteButton.isHidden = true
            retryButton.isHidden = true
            showInFinderButton.isHidden = true
        case .succeeded:
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            cancelButton.isHidden = true
            deleteButton.isHidden = false
            retryButton.isHidden = true
            showInFinderButton.isHidden = false
        case .canceled:
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            cancelButton.isHidden = true
            showInFinderButton.isHidden = true
            deleteButton.isHidden = false
            retryButton.isHidden = false
        default:
            debugPrint("【Error】错误逻辑")
        }
    }
}

enum DownloadState: Int {
    case downloading
    case downloaded
    case failed
    case paused
    case canceled
    case pending
}
