//
//  DownloadRowView.swift
//  netdisk
//
//  Created by Zackary on 2023/9/5.
//

import Cocoa
import SnapKit

class DownloadRowView: NSTableRowView, DownloadItemDelegate {

    let imageView = NSImageView()
    
    let fileNameLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.isEditable = false
        label.drawsBackground = false
        label.font = NSFont(PingFang: 14)
        label.textColor = .white
        return label
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
        return label
    }()
    
    let progressView = {
        let progress = NSProgressIndicator()
        progress.style = .bar
        progress.isIndeterminate = false
        progress.isDisplayedWhenStopped = true
        progress.controlSize = .small
        progress.minValue = 0.0
        progress.maxValue = 1.0
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
        
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(12)
            make.trailing.equalTo(self).offset(-12)
            make.height.equalTo(4)
            make.bottom.equalTo(self).offset(-5)
        }
        
        addSubview(downloadStatueLabel)
        downloadStatueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
            make.width.equalTo(150)
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(34)
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(12)
        }
        
        addSubview(fileNameLabel)
        fileNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.top.equalTo(imageView)
            make.trailing.equalTo(downloadStatueLabel.snp.leading).offset(-20)
        }
        
        addSubview(fileSizeLabel)
        fileSizeLabel.snp.makeConstraints { make in
            make.leading.equalTo(fileNameLabel.snp.leading)
            make.bottom.equalTo(imageView)
        }
    }
    
    func updateRowView(with downloadItem: DownloadItem) {
        downloadItem.delegate = self
        imageView.image = Utils.thumbForFile(info: downloadItem.fileDetail)
        fileNameLabel.stringValue = downloadItem.fileDetail.filename ?? ""
        let downloadedSize = (Double(downloadItem.fileDetail.size ?? 0) * downloadItem.progress).binarySizeString
        fileSizeLabel.stringValue = "\(downloadedSize) / \(Double(downloadItem.fileDetail.size ?? 0).binarySizeString)"
        progressView.doubleValue = downloadItem.progress
        
        switch downloadItem.state {
        case .paused:
            downloadStatueLabel.stringValue = "已暂停"
        case .failed:
            downloadStatueLabel.stringValue = "失败"
        case .pending:
            downloadStatueLabel.stringValue = ""
        case .downloading:
            downloadStatueLabel.stringValue = "\((downloadItem.speed).binarySizeString) / s"
        case .downloaded:
            downloadStatueLabel.stringValue = "已完成"
        }
    }
    
    func stateDidUpdate(item: DownloadItem) {
        switch item.state {
        case .paused:
            downloadStatueLabel.stringValue = "已暂停"
        case .failed:
            downloadStatueLabel.stringValue = "失败"
        case .pending:
            downloadStatueLabel.stringValue = ""
        case .downloading:
            downloadStatueLabel.stringValue = "\((item.speed).binarySizeString) / s"
        case .downloaded:
            downloadStatueLabel.stringValue = "已完成"
        }
    }
    
    func progressDidUpdate(item: DownloadItem) {
        if item.state == .downloading {
            progressView.doubleValue = item.progress
            let downloadedSize = (Double(item.fileDetail.size ?? 0) * item.progress).binarySizeString
            fileSizeLabel.stringValue = "\(downloadedSize) / \(Double(item.fileDetail.size ?? 0).binarySizeString)"
            downloadStatueLabel.stringValue = "\(item.speed.binarySizeString) / s"
        }
    }
    
}

enum DownloadState {
    case downloading
    case downloaded
    case failed
    case paused
    case pending
}

protocol DownloadItemDelegate: NSObjectProtocol {
    func stateDidUpdate(item: DownloadItem)
    func progressDidUpdate(item: DownloadItem)
}

class DownloadItem {
    weak var delegate: DownloadItemDelegate?
    var fileDetail: FileDetailInfo
    var progress: Double = 0.0
    var lastTime: TimeInterval = 0.0
    var lastProgress: Double = 0.0
    var state: DownloadState = .pending
    var speed: Double = 0.0
    init(fileDetail: FileDetailInfo) {
        self.fileDetail = fileDetail
    }
}
