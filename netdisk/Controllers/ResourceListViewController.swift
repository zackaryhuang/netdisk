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
    
    let listType: FileListType = .resource
    
    lazy var currentFolderPath = {
        [ABFolderPath(folderID: "root", folderName: listType == .backup ? "备份盘" : "资源库")]
    }()
    
    lazy var filePathView = {
        let view = FilePathView(folderPaths: currentFolderPath)
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
            if filePathView.inSearchMode {
                filePathView.endSearch()
            }
            
            currentFolderPath.append(ABFolderPath(folderID: fileData.fileID, folderName: fileData.fileName))
            filePathView.folderPaths = currentFolderPath
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
        
        ZigPreviewHelper.preview(fileData: fileData, driveID: ZigClientManager.shared.aliUserData?.resourceDriveID)
        
    }
    
    @objc func endScroll(_ notification: Notification) {
        if let offsetY = (notification.object as? NSScrollView)?.documentVisibleRect.origin.y,
           let visibleHeight = (notification.object as? NSScrollView)?.documentVisibleRect.size.height,
           let documentViewHeight = (notification.object as? NSScrollView)?.documentView?.frame.height,
           offsetY + visibleHeight == documentViewHeight {
            requestMoreFiles()
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
    
    func filePathViewPathDidChange(currentPaths: [ABFolderPath]) {
        if currentPaths.last != currentFolderPath.last {
            currentFolderPath = currentPaths
            parentFolderID = currentPaths.last!.folderID
            fileList?.removeAll()
            tableView.reloadData()
            requestFiles()
        }
    }
    
    func searchViewStartSearch(keywords: String) {
        guard let driveID = ZigClientManager.shared.aliUserData?.resourceDriveID else { return }
        Task { [weak self] in
            let res = try? await WebRequest.requestFileSearch(keywords: keywords, driveID: driveID)
            if let fileList = res?.items {
                self?.fileList = fileList
                self?.tableView.reloadData()
            }
        }
    }
    
    func searchViewDidEndSearch() {
        startMarker = nil
        fileList = nil
        requestFiles()
    }
}
