//
//  UploadRowView.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/23.
//

import Cocoa

class UploadRowView: NSTableRowView {

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
    
    var task: ABUploadTask?
    
    let startButton = {
        let btn = HoverButton(normalImage: NSImage(named: "btn_resume_trans"), hoveredImage: NSImage(named: "btn_resume_trans_hover"))
        btn.isBordered = false
        btn.tip = " 开始上传"
        btn.contentTintColor = .white
        btn.isHidden = true
        return btn
    }()
    
    let cancelButton = {
        let btn = HoverButton(normalImage: NSImage(named: "btn_cancel_trans"), hoveredImage: NSImage(named: "btn_cancel_trans_hover"))
        btn.isBordered = false
        btn.tip = "取消上传"
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
        cancelButton.action = #selector(cancelUpload)
        firstColumn.addSubview(cancelButton)
        
        startButton.target = self
        startButton.action = #selector(startUpload)
        firstColumn.addSubview(startButton)
        
        deleteButton.target = self
        deleteButton.action = #selector(deleteRecord)
        firstColumn.addSubview(deleteButton)
        
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
    
    @objc func cancelUpload() {
        if let task = self.task {
            guard let contentView = self.window?.contentView else { return }
            let alertView = ZigTextAlertView(title: "取消任务", message: "确定要取消此上传任务吗?")
            alertView.confirmBlock = {
                UploadManager.shared.removeTask(task: task)
            }
            alertView.showInView(contentView)
        }
    }
    
    @objc func startUpload() {
        if let task = self.task {
            task.start()
        }
    }
    
    @objc func retryUpload() {
        guard let task = task else { return }
        task.start()
    }
    
    @objc func deleteRecord() {
        guard let task = task else { return }
        UploadManager.shared.removeTask(task: task)
    }
    
    @objc func showInFinder() {
//        guard let task = self.task, let finderURL = URL(string: "file://" + task.filepa) else { return }
//
//        if FileManager.default.fileExists(atPath: url) {
//            NSWorkspace.shared.activateFileViewerSelecting([finderURL])
//        } else {
//            guard let contentView = self.window?.contentView else { return }
//            let alertView = ZigTextAlertView(title: "文件不存在", message: "当前文件已被删除或移动至其他目录，是否删除记录?")
//            alertView.confirmBlock = { [weak self] in
//                guard let self = self else { return }
//                ZigDownloadManager.shared.downloadSessionManager.remove(self.task!)
//                UploadManager.shared.removeTask(task: task)
//            }
//            alertView.showInView(contentView)
//        }
    }
    
    func updateRowView(with task: ABUploadTask) {
        self.task = task
        imageView.image = Utils.thumbForFile(fileName: task.filePath.lastPathComponent)
        fileNameLabel.stringValue = task.filePath.lastPathComponent
        let downloadedSize = Double(task.fileSize) * task.progress.fractionCompleted
        let totalSize = task.fileSize
        fileSizeLabel.stringValue = "\(downloadedSize.decimalSizeString) / \(Double(totalSize).decimalSizeString)"
        
        updateStatus()
        
        if task.state == .running {
//            task.progressHandler { [weak self] progress in
//                guard let self = self else { return }
//                let downloadedSize = task.progress.completedUnitCount
//                let totalSize = task.progress.totalUnitCount
//                self.downloadStatueLabel.stringValue = task.speedString
//                self.fileSizeLabel.stringValue = "\(Double(downloadedSize).binarySizeString) / \(Double(totalSize).binarySizeString)"
//                progressView.doubleValue = task.progress.fractionCompleted
//            }
            task.progressHandler = { [weak self] progress in
                guard let self = self else { return }
                let downloadedSize = progress.fractionCompleted * Double(totalSize)
                self.downloadStatueLabel.stringValue = "\((task.speed).decimalSizeString) / s"
                self.fileSizeLabel.stringValue = "\(downloadedSize.decimalSizeString) / \(Double(totalSize).decimalSizeString)"
                progressView.doubleValue = progress.fractionCompleted
            }
        } else {
            progressView.doubleValue = task.progress.fractionCompleted
        }
        
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(CIColor(color: task.state == .running ? NSColor(hex: 0x0F6FE3) : NSColor(hex: 0x6F6F71)), forKey: "inputColor0")
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
        
        if !startButton.isHidden {
            startButton.snp.remakeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalTo(firstColumn)
                make.trailing.equalTo(attribute).offset(offset)
            }
            
            attribute = startButton.snp.leading
        }
        
        if !cancelButton.isHidden {
            cancelButton.snp.remakeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalTo(firstColumn)
                make.trailing.equalTo(attribute).offset(offset)
            }
            
            attribute = cancelButton.snp.leading
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
        
        cancelButton.isHidden = true
        showInFinderButton.isHidden = true
        retryButton.isHidden = true
        deleteButton.isHidden = true
    }
    
    func updateStatus() {
        guard let task = self.task else { return }
        switch task.state {
        case .failed:
            downloadStatueLabel.stringValue = "失败"
        case .waiting:
            downloadStatueLabel.stringValue = "等待上传"
        case .running:
            downloadStatueLabel.stringValue = "\((task.speed).decimalSizeString) / s"
        case .succeeded:
            downloadStatueLabel.stringValue = "已完成"
        case .canceled:
            downloadStatueLabel.stringValue = "已取消"
        }
        updateButtonStatus()
    }
    
    func updateButtonStatus() {
        guard let task = task else { return }
        switch task.state {
        case .failed:
            cancelButton.isHidden = true
            deleteButton.isHidden = false
            retryButton.isHidden = false
            showInFinderButton.isHidden = true
            startButton.isHidden = false
        case .waiting:
            cancelButton.isHidden = false
            deleteButton.isHidden = true
            retryButton.isHidden = true
            showInFinderButton.isHidden = true
            startButton.isHidden = false
        case .running:
            cancelButton.isHidden = false
            deleteButton.isHidden = true
            retryButton.isHidden = true
            showInFinderButton.isHidden = true
            startButton.isHidden = true
        case .succeeded:
            cancelButton.isHidden = true
            deleteButton.isHidden = false
            retryButton.isHidden = true
            showInFinderButton.isHidden = true
            startButton.isHidden = true
        case .canceled:
            cancelButton.isHidden = true
            showInFinderButton.isHidden = true
            deleteButton.isHidden = false
            retryButton.isHidden = false
            startButton.isHidden = false
        }
    }
    
}
