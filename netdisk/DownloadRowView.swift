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
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.6).cgColor
        contentView.layer?.cornerRadius = 10
        return contentView
    }()
    
    let fileNameLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.isEditable = false
        label.drawsBackground = false
        label.maximumNumberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.font = NSFont(PingFang: 14)
        label.textColor = .white
        return label
    }()
    
    var task: DownloadTask?
    
    let pauseButton = {
        let btn = NSButton()
        btn.isBordered = false
        btn.contentTintColor = .white
        btn.imagePosition = .imageOnly
        btn.image = NSImage(systemSymbolName: "pause.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        return btn
    }()
    
    let resumeButton = {
        let btn = NSButton()
        btn.isBordered = false
        btn.contentTintColor = .white
        btn.image = NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        return btn
    }()
    
    let deleteButton = {
        let btn = NSButton()
        btn.isBordered = false
        btn.contentTintColor = .white
        btn.image = NSImage(systemSymbolName: "trash.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        return btn
    }()
    
    let showInFinderButton = {
        let btn = NSButton()
        btn.isBordered = false
        btn.contentTintColor = .white
        btn.image = NSImage(systemSymbolName: "folder.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        return btn
    }()
    
    let fileSizeLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.isEditable = false
        label.drawsBackground = false
        label.font = NSFont(Menlo: 10)
        label.textColor = .white
        return label
    }()
    
    let downloadStatueLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.isEditable = false
        label.drawsBackground = false
        label.font = NSFont(Menlo: 12)
        label.textColor = .white
        label.alignment = .right
        return label
    }()
    
    let progressView = {
        let progress = NSView()
        progress.wantsLayer = true
        progress.layer?.backgroundColor = NSColor(hex: 0x32B3FB, alpha: 0.1).cgColor
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
            make.edges.equalTo(self).inset(NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(contentView)
            make.width.equalTo(CGFLOAT_MIN)
        }
        
        showInFinderButton.target = self
        showInFinderButton.action = #selector(showInFinder)
        contentView.addSubview(showInFinderButton)
        showInFinderButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-20)
            make.width.height.equalTo(Self.ButtonWidth)
            make.centerY.equalTo(contentView)
        }
        
        deleteButton.target = self
        deleteButton.action = #selector(cancelDownload)
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalTo(showInFinderButton.snp.leading).offset(-10)
            make.width.height.equalTo(Self.ButtonWidth)
            make.centerY.equalTo(contentView)
        }
        
        pauseButton.target = self
        pauseButton.action = #selector(pauseDownload)
        contentView.addSubview(pauseButton)
        pauseButton.snp.makeConstraints { make in
            make.trailing.equalTo(deleteButton.snp.leading).offset(-10)
            make.width.height.equalTo(Self.ButtonWidth)
            make.centerY.equalTo(contentView)
        }
        
        resumeButton.target = self
        resumeButton.action = #selector(resumeDownload)
        contentView.addSubview(resumeButton)
        resumeButton.snp.makeConstraints { make in
            make.trailing.equalTo(pauseButton.snp.leading).offset(-10)
            make.width.height.equalTo(Self.ButtonWidth)
            make.centerY.equalTo(contentView)
        }
        
        contentView.addSubview(downloadStatueLabel)
        downloadStatueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(resumeButton.snp.leading).offset(-20)
            make.centerY.equalTo(contentView)
            make.width.equalTo(150)
        }
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(34)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(12)
        }
        
        contentView.addSubview(fileNameLabel)
        fileNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.top.equalTo(imageView)
            make.trailing.lessThanOrEqualTo(downloadStatueLabel.snp.leading).offset(-20)
        }
        
        contentView.addSubview(fileSizeLabel)
        fileSizeLabel.snp.makeConstraints { make in
            make.leading.equalTo(fileNameLabel.snp.leading)
            make.bottom.equalTo(imageView)
        }
    }
    
    @objc func cancelDownload() {
        debugPrint("cancelDownload")
        if let task = self.task {
            ZigDownloadManager.shared.downloadSessionManager.cancel(task)
        }
        
        
    }
    
    @objc func pauseDownload() {
        if let task = self.task {
            ZigDownloadManager.shared.downloadSessionManager.suspend(task)
        }
    }
    
    @objc func resumeDownload() {
        if let task = self.task {
            ZigDownloadManager.shared.downloadSessionManager.start(task)
        }
    }
    
    @objc func showInFinder() {
        
        debugPrint(self.task?.filePath ?? "unknown destination_url")
        if let url = self.task?.filePath, let finderURL = URL(string: "file://" + url) {
            NSWorkspace.shared.activateFileViewerSelecting([finderURL])
        } else {
            let alertOption = AlertOption(title: "文件不存在", subTitle: "当前文件已被删除或移动至其他目录", leftButtonTitle: "确认", rightButtonTitle: "删除记录") { window in
                window.orderOut(nil)
            } rightActionBlock: { window in
                self.cancelDownload()
                window.orderOut(nil)
            }

            let window = AlertWindow(with: alertOption)
            window.level = .modalPanel
            window.showIn(window: self.window!)
        }
    }
    
    func updateRowView(with task: DownloadTask) {
        self.task = task
        imageView.image = Utils.thumbForFile(fileName: task.fileName)
        fileNameLabel.stringValue = task.fileName
        let downloadedSize = task.progress.completedUnitCount
        let totalSize = task.progress.totalUnitCount
        fileSizeLabel.stringValue = "\(Double(downloadedSize).binarySizeString) / \(Double(totalSize).binarySizeString)"
        
        switch task.status {
        case .suspended:
            downloadStatueLabel.stringValue = "已暂停"
            pauseButton.isHidden = true
            resumeButton.isHidden = false
            deleteButton.isHidden = false
            showInFinderButton.isHidden = true
        case .failed:
            downloadStatueLabel.stringValue = "失败"
            pauseButton.isHidden = true
            resumeButton.isHidden = false
            deleteButton.isHidden = false
            showInFinderButton.isHidden = true
        case .waiting:
            downloadStatueLabel.stringValue = "等待下载"
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            deleteButton.isHidden = true
            showInFinderButton.isHidden = true
        case .running:
            downloadStatueLabel.stringValue = task.speedString
            pauseButton.isHidden = false
            resumeButton.isHidden = true
            deleteButton.isHidden = false
            showInFinderButton.isHidden = true
        case .succeeded:
            downloadStatueLabel.stringValue = "已完成"
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            deleteButton.isHidden = false
            showInFinderButton.isHidden = false
        case .canceled:
            downloadStatueLabel.stringValue = "已取消"
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            deleteButton.isHidden = true
            showInFinderButton.isHidden = true
        default:
            debugPrint("【Error】错误逻辑")
        }
        
        var attribute = self.snp.trailing
        var offset = -20
        
        if !showInFinderButton.isHidden {
            showInFinderButton.snp.remakeConstraints { make in
                make.trailing.equalTo(attribute).offset(offset)
                make.width.height.equalTo(Self.ButtonWidth)
                make.centerY.equalTo(contentView)
            }
            attribute = showInFinderButton.snp.leading
            offset = -10
        }
        
        if !deleteButton.isHidden {
            deleteButton.snp.remakeConstraints { make in
                make.trailing.equalTo(attribute).offset(offset)
                make.width.height.equalTo(Self.ButtonWidth)
                make.centerY.equalTo(contentView)
            }
            attribute = deleteButton.snp.leading
            offset = -10
        }
        
        if !pauseButton.isHidden {
            pauseButton.snp.remakeConstraints { make in
                make.trailing.equalTo(attribute).offset(offset)
                make.width.height.equalTo(Self.ButtonWidth)
                make.centerY.equalTo(contentView)
            }
            attribute = pauseButton.snp.leading
            offset = -10
        }
        
        if !resumeButton.isHidden {
            resumeButton.snp.remakeConstraints { make in
                make.trailing.equalTo(attribute).offset(offset)
                make.width.height.equalTo(Self.ButtonWidth)
                make.centerY.equalTo(contentView)
            }
            
            attribute = resumeButton.snp.leading
            offset = -20
        }
        
        downloadStatueLabel.snp.remakeConstraints { make in
            make.trailing.equalTo(attribute).offset(offset)
            make.centerY.equalTo(contentView)
            make.width.equalTo(150)
        }
        
        if task.status == .running {
            task.progress { [weak self] (task) in
                guard let self = self else { return }
                let downloadedSize = task.progress.completedUnitCount
                let totalSize = task.progress.totalUnitCount
                self.downloadStatueLabel.stringValue = task.speedString
                self.fileSizeLabel.stringValue = "\(Double(downloadedSize).binarySizeString) / \(Double(totalSize).binarySizeString)"
                
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.25
                    context.allowsImplicitAnimation = true
                    self.progressView.snp.remakeConstraints { make in
                        make.leading.top.bottom.equalTo(self.contentView)
                        make.width.equalTo(self.contentView).multipliedBy(task.progress.fractionCompleted)
                    }
                    self.contentView.layoutSubtreeIfNeeded()
                }
            }
        } else {
            self.progressView.snp.remakeConstraints { make in
                make.leading.top.bottom.equalTo(self.contentView)
                make.width.equalTo(self.contentView).multipliedBy(task.progress.fractionCompleted)
            }
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
