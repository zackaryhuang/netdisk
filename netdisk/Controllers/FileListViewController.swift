//
//  FileListViewController.swift
//  netdisk
//
//  Created by Zackary on 2023/12/25.
//

import AppKit

protocol CategoryVC {
    var categoryType: SubSidePanelItemType { get }
    var view: NSView { get }
}

enum FileListType {
    case backup
    case resource
}

class FileListViewController: NSViewController, CategoryVC {

    var listType = FileListType.backup
    
    lazy var currentFolderPath = {
        [ABFolderPath(folderID: "root", folderName: listType == .backup ? "备份盘" : "资源库")]
    }()
    
    init(listType: FileListType) {
        super.init(nibName: nil, bundle: nil)
        self.listType = listType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tableView = {
        let tableView = NSTableView()
        tableView.selectionHighlightStyle = .none
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    lazy var filePathView = {
        let view = FilePathView(folderPaths: self.currentFolderPath)
        return view
    }()
    
    var tableContainerView: NSScrollView!
    
    var fileList: [any FileData]?
    lazy var parentFolderID = self.currentFolderPath.last!.folderID
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
        NotificationCenter.default.addObserver(self, selector: #selector(didUploadNotification(_:)), name: UploadManager.DidFinishUploadNotificationName, object: nil)
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
        
        let menu = NSMenu()
        menu.addItem(ZigMenuItem(title: "新建文件夹", target:self, action: #selector(createFolder), keyEquivalent: "", itemWidth: nil))
        tableContainerView.menu = menu
        
    }
    
    @objc func createFolder() {
        if let view = self.view.window?.contentView {
            let alert = ZigFolerEditAlterView()
            alert.showInView(view)
            alert.confirmBlock = { (name:String?) in
                if let folderName = name {
                    Task { [weak self] in
                        guard let self = self else { return }
                        if let success = try? await WebRequest.createFolder(parentFileID: self.parentFolderID, folderName: folderName), success {
                            debugPrint("创建成功")
                            self.requestFiles()
                        }
                    }
                }
            }
        }
    }
    
    private func requestFiles() {
        startMarker = nil
        Task {
            view.showHUD()
            if let fileResp = try? await WebRequest.requestFileList(startMark: startMarker, limit: 50, parentFolder: currentFolderPath.last!, listType: listType) {
                view.hideHUD()
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
            if let fileResp = try? await WebRequest.requestFileList(startMark: startMarker, limit: 50, parentFolder: self.currentFolderPath.last!, listType: listType) {
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
                guard let driveID = listType == .backup ? ZigClientManager.shared.aliUserData?.backupDriveID : ZigClientManager.shared.aliUserData?.resourceDriveID else { return }
                Task {
                    if let resp = try? await WebRequest.requestFileDetail(fileID:fileData.fileID, driveID:driveID),
                       let namePaths = resp.namePath?.split(separator: "/"),
                       let IDPath = resp.IDPath?.split(separator: "/"),
                       namePaths.count == IDPath.count {
                        var newFolderPath = [ABFolderPath]()
                        for (index, str) in namePaths.enumerated() {
                            var folderID = String(IDPath[index])
                            var folderName = String(str)
                            if folderName == "root:" {
                                folderName = currentFolderPath.first!.folderName
                            }
                            if folderID == "root:" {
                                folderID = "root"
                            }
                            newFolderPath.append(ABFolderPath(folderID: folderID, folderName: folderName))
                        }
                        currentFolderPath = newFolderPath
                        filePathView.folderPaths = currentFolderPath
                        startMarker = nil
                        fileList?.removeAll()
                        tableView.reloadData()
                        requestFiles()
                    }
                }
            } else {
                currentFolderPath.append(ABFolderPath(folderID: fileData.fileID, folderName: fileData.fileName))
                filePathView.folderPaths = currentFolderPath
                parentFolderID = fileData.fileID
                startMarker = nil
                fileList?.removeAll()
                tableView.reloadData()
                requestFiles()
            }
            
            return
        }
        
        ZigPreviewHelper.preview(fileData: fileData, driveID: listType == .backup ? ZigClientManager.shared.aliUserData?.backupDriveID : ZigClientManager.shared.aliUserData?.resourceDriveID)
    }
    
    @objc func endScroll(_ notification: Notification) {
        if let offsetY = (notification.object as? NSScrollView)?.documentVisibleRect.origin.y,
           let visibleHeight = (notification.object as? NSScrollView)?.documentVisibleRect.size.height,
           let documentViewHeight = (notification.object as? NSScrollView)?.documentView?.frame.height,
           offsetY + visibleHeight == documentViewHeight {
            requestMoreFiles()
        }
    }
    
    @objc func didUploadNotification(_ notification: Notification) {
        if let parentID = notification.object as? String,
           parentID == parentFolderID {
            requestFiles()
        }
    }
}

extension FileListViewController: NSTableViewDelegate, NSTableViewDataSource, FilePathViewDelegate {
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
            cell.delegate = self
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
        guard let driveID = ZigClientManager.shared.aliUserData?.defaultDriveID else { return }
        Task { [weak self] in
            let res = try? await WebRequest.requestFileSearch(keywords: keywords, driveID: driveID)
            if let fileList = res?.items {
                self?.fileList = fileList
                self?.tableView.reloadData()
            }
        }
    }
    
    func searchViewDidEndSearch() {
        fileList = nil
        requestFiles()
    }
    
    var categoryType: SubSidePanelItemType {
        return listType == .backup ? .backupDrive : .resourceDrive
    }
}


extension FileListViewController: FileRowViewDelegate {
    func fileRowViewDidClickTrash(fileID: String) {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        guard let contentView = self.view.window?.contentView else { return }
        let trashAlert = ZigTextAlertView(title: "放入回收站", message: "10 天内可在回收站中找回已删除文件。放入回收站的文件仍然占用云盘容量，请及时去回收站清理")
        trashAlert.confirmBlock = { [weak self] in
            guard let self = self else { return }
            ZigFileManager.shared.trash(driveID: driveID, fileID: fileID) { (success) in
                self.requestFiles()
            }
        }
        trashAlert.showInView(contentView)
    }
    
    func fileRowViewDidClickCopy(fileID: String) {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        ZigFileManager.shared.copy(driveID: driveID, fileID: fileID)
    }
    
    func fileRowViewDidClickMove(fileID: String) {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        ZigFileManager.shared.move(driveID: driveID, fileID: fileID)
    }
    
    func fileRowViewDidClickDownload(fileID: String, fileName: String) {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        ZigFileManager.shared.download(driveID: driveID, fileID: fileID, fileName: fileName) { error in
            debugPrint(error?.localizedDescription ?? "已添加至下载队列")
        }
    }
    
    func fileRowViewDidClickRename(fileID: String, originalName: String) {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        guard let contentView = self.view.window?.contentView else { return }
        let renameAlert = ZigFolerEditAlterView(title: "重命名", placeholder: originalName)
        renameAlert.confirmBlock = { [weak self] (name:String?) in
            guard let self = self else { return }
            guard let newName = name, !newName.isEmpty else { return }
            ZigFileManager.shared.rename(driveID: driveID, fileID: fileID, toName: newName) { (success) in
                if success {
                    self.requestFiles()
                } else {
                    debugPrint("文件重命名失败")
                }
            }
        }
        renameAlert.showInView(contentView)
    }
    
    func fileRowViewDidClickDelete(fileID: String) {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        guard let contentView = self.view.window?.contentView else { return }
        let deleteAlert = ZigTextAlertView(title: "删除文件", message: "确认删除吗？删除后文件不可恢复，容量空间将在一段时间后释放")
        deleteAlert.confirmBlock = {
            ZigFileManager.shared.delete(driveID: driveID, fileID: fileID)
        }
        deleteAlert.showInView(contentView)
    }
    
    func fileRowViewDidClickCopyDownloadLink(fileID: String) {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        ZigFileManager.shared.copy(driveID: driveID, fileID: fileID)
    }
    
    func fileRowViewDidClickCreateFolder() {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        guard let contentView = self.view.window?.contentView else { return }
        let renameAlert = ZigFolerEditAlterView(title: "重命名", placeholder: "新建文件夹")
        renameAlert.confirmBlock = { [weak self] (name:String?) in
            guard let self = self else { return }
            guard let folderName = name, !folderName.isEmpty else { return }
            ZigFileManager.shared.createFolder(driveID: driveID, parentFileID: self.parentFolderID, folderName: folderName) { (success) in
                if (success) {
                    self.requestFiles()
                } else {
                    debugPrint("新建文件夹失败")
                }
            }
        }
        renameAlert.showInView(contentView)
    }
    
    func fileRowViewDidClickUpload() {
        guard let driveID = listType == .backup ? ZigClientManager.backupDriveID : ZigClientManager.resourceDriveID else { return }
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.begin { [weak self] result in
            guard let filePath = openPanel.urls.first, let self = self else { return }
            ZigFileManager.shared.uploadFile(driveID: driveID, 
                                             parentFileID: self.parentFolderID,
                                             filePath: filePath) { error in
                guard let err = error else { return }
                debugPrint(err.localizedDescription)
            }
        }
    }
}
