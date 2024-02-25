////
////  DownloadRowView.swift
////  netdisk
////
////  Created by Zackary on 2023/9/5.
////
//
//import Cocoa
//import SnapKit
//import SwiftUI
//class DownloadRowView: NSTableRowView, DownloadItemDelegate {
//
//    static let ButtonWidth = 24
//    
//    let imageView = NSImageView()
//    
//    let fileNameLabel = {
//        let label = NSTextField()
//        label.isBordered = false
//        label.isEditable = false
//        label.drawsBackground = false
//        label.maximumNumberOfLines = 1
//        label.lineBreakMode = .byTruncatingMiddle
//        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        label.font = NSFont(PingFang: 14)
//        label.textColor = .white
//        return label
//    }()
//    
//    var item: DownloadItem?
//    
//    let pauseButton = {
//        let btn = NSButton()
//        btn.isBordered = false
//        btn.contentTintColor = .white
//        btn.imagePosition = .imageOnly
//        btn.image = NSImage(systemSymbolName: "pause.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
//        return btn
//    }()
//    
//    let resumeButton = {
//        let btn = NSButton()
//        btn.isBordered = false
//        btn.contentTintColor = .white
//        btn.image = NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
//        return btn
//    }()
//    
//    let deleteButton = {
//        let btn = NSButton()
//        btn.isBordered = false
//        btn.contentTintColor = .white
//        btn.image = NSImage(systemSymbolName: "trash.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
//        return btn
//    }()
//    
//    let showInFinderButton = {
//        let btn = NSButton()
//        btn.isBordered = false
//        btn.contentTintColor = .white
//        btn.image = NSImage(systemSymbolName: "folder.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
//        return btn
//    }()
//    
//    let fileSizeLabel = {
//        let label = NSTextField()
//        label.isBordered = false
//        label.isEditable = false
//        label.drawsBackground = false
//        label.font = NSFont(Menlo: 10)
//        label.textColor = .white
//        return label
//    }()
//    
//    let downloadStatueLabel = {
//        let label = NSTextField()
//        label.isBordered = false
//        label.isEditable = false
//        label.drawsBackground = false
//        label.font = NSFont(Menlo: 12)
//        label.textColor = .white
//        label.alignment = .right
//        return label
//    }()
//    
//    let progressView = {
//        let progress = NSProgressIndicator()
//        progress.style = .bar
//        progress.isIndeterminate = false
//        progress.isDisplayedWhenStopped = true
//        progress.controlSize = .small
//        progress.minValue = 0.0
//        progress.maxValue = 1.0
//        return progress
//    }()
//    
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        configUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configUI() {
//        
//        addSubview(progressView)
//        progressView.snp.makeConstraints { make in
//            make.leading.equalTo(self).offset(12)
//            make.trailing.equalTo(self).offset(-12)
//            make.height.equalTo(4)
//            make.bottom.equalTo(self).offset(-5)
//        }
//        
//        showInFinderButton.target = self
//        showInFinderButton.action = #selector(showInFinder)
//        addSubview(showInFinderButton)
//        showInFinderButton.snp.makeConstraints { make in
//            make.trailing.equalTo(self).offset(-20)
//            make.width.height.equalTo(Self.ButtonWidth)
//            make.centerY.equalTo(self)
//        }
//        
//        deleteButton.target = self
//        deleteButton.action = #selector(cancelDownload)
//        addSubview(deleteButton)
//        deleteButton.snp.makeConstraints { make in
//            make.trailing.equalTo(showInFinderButton.snp.leading).offset(-10)
//            make.width.height.equalTo(Self.ButtonWidth)
//            make.centerY.equalTo(self)
//        }
//        
//        pauseButton.target = self
//        pauseButton.action = #selector(pauseDownload)
//        addSubview(pauseButton)
//        pauseButton.snp.makeConstraints { make in
//            make.trailing.equalTo(deleteButton.snp.leading).offset(-10)
//            make.width.height.equalTo(Self.ButtonWidth)
//            make.centerY.equalTo(self)
//        }
//        
//        resumeButton.target = self
//        resumeButton.action = #selector(resumeDownload)
//        addSubview(resumeButton)
//        resumeButton.snp.makeConstraints { make in
//            make.trailing.equalTo(pauseButton.snp.leading).offset(-10)
//            make.width.height.equalTo(Self.ButtonWidth)
//            make.centerY.equalTo(self)
//        }
//        
//        addSubview(downloadStatueLabel)
//        downloadStatueLabel.snp.makeConstraints { make in
//            make.trailing.equalTo(resumeButton.snp.leading).offset(-20)
//            make.centerY.equalTo(self)
//            make.width.equalTo(150)
//        }
//        
//        addSubview(imageView)
//        imageView.snp.makeConstraints { make in
//            make.width.height.equalTo(34)
//            make.centerY.equalTo(self)
//            make.leading.equalTo(self).offset(12)
//        }
//        
//        addSubview(fileNameLabel)
//        fileNameLabel.snp.makeConstraints { make in
//            make.leading.equalTo(imageView.snp.trailing).offset(12)
//            make.top.equalTo(imageView)
//            make.trailing.lessThanOrEqualTo(downloadStatueLabel.snp.leading).offset(-20)
//        }
//        
//        addSubview(fileSizeLabel)
//        fileSizeLabel.snp.makeConstraints { make in
//            make.leading.equalTo(fileNameLabel.snp.leading)
//            make.bottom.equalTo(imageView)
//        }
//    }
//    
//    @objc func cancelDownload() {
//        debugPrint("cancelDownload")
//        if let downloadOperation = self.item?.downloadOperation {
//            downloadOperation.pauseDownload()
//            return
//        }
//        
//        if let downloadItem = self.item {
//            let originalState = downloadItem.state
//            downloadItem.state = .canceled
//            downloadItem.stateObserver?.downloadItemStateDidUpdate(downloadItem: downloadItem, fromState: originalState, toState: .canceled)
//        }
//    }
//    
//    @objc func pauseDownload() {
//        self.item?.downloadOperation?.pauseDownload()
//    }
//    
//    @objc func resumeDownload() {
//        if let downloadItem = self.item {
//            DownloadManager.shared.resumeDownload(with: downloadItem)
//        }
//    }
//    
//    @objc func showInFinder() {
//        
//        debugPrint(self.item?.destinationUrl ?? "unknown destination_url")
//        if let url = self.item?.destinationUrl, let finderURL = URL(string: url) {
//            NSWorkspace.shared.activateFileViewerSelecting([finderURL])
//        } else {
//            let alertOption = AlertOption(title: "文件不存在", subTitle: "当前文件已被删除或移动至其他目录", leftButtonTitle: "确认", rightButtonTitle: "删除记录") { window in
//                window.orderOut(nil)
//            } rightActionBlock: { window in
//                self.cancelDownload()
//                window.orderOut(nil)
//            }
//
//            let window = AlertWindow(with: alertOption)
//            window.level = .modalPanel
//            window.showIn(window: self.window!)
//        }
//    }
//    
//    func updateRowView(with downloadItem: DownloadItem) {
//        self.item = downloadItem
//        downloadItem.delegate = self
//        imageView.image = Utils.thumbForFile(info: downloadItem.fileDetail)
//        fileNameLabel.stringValue = downloadItem.fileDetail.filename ?? ""
//        let downloadedSize = (Double(downloadItem.fileDetail.size ?? 0) * downloadItem.progress).binarySizeString
//        fileSizeLabel.stringValue = "\(downloadedSize) / \(Double(downloadItem.fileDetail.size ?? 0).binarySizeString)"
//        progressView.doubleValue = downloadItem.progress
//        
//        switch downloadItem.state {
//        case .paused:
//            downloadStatueLabel.stringValue = "已暂停"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = false
//            deleteButton.isHidden = false
//            showInFinderButton.isHidden = true
//        case .failed:
//            downloadStatueLabel.stringValue = "失败"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = false
//            deleteButton.isHidden = false
//            showInFinderButton.isHidden = true
//        case .pending:
//            downloadStatueLabel.stringValue = "等待下载"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = true
//            deleteButton.isHidden = true
//            showInFinderButton.isHidden = true
//        case .downloading:
//            downloadStatueLabel.stringValue = "\((downloadItem.speed).binarySizeString) / s"
//            pauseButton.isHidden = false
//            resumeButton.isHidden = true
//            deleteButton.isHidden = false
//            showInFinderButton.isHidden = true
//        case .downloaded:
//            downloadStatueLabel.stringValue = "已完成"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = true
//            deleteButton.isHidden = false
//            showInFinderButton.isHidden = false
//        case .canceled:
//            downloadStatueLabel.stringValue = "已取消"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = true
//            deleteButton.isHidden = true
//            showInFinderButton.isHidden = true
//        }
//        
//        var attribute = self.snp.trailing
//        var offset = -20
//        
//        if !showInFinderButton.isHidden {
//            showInFinderButton.snp.remakeConstraints { make in
//                make.trailing.equalTo(attribute).offset(offset)
//                make.width.height.equalTo(Self.ButtonWidth)
//                make.centerY.equalTo(self)
//            }
//            attribute = showInFinderButton.snp.leading
//            offset = -10
//        }
//        
//        if !deleteButton.isHidden {
//            deleteButton.snp.remakeConstraints { make in
//                make.trailing.equalTo(attribute).offset(offset)
//                make.width.height.equalTo(Self.ButtonWidth)
//                make.centerY.equalTo(self)
//            }
//            attribute = deleteButton.snp.leading
//            offset = -10
//        }
//        
//        if !pauseButton.isHidden {
//            pauseButton.snp.remakeConstraints { make in
//                make.trailing.equalTo(attribute).offset(offset)
//                make.width.height.equalTo(Self.ButtonWidth)
//                make.centerY.equalTo(self)
//            }
//            attribute = pauseButton.snp.leading
//            offset = -10
//        }
//        
//        if !resumeButton.isHidden {
//            resumeButton.snp.remakeConstraints { make in
//                make.trailing.equalTo(attribute).offset(offset)
//                make.width.height.equalTo(Self.ButtonWidth)
//                make.centerY.equalTo(self)
//            }
//            
//            attribute = resumeButton.snp.leading
//            offset = -20
//        }
//        
//        downloadStatueLabel.snp.remakeConstraints { make in
//            make.trailing.equalTo(attribute).offset(offset)
//            make.centerY.equalTo(self)
//            make.width.equalTo(150)
//        }
//        
//        
//    }
//    
//    func stateDidUpdate(item: DownloadItem) {
//        switch item.state {
//        case .paused:
//            downloadStatueLabel.stringValue = "已暂停"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = false
//            deleteButton.isHidden = false
//        case .failed:
//            downloadStatueLabel.stringValue = "失败"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = false
//            deleteButton.isHidden = false
//        case .pending:
//            downloadStatueLabel.stringValue = "等待下载"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = true
//            deleteButton.isHidden = true
//        case .downloading:
//            downloadStatueLabel.stringValue = "\((item.speed).binarySizeString) / s"
//            pauseButton.isHidden = false
//            resumeButton.isHidden = true
//            deleteButton.isHidden = false
//        case .downloaded:
//            downloadStatueLabel.stringValue = "已完成"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = true
//            deleteButton.isHidden = false
//        case .canceled:
//            downloadStatueLabel.stringValue = "已取消"
//            pauseButton.isHidden = true
//            resumeButton.isHidden = true
//            deleteButton.isHidden = true
//        }
//        
//        var attribute = self.snp.trailing
//        var offset = -20
//        
//        if !deleteButton.isHidden {
//            deleteButton.snp.remakeConstraints { make in
//                make.trailing.equalTo(attribute).offset(offset)
//                make.width.height.equalTo(Self.ButtonWidth)
//                make.centerY.equalTo(self)
//            }
//            attribute = deleteButton.snp.leading
//            offset = -10
//        }
//        
//        if !pauseButton.isHidden {
//            pauseButton.snp.remakeConstraints { make in
//                make.trailing.equalTo(attribute).offset(offset)
//                make.width.height.equalTo(Self.ButtonWidth)
//                make.centerY.equalTo(self)
//            }
//            attribute = pauseButton.snp.leading
//            offset = -10
//        }
//        
//        if !resumeButton.isHidden {
//            resumeButton.snp.remakeConstraints { make in
//                make.trailing.equalTo(attribute).offset(offset)
//                make.width.height.equalTo(Self.ButtonWidth)
//                make.centerY.equalTo(self)
//            }
//            
//            attribute = resumeButton.snp.leading
//            offset = -20
//        }
//        
//        downloadStatueLabel.snp.remakeConstraints { make in
//            make.trailing.equalTo(attribute).offset(offset)
//            make.centerY.equalTo(self)
//            make.width.equalTo(150)
//        }
//    }
//    
//    func progressDidUpdate(item: DownloadItem) {
//        if item.state == .downloading {
//            progressView.doubleValue = item.progress
//            let downloadedSize = (Double(item.fileDetail.size ?? 0) * item.progress).binarySizeString
//            fileSizeLabel.stringValue = "\(downloadedSize) / \(Double(item.fileDetail.size ?? 0).binarySizeString)"
//            downloadStatueLabel.stringValue = "\(item.speed.binarySizeString) / s"
//        }
//    }
//    
//}
//
//enum DownloadState: Int {
//    case downloading
//    case downloaded
//    case failed
//    case paused
//    case canceled
//    case pending
//}
//
//protocol DownloadItemDelegate: NSObjectProtocol {
//    func stateDidUpdate(item: DownloadItem)
//    func progressDidUpdate(item: DownloadItem)
//}
//
//protocol DownloadItemStateObserver: NSObjectProtocol {
//    func downloadItemStateDidUpdate(downloadItem: DownloadItem, fromState: DownloadState, toState: DownloadState)
//}
//
//class DownloadItem {
//    var resumeData: Data?
//    var destinationUrl: String?
//    var temporaryUrl: String?
//    weak var delegate: DownloadItemDelegate?
//    weak var stateObserver: DownloadItemStateObserver?
//    var fileDetail: FileDetailInfo
//    var progress: Double = 0.0
//    var lastTime: TimeInterval = 0.0
//    var lastProgress: Double = 0.0
//    var state: DownloadState = .pending
//    var speed: Double = 0.0
//    var rowIndex: Int?
//    weak var downloadOperation: DownloadOperation?
//    init(fileDetail: FileDetailInfo) {
//        self.fileDetail = fileDetail
//    }
//}
