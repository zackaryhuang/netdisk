//
//  MainViewController.swift
//  netdisk
//
//  Created by Zackary on 2023/8/30.
//

import Cocoa
import SnapKit
import Alamofire
import Kingfisher

enum CategoryType {
    case downloading
    case uploading
    case finishedTrans
    case files
    case photos
    case videos
    case audios
    case docs
}

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, FilePathViewDelegate, TabItemViewDelegate, NSMenuDelegate, DownloadManagerDelegate {
    
    static let pageSize = 50
    
    var fileResponse: FileResponse?
    
    var categoryFilesResponse = [CategoryType : CategoryFilesResponse]()
    
    let avatarImageView = {
        let imageView = NSImageView()
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 5;
        return imageView
    }()
    
    var currentFolderPath = "/" {
        didSet {
            filePathView.path = currentFolderPath
        }
    }
    
    var isLoadingMore = false
    
    var hasMoreData = true
    
    var imagePreviewWindowController: ImagePreviewWindowController?
    
    var currentCategoryType: CategoryType? {
        didSet {
            if currentCategoryType == .downloading ||
                currentCategoryType == .uploading ||
                currentCategoryType == .finishedTrans {
                self.fileResponse = nil
                hideFilePathView(true)
            } else if currentCategoryType == .files {
                loadFiles(with: "/") { success in
                    if success {
                        debugPrint("load files success")
                        self.currentFolderPath = "/"
                    } else {
                        debugPrint("load files failed")
                    }
                }
                hasMoreData = true
                hideFilePathView(false)
            } else if currentCategoryType == .photos || currentCategoryType == .videos || currentCategoryType == .audios || currentCategoryType == .docs {
                loadCategoryFiles { success in
                    if success {
                        debugPrint("load category files success")
                        debugPrint("load category files success")
                    } else {
                        debugPrint("load category files failed")
                    }
                }
                hasMoreData = true
                hideFilePathView(true)
            } else {
                hideFilePathView(true)
            }
            self.tableContainerView?.documentView?.scrollToBeginningOfDocument(nil)
            self.tableView.reloadData()
        }
    }
    
    var tabs: [TabItemView] = []
    
    var categoryItems = [CategoryItem(image: "icon_category_files", title: "我的网盘", isSelected: true, type: .files),
                         CategoryItem(image: "icon_category_image", title: "图片", isSelected: false, type: .photos),
                         CategoryItem(image: "icon_category_video", title: "视频", isSelected: false, type: .videos),
                         CategoryItem(image: "icon_category_audio", title: "音频", isSelected: false, type: .audios),
                         CategoryItem(image: "icon_category_doc", title: "文档", isSelected: false, type: .docs)]
    
    var transItems = [CategoryItem(image: "icon_download", title: "正在下载", isSelected: true, type: .downloading),
                      CategoryItem(image: "icon_upload", title: "正在上传", isSelected: false, type: .uploading),
                      CategoryItem(image: "icon_finished", title: "传输完成", isSelected: false, type: .finishedTrans)]
    
    var currentItems: [CategoryItem] = []
    
    let tableView = {
        let tableView = NSTableView()
        tableView.selectionHighlightStyle = .none
        tableView.wantsLayer = true
        tableView.backgroundColor = NSColor(hex: 0x121213)
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    var tableContainerView: NSScrollView?
    
    let categoryTableView = {
        let tableView = NSTableView()
        tableView.backgroundColor = NSColor(hex: 0x121213)
        tableView.selectionHighlightStyle = .none
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "CategoryColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    var categoryTableContainerView: NSScrollView?
    
    let filePathView = {
        let view = FilePathView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x121213).cgColor
        return view
    }()
    
    let usageView = {
        let view = UsageView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x111113).cgColor
        return view
    }()
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x1F1F22).cgColor
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(endScroll(_:)), name: NSScrollView.didEndLiveScrollNotification, object: nil)
        configUI()
        currentCategoryType = .files
        requestUerData()
        requestUsage()
        DownloadManager.shared.delegate = self
    }
    
    @objc func endScroll(_ notification: Notification) {
        if let offsetY = (notification.object as? NSScrollView)?.documentVisibleRect.origin.y,
           let visibleHeight = (notification.object as? NSScrollView)?.documentVisibleRect.size.height,
           let documentViewHeight = (notification.object as? NSScrollView)?.documentView?.frame.height,
           offsetY + visibleHeight == documentViewHeight {
            loadMoreData()
        }
    }
    
    func configUI() {
        view.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(38)
            make.leading.equalTo(view).offset(10)
            make.top.equalTo(view).offset(60)
        }
        
        let filesTabItem = TabItemView(image: "icon_tab_files", title: "文件", delegate: self, type: .files)
        filesTabItem.isSelected = true
        tabs.append(filesTabItem)
        view.addSubview(filesTabItem)
        filesTabItem.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.leading.equalTo(view)
            make.width.equalTo(58)
        }
        
        let searchTabItem = TabItemView(image: "icon_tab_search", title: "搜索", delegate: self, type: .search)
        tabs.append(searchTabItem)
        view.addSubview(searchTabItem)
        searchTabItem.snp.makeConstraints { make in
            make.top.equalTo(filesTabItem.snp.bottom).offset(10)
            make.leading.equalTo(view)
            make.width.equalTo(58)
        }
        
        let transTabItem = TabItemView(image: "icon_tab_trans", title: "传输", delegate: self, type: .trans)
        tabs.append(transTabItem)
        view.addSubview(transTabItem)
        transTabItem.snp.makeConstraints { make in
            make.top.equalTo(searchTabItem.snp.bottom).offset(10)
            make.leading.equalTo(view)
            make.width.equalTo(58)
        }
        
        currentItems = categoryItems
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.headerView = nil
        categoryTableView.target = self
        categoryTableView.action = #selector(didClickCategoryTableView(_:))
        
        categoryTableContainerView = NSScrollView()
        view.addSubview(categoryTableContainerView!)
        categoryTableContainerView?.backgroundColor = NSColor(hex: 0x111113)
        categoryTableContainerView?.hasVerticalScroller = false
        categoryTableContainerView?.documentView = categoryTableView
        categoryTableContainerView?.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.top.equalTo(view)
            make.width.equalTo(view).multipliedBy(1/5.0)
        }
        
        let lineView = NSView()
        lineView.wantsLayer = true
        lineView.layer?.backgroundColor = NSColor(hex: 0x272729).cgColor
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.leading.equalTo(categoryTableView.snp.trailing)
            make.top.bottom.equalTo(view)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        let fileMenu = NSMenu()
        fileMenu.delegate = self
        tableView.menu = fileMenu
        
        filePathView.delegate = self
        view.addSubview(filePathView)
        filePathView.snp.makeConstraints { make in
            make.leading.equalTo(categoryTableContainerView!.snp.trailing)
            make.top.trailing.equalTo(view)
            make.height.equalTo(40)
        }
        
        tableContainerView = NSScrollView()
        view.addSubview(tableContainerView!)
        tableContainerView?.drawsBackground = false
        tableContainerView?.hasVerticalScroller = true
        tableContainerView?.autohidesScrollers = true
        tableContainerView?.documentView = tableView
        tableContainerView?.snp.makeConstraints { make in
            make.leading.equalTo(lineView.snp.trailing)
            make.trailing.equalTo(view)
            make.top.equalTo(view).offset(40)
            make.bottom.equalTo(view)
        }
        
        view.addSubview(usageView)
        usageView.snp.makeConstraints { make in
            make.leading.equalTo(categoryTableContainerView!)
            make.trailing.equalTo(categoryTableContainerView!)
            make.top.equalTo(categoryTableContainerView!.snp.bottom)
            make.bottom.equalTo(view)
            make.height.equalTo(60)
            
        }
        
    }
    
    func hideFilePathView(_ hidden: Bool) {
        NSAnimationContext.runAnimationGroup({context in
          context.duration = 0.25
          context.allowsImplicitAnimation = true
          
            tableContainerView?.snp.remakeConstraints({ make in
                make.leading.equalTo(categoryTableContainerView!.snp.trailing)
                make.trailing.equalTo(view)
                make.top.equalTo(view).offset(hidden ? 0 : 40)
                make.bottom.equalTo(view)
            })
            filePathView.alphaValue = hidden ? 0.0 : 1.0
            
          self.view.layoutSubtreeIfNeeded()
          
        }, completionHandler:nil)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == categoryTableView {
            return currentItems.count
        }
        if currentCategoryType == .downloading {
            let downloadList = DownloadManager.shared.downloadingList + DownloadManager.shared.pendingList + DownloadManager.shared.failedList + DownloadManager.shared.pausedList
            return downloadList.count
        }
        
        if currentCategoryType == .finishedTrans {
            let downloadedList = DownloadManager.shared.downloadedList
            return downloadedList.count
        }
        
        if currentCategoryType == .photos || currentCategoryType == .videos || currentCategoryType == .docs || currentCategoryType == .audios {
            return self.categoryFilesResponse[currentCategoryType!]?.list?.count ?? 0
        }
        return fileResponse?.list?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if tableView == categoryTableView {
            var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("CategoryRowView"), owner: self)
            if rowView == nil {
                rowView = CategoryRowView()
            }
            
            let categoryItem = currentItems[row]
            (rowView as? CategoryRowView)?.updateCategoryRowView(with: categoryItem)
            return rowView as? CategoryRowView
        } else if currentCategoryType == .downloading {
            let downloadList = DownloadManager.shared.downloadingList + DownloadManager.shared.pendingList + DownloadManager.shared.failedList + DownloadManager.shared.pausedList
            if downloadList.count <= 0 || row >= downloadList.count {
                return nil
            }
            
            var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DownloadRowView"), owner: self)
            if rowView == nil {
                rowView = DownloadRowView()
            }
            
            (rowView as? DownloadRowView)?.updateRowView(with: downloadList[row])
            return rowView as? DownloadRowView
        } else if currentCategoryType == .finishedTrans {
            let downloadedList = DownloadManager.shared.downloadedList
            if downloadedList.count <= 0 {
                return nil
            }
            
            var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DownloadRowView"), owner: self)
            if rowView == nil {
                rowView = DownloadRowView()
            }
            
            
            (rowView as? DownloadRowView)?.updateRowView(with: downloadedList[row])
            return rowView as? DownloadRowView
        }
        
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("FileRowView"), owner: self)
        if rowView == nil {
            rowView = FileRowView()
        }
        if currentCategoryType == .photos || currentCategoryType == .videos || currentCategoryType == .docs || currentCategoryType == .audios {
            let fileInfo = categoryFilesResponse[currentCategoryType!]?.list![row]
            (rowView as? FileRowView)?.updateRowView(with: fileInfo)
            return (rowView as? FileRowView)
        }
        
        let fileInfo = fileResponse?.list![row]
        (rowView as? FileRowView)?.updateRowView(with: fileInfo)
        return (rowView as? FileRowView)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView == categoryTableView {
            return 60
        } 
        
        if currentCategoryType == .downloading || currentCategoryType == .uploading || currentCategoryType == .finishedTrans {
            return 60
        }
        
        return 50
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"), owner: nil)
        columnView?.focusRingType = .none
        return columnView
        
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        var temp: FileInfo? = nil
        if currentCategoryType == .files {
            temp = fileResponse?.list?[tableView.selectedRow]
        } else if currentCategoryType == .photos {
            temp = categoryFilesResponse[currentCategoryType!]?.list?[tableView.selectedRow]
        }
        guard let fileInfo = temp else {
            return
        }
        if fileInfo.isDir == 1, let folderPath = fileInfo.path {
            hasMoreData = true
            loadFiles(with: folderPath) { success in
                if success {
                    self.currentFolderPath = folderPath
                }
            }
        } else if fileInfo.category == 3 {
            requestFileDetail(with: fileInfo) { detail in
                if let detailInfo = detail {
                    let previewWindow = ImagePreviewWindowController()
                    previewWindow.detailInfo = detailInfo
                    previewWindow.window?.makeKeyAndOrderFront(nil)
                    previewWindow.window?.center()
                }
            }
        }
    }
    
    @objc func didClickCategoryTableView(_ sender: AnyObject) {
        if let categoryTableView = sender as? NSTableView {
            let index = categoryTableView.selectedRow
            for (idx, value) in currentItems.enumerated() {
                value.isSelected = idx == index
                if value.isSelected && currentCategoryType != value.type {
                    currentCategoryType = value.type
                }
            }
            categoryTableView.reloadData()
        }
        
    }
    
    
    func didClickPath(path: String) {
        currentFolderPath = path
        hasMoreData = true
        loadFiles(with: path) { success in
            if success {
                self.currentFolderPath = path
            }
        }
    }
    
    func didClickTabView(tabView: TabItemView) {
        tabs.forEach { tab in
            if tab == tabView {
                tab.isSelected = true
                switch tabView.type {
                case .trans:
                    currentItems = transItems
                default:
                    currentItems = categoryItems
                }
                currentItems.forEach { item in
                    item.isSelected = false
                }
            } else {
                tab.isSelected = false
            }
        }
        
        if let categoryItem = currentItems.first, currentCategoryType != categoryItem.type {
            categoryItem.isSelected = true
            currentCategoryType = categoryItem.type
        }
        categoryTableView.reloadData()
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = tableView.clickedRow
        if row < 0 {
            return
        }
        
        menu.removeAllItems()
        menu.addItem(NSMenuItem(title: "删除", action: #selector(deleteFile(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "重命名", action: #selector(renameFile(_:)), keyEquivalent: ""))
        
        if currentCategoryType == .files,
           let fileInfo = self.fileResponse?.list?[row], fileInfo.isDir == 1 {
            return
        }
        
        if (currentCategoryType == .videos || currentCategoryType == .photos || currentCategoryType == .audios || currentCategoryType == .docs),
           let fileInfo = self.categoryFilesResponse[currentCategoryType!]?.list?[row], fileInfo.isDir == 1 {
            return
        }
        
        menu.addItem(NSMenuItem(title: "下载", action: #selector(downloadFile(_:)), keyEquivalent: ""))
    }
    
    @objc func deleteFile(_ sender: AnyObject) {
        
    }
    
    @objc func downloadFile(_ sender: AnyObject) {
        let row = tableView.clickedRow
        if currentCategoryType == .files,
           let fileInfo = self.fileResponse?.list?[row] {
            downloadFile(with: fileInfo)
            return
        }
        
        if (currentCategoryType == .videos || currentCategoryType == .photos || currentCategoryType == .audios || currentCategoryType == .docs),
           let fileInfo = self.categoryFilesResponse[currentCategoryType!]?.list?[row]{
            downloadFile(with: fileInfo)
            return
        }
    }
    
    @objc func renameFile(_ sender: AnyObject) {
        
    }
    
    func downloadManager(fileDownloaded: DownloadItem) {
        if currentCategoryType == .downloading || currentCategoryType == .finishedTrans {
            self.tableView.reloadData()
        }
    }
}

extension MainViewController {
    func requestUsage() {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String {
            AF.request("https://pan.baidu.com/api/quota", method: .get, parameters: [
                "access_token" : accessToken
            ]).responseDecodable(of: UsageInfo.self) { response in
                if let usageInfo = response.value {
                    self.usageView.updateView(with: usageInfo)
                }
            }
        }
    }
    func downloadFile(with fileInfo: FileInfo) {
        DownloadManager.shared.download(with: fileInfo)
    }
    
    func loadCategoryFiles(completionHandler completion: @escaping ((_ success: Bool) -> Void)) {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String,
            let deviceID = UserDefaults.standard.object(forKey: "UserDeviceCode") {
            debugPrint("请求数据 0 - \(Self.pageSize)")
            var category = "3"
            if currentCategoryType == .videos {
                category = "1"
            } else if (currentCategoryType == .audios) {
                category = "2"
            } else if (currentCategoryType == .docs) {
                category = "4"
            }
            
            AF.request("https://pan.baidu.com/rest/2.0/xpan/multimedia", method: .get, parameters: [
                "method" : "categorylist",
                "access_token" : accessToken,
                "start" : 0,
                "category" : category,
                "limit" : Self.pageSize,
                "recursion" : 1,
                "device_id" : deviceID
            ], encoding: NOURLEncoding()).responseDecodable(of: CategoryFilesResponse.self) { response in
                switch response.result {
                case .success:
                    if let categoryFilesResponse = response.value {
                        if categoryFilesResponse.errno == 0 {
                            self.categoryFilesResponse[self.currentCategoryType!] = categoryFilesResponse
                            if let cnt = categoryFilesResponse.list?.count, cnt < Self.pageSize {
                                debugPrint("已无更多数据 - \(categoryFilesResponse.list?.count ?? 0)")
                                self.hasMoreData = false
                            }
                            self.tableView.reloadData()
                            completion(true)
                        } else {
                            debugPrint("error - \(categoryFilesResponse.errno!)")
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                case let .failure(err):
                    debugPrint("请求数据失败 - \(err.localizedDescription)")
                    completion(false)
                }
                
            }
        } else {
            completion(false)
        }
    }
    
    func loadFiles(with filePath: String, completionHandler completion: @escaping(_ success: Bool) -> Void) {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String {
            debugPrint("请求数据 0 - \(Self.pageSize)")
            AF.request("https://pan.baidu.com/rest/2.0/xpan/file", method: .get, parameters: [
                "method" : "list",
                "access_token" : accessToken,
                "start" : 0,
                "limit" : Self.pageSize,
                "dir" : filePath,
                "web" : 1
            ], encoding: NOURLEncoding()).responseDecodable(of: FileResponse.self) { response in
                switch response.result {
                case .success:
                    if let fileResponse = response.value {
                        if fileResponse.errno == 0 {
                            self.fileResponse = fileResponse
                            if let cnt = fileResponse.list?.count, cnt < Self.pageSize {
                                debugPrint("已无更多数据 - \(fileResponse.list?.count ?? 0)")
                                self.hasMoreData = false
                            }
                            self.tableView.reloadData()
                            completion(true)
                        } else {
                            debugPrint("error - \(fileResponse.errno!)")
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                case let .failure(err):
                    debugPrint("请求数据失败 - \(err.localizedDescription)")
                    completion(false)
                }
                
            }
        } else {
            completion(false)
        }
    }
    
    func loadMoreData() {
        if isLoadingMore || !hasMoreData {
            return
        }
        if currentCategoryType == .files {
            if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String {
                debugPrint("请求更多数据 \(self.fileResponse?.list?.count ?? 0) - \(Self.pageSize)")
                isLoadingMore = true
                AF.request("https://pan.baidu.com/rest/2.0/xpan/file", method: .get, parameters: [
                    "method" : "list",
                    "access_token" : accessToken,
                    "start" : self.fileResponse?.list?.count ?? 0,
                    "limit" : Self.pageSize,
                    "dir" : currentFolderPath,
                    "web" : 1
                ], encoding: NOURLEncoding()).responseDecodable(of: FileResponse.self) { response in
                    switch response.result {
                    case .success:
                        if let fileResponse = response.value {
                            if fileResponse.errno == 0 {
                                if let cnt = fileResponse.list?.count, cnt < Self.pageSize {
                                    debugPrint("已无更多数据")
                                    self.hasMoreData = false
                                }
                                fileResponse.list?.forEach({ fileInfo in
                                    self.fileResponse?.list?.append(fileInfo)
                                })
                                self.tableView.reloadData()
                            } else {
                                debugPrint("error - \(fileResponse.errno!)")
                            }
                        }
                    case let .failure(err):
                        debugPrint("加载更多数据错误\(err.localizedDescription)")
                    }
                    self.isLoadingMore = false
                }
            }
            return
        }
        
        if currentCategoryType == .photos || currentCategoryType == .videos || currentCategoryType == .docs || currentCategoryType == .audios {
            if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String,
                let deviceID = UserDefaults.standard.object(forKey: "UserDeviceCode") {
                debugPrint("请求更多数据 \(self.fileResponse?.list?.count ?? 0) - \(Self.pageSize)")
                isLoadingMore = true
                var category = "3"
                if currentCategoryType == .videos {
                    category = "1"
                } else if (currentCategoryType == .audios) {
                    category = "2"
                } else if (currentCategoryType == .docs) {
                    category = "4"
                }
                AF.request("https://pan.baidu.com/rest/2.0/xpan/multimedia", method: .get, parameters: [
                    "method" : "categorylist",
                    "access_token" : accessToken,
                    "start" : self.categoryFilesResponse[self.currentCategoryType!]?.list?.count ?? 0,
                    "limit" : Self.pageSize,
                    "category" : category,
                    "recursion" : 1,
                    "device_id" : deviceID
                ], encoding: NOURLEncoding()).responseDecodable(of: CategoryFilesResponse.self) { response in
                    switch response.result {
                    case .success:
                        if let categoryFilesResponse = response.value {
                            if categoryFilesResponse.errno == 0 {
                                if let cnt = categoryFilesResponse.list?.count, cnt < Self.pageSize {
                                    debugPrint("已无更多数据")
                                    self.hasMoreData = false
                                }
                                categoryFilesResponse.list?.forEach({ fileInfo in
                                    self.categoryFilesResponse[self.currentCategoryType!]?.list?.append(fileInfo)
                                })
                                self.tableView.reloadData()
                            } else {
                                debugPrint("error - \(categoryFilesResponse.errno!)")
                            }
                        }
                    case let .failure(err):
                        debugPrint("加载更多数据错误\(err.localizedDescription)")
                    }
                    self.isLoadingMore = false
                }
            }
            return
        }
        
    }
    
    func requestFileDetail(with fileInfo: FileInfo, completion: @escaping (_ detail: FileDetailInfo?) -> ()) {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String,
           let fsid = fileInfo.fsID {
            AF.request("http://pan.baidu.com/rest/2.0/xpan/multimedia", method: .get, parameters: [
                "method" : "filemetas",
                "access_token" : accessToken,
                "fsids" : "[" + String(fsid) + "]",
                "thumb" : 1,
                "dlink" : 1
            ], encoding: NOURLEncoding()).responseDecodable(of: FileDetailInfoResponse.self) { result in
                switch result.result {
                case .success:
                    if let fileDetailResponse = result.value,
                       let fileDetail = fileDetailResponse.list?.first {
                        completion(fileDetail)
                    } else {
                        completion(nil)
                    }
                case let .failure(err):
                    debugPrint("获取文件详情失败:\(String(describing: err.responseCode))\(err.localizedDescription)")
                    completion(nil)
                }
                
            }
        } else {
            completion(nil)
        }
    }
    
    func requestUerData() {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String {
            AF.request("https://pan.baidu.com/rest/2.0/xpan/nas", method: .get, parameters: ["method" : "uinfo", "access_token" : accessToken]).responseDecodable(of: BaiduUserData.self) { response in
                
                if let url_string = response.value?.avatarUrl {
                    self.avatarImageView.kf.setImage(with: URL(string: url_string)) { result in
                        switch result {
                        case .success:
                            print(response.value?.netdiskName ?? "")
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

class BaiduUserData: Codable {
    var baiduName: String?
    var netdiskName: String?
    var avatarUrl: String?
    var vipType: Int?
    var uk: Int?
    
    enum CodingKeys: String, CodingKey {
        case baiduName = "baidu_name"
        case netdiskName = "netdisk_name"
        case avatarUrl = "avatar_url"
        case vipType = "vip_type"
        case uk = "uk"
    }
}

class FileInfo: Codable {
    var fsID: UInt64?
    var path: String?
    var serverFileName: String?
    var size: Int?
    var isDir = 0
    var category: Int?
    var thumbs: [String : String]?
    var md5: String?
    
    enum CodingKeys: String, CodingKey {
        case fsID = "fs_id"
        case path = "path"
        case serverFileName = "server_filename"
        case size = "size"
        case isDir = "isdir"
        case category = "category"
        case thumbs = "thumbs"
        case md5 = "md5"
    }
}

class FileDetailInfoResponse: Codable {
    let list: [FileDetailInfo]?
}

class FileDetailInfo: Codable {
    var fsID: UInt64?
    var category: Int?
    var downloadLink: String?
    var filename: String?
    var isDir = 0
    var serverCTime: Int?
    var serverMTime: Int?
    var size: Int?
    var md5: String?
    var thumbs: [String : String]?
    var height: Int?
    var width: Int?
    
    enum CodingKeys: String, CodingKey {
        case category = "category"
        case downloadLink = "dlink"
        case filename = "filename"
        case isDir = "isdir"
        case size = "size"
        case serverCTime = "server_ctime"
        case serverMTime = "server_mtime"
        case thumbs = "thumbs"
        case height = "height"
        case width = "width"
    }
    
    init(fileInfo: FileInfo) {
        category = fileInfo.category
        filename = fileInfo.serverFileName
        isDir = fileInfo.isDir
        size = fileInfo.size
        md5 = fileInfo.md5
        thumbs = fileInfo.thumbs
        fsID = fileInfo.fsID
    }
}

class FileResponse: Codable {
    let errno: Int?
    let guideInfo: String?
    var list: [FileInfo]?
    enum CodingKeys: String, CodingKey {
        case errno = "errno"
        case guideInfo = "guide_info"
        case list = "list"
    }
}

class CategoryFilesResponse: Codable {
    let errno: Int?
    let hasMore: Int?
    var list: [FileInfo]?
    enum CodingKeys: String, CodingKey {
        case hasMore = "has_more"
        case errno = "errno"
        case list = "list"
    }
}

class UsageInfo: Codable {
    let total: Int?
    let used: Int?
    let free: Int?
    let expire: Bool?
}

public struct NOURLEncoding: ParameterEncoding {
    
    //protocol implementation
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters else { return urlRequest }
        
        guard let url = urlRequest.url else {
            throw AFError.parameterEncodingFailed(reason: .missingURL)
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
            urlComponents.percentEncodedQuery = percentEncodedQuery
            urlRequest.url = urlComponents.url
        }
        
        return urlRequest
    }
    
    //append query parameters
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    //Alamofire logic for query components handling
    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    //escaping function where we can select symbols which we want to escape
    //(I just removed + for example)
    public func escape(_ string: String) -> String {
        let generalDelimitersToEncode = "/:#[]@+" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*,;="
        
        var allowedCharacterSet = CharacterSet.urlHostAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        
        return escaped
    }
    
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
