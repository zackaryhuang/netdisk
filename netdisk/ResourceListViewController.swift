//
//  ResourceListViewController.swift
//  netdisk
//
//  Created by Zackary on 2024/3/24.
//

import Cocoa

class ResourceListViewController: NSViewController {

    let tableView = {
        let tableView = NSTableView()
        tableView.selectionHighlightStyle = .none
        tableView.wantsLayer = true
        tableView.backgroundColor = NSColor(hex: 0x121213)
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    let filePathView = {
        let view = FilePathView()
        return view
    }()
    
    var tableContainerView: NSScrollView!
    
    var fileList: [any FileData]?
    
    var path: String?
    var parentFolderID = "root"
    var startMarker: String?
    var hasMore = true
    var isLoadingMore = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        NotificationCenter.default.addObserver(self, selector: #selector(endScroll(_:)), name: NSScrollView.didEndLiveScrollNotification, object: nil)
        requestFiles()
    }
    
    private func configUI() {
        let sepLine = NSView()
        sepLine.wantsLayer = true
        sepLine.layer?.backgroundColor = NSColor.darkGray.cgColor
        view.addSubview(sepLine)
        sepLine.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(view)
            make.width.equalTo(0.5)
        }
        
        tableView.focusRingType = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        filePathView.delegate = self
        view.addSubview(filePathView)
        filePathView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view)
            make.height.equalTo(60)
        }
        
        tableContainerView = NSScrollView()
        view.addSubview(tableContainerView!)
        tableContainerView.focusRingType = .none
        tableContainerView.drawsBackground = false
        tableContainerView.hasVerticalScroller = true
        tableContainerView.autohidesScrollers = true
        tableContainerView.documentView = tableView
        tableContainerView.snp.makeConstraints { make in
            make.top.equalTo(filePathView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view)
        }
    }
    
    private func requestFiles() {
        Task {
            let currentClient = ZigClientManager.shared.currentClient()
            if let fileResp = try? await WebRequest.requestFileList(startMark: startMarker, limit: 50, parentFolder: currentClient == .Aliyun ? parentFolderID : path ?? "/", useResourceDrive: true) {
                fileList = fileResp.fileList
                tableView.reloadData()
                if ZigClientManager.shared.currentClient() == .Aliyun {
                    startMarker = fileResp.nextMarker
                    if let marker = startMarker, !marker.isEmpty {
                        hasMore = true
                    } else {
                        hasMore = false
                    }
                } else {
                    startMarker = String(fileList?.count ?? 0)
                    if let count = fileList?.count,
                        count >= 50 {
                        hasMore = true
                    } else {
                        hasMore = false
                    }
                }
                filePathView.updateUI()
            }
        }
    }
    
    private func requestMoreFiles() {
        if !hasMore || isLoadingMore { return }
        
        isLoadingMore = true
        
        Task {
            let currentClient = ZigClientManager.shared.currentClient()
            if let fileResp = try? await WebRequest.requestFileList(startMark: startMarker, limit: 50, parentFolder: currentClient == .Aliyun ? self.parentFolderID : self.path ?? "/", useResourceDrive: true) {
                isLoadingMore = false
                
                if let list = fileResp.fileList {
                    self.fileList? += list
                    tableView.reloadData()
                }
                
                if ZigClientManager.shared.currentClient() == .Aliyun {
                    startMarker = fileResp.nextMarker
                    if let marker = startMarker, !marker.isEmpty {
                        hasMore = true
                    } else {
                        hasMore = false
                    }
                } else {
                    startMarker = String(fileList?.count ?? 0)
                    if let count = fileList?.count,
                        count >= 50 {
                        hasMore = true
                    } else {
                        hasMore = false
                    }
                }
            }
        }
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        let selectedRow = tableView.selectedRow
        guard let fileData = fileList?[selectedRow] else {
            return
        }
        if fileData.isDir {
            var currentFilePath = filePathView.filePaths
            currentFilePath.append((path: fileData.fileName, folderID: fileData.fileID))
            filePathView.filePaths = currentFilePath
            parentFolderID = fileData.fileID
            startMarker = nil
            if path == nil {
                path = "/\(fileData.fileName)"
            } else {
                path? += "/\(fileData.fileName)"
            }
            fileList?.removeAll()
            tableView.reloadData()
            requestFiles()
            return
        }
        
        ZigPreviewHelper.preview(fileData: fileData)
        
    }
    
    @objc func endScroll(_ notification: Notification) {
        if let offsetY = (notification.object as? NSScrollView)?.documentVisibleRect.origin.y,
           let visibleHeight = (notification.object as? NSScrollView)?.documentVisibleRect.size.height,
           let documentViewHeight = (notification.object as? NSScrollView)?.documentView?.frame.height,
           offsetY + visibleHeight == documentViewHeight {
            requestMoreFiles()
        }
    }
    
    private func previewImageWith(fileID: String) {
        Task {
            let fileDetail = try? await WebRequest.requestFileDetail(fileID: fileID)
            if let detailInfo = fileDetail {
                let previewWindow = ImagePreviewWindowController()
                previewWindow.detailInfo = detailInfo
                previewWindow.window?.makeKeyAndOrderFront(nil)
                previewWindow.window?.center()
            }
        }

    }
    
    private func previewVideoWith(fileID: String) {
        Task {
            if let fileInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID),
               let url = fileInfo.downloadURL?.absoluteString.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed),
               let playURL = URL(string: "iina://weblink?url=\(url)"){
                // DownloadUrl 获取的链接为原画画质
                NSWorkspace.shared.open(playURL)
            } else if let playInfo = try? await WebRequest.requestVideoPlayInfo(fileID: fileID),
                      let url = playInfo.playURL?.absoluteString.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed),
                      let playURL = URL(string: "iina://weblink?url=\(url)"){
                // 通过 PlayInfo 获取的为转码后的画质中的最好的一档画质
                NSWorkspace.shared.open(playURL)
            }
        }
    }
    
}

extension ResourceListViewController: CategoryVC {
    var categoryType: SubSidePanelItemType {
        return .resourceDrive
    }
}

extension ResourceListViewController: NSTableViewDelegate, NSTableViewDataSource, FilePathViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileList?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("FileRowView"), owner: self)
        if rowView == nil {
            rowView = FileRowView()
        }
        
        if let fileData = fileList?[row],
            let cell = rowView as? FileRowView {
            cell.updateRowView(with: fileData)
        }
        
        return rowView as? NSTableRowView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 54
    }
    
    func filePathViewPathDidChange(path: String, folderID: String?) {
        if path != self.path {
            self.path = path
            if let id = folderID {
                self.parentFolderID = id
            }
            startMarker = nil
            fileList?.removeAll()
            tableView.reloadData()
            requestFiles()
        }
    }
    
    func searchViewStartSearch(keywords: String) {
        Task { [weak self] in
            let res = try? await WebRequest.requestFileSearch(keywords: keywords)
            if let fileList = res?.items {
                self?.fileList = fileList
                self?.tableView.reloadData()
            }
        }
    }
}
