//
//  SearchFileListViewController.swift
//  netdisk
//
//  Created by Zackary Huang on 2024/3/12.
//

import AppKit

class SearchFileListViewController: NSViewController {
    let tableView = {
        let tableView = NSTableView()
        tableView.selectionHighlightStyle = .none
        tableView.wantsLayer = true
        tableView.backgroundColor = NSColor(hex: 0x121213)
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    var tableContainerView: NSScrollView!
    
    var fileList: [any FileData]?
    
    var hasMore = true
    var isLoadingMore = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        requestFiles()
    }
    
    private func configUI() {
        tableView.focusRingType = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        tableContainerView = NSScrollView()
        view.addSubview(tableContainerView!)
        tableContainerView.focusRingType = .none
        tableContainerView.drawsBackground = false
        tableContainerView.hasVerticalScroller = true
        tableContainerView.autohidesScrollers = true
        tableContainerView.documentView = tableView
        tableContainerView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.leading.trailing.bottom.equalTo(view)
        }
    }
    
    private func requestFiles() {
        Task {
            if let fileResp = try? await WebRequest.requestFileSearch(keywords: "沙丘") {
                fileList = fileResp.items
                tableView.reloadData()
            }
        }
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        let selectedRow = tableView.selectedRow
        guard let fileData = fileList?[selectedRow] else {
            return
        }
        switch fileData.category {
        case .Picture:
            debugPrint("预览照片")
            previewImageWith(fileID: fileData.fileID)
        case .Video:
            debugPrint("预览视频")
            previewVideoWith(fileID: fileData.fileID)
        case .Audio:
            debugPrint("预览音频")
        case .Document:
            debugPrint("预览文档")
        case .Application:
            debugPrint("预览应用")
        case .Torrent:
            debugPrint("预览种子")
        case .Others:
            debugPrint("预览其他")
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

extension SearchFileListViewController: NSTableViewDelegate, NSTableViewDataSource, CategoryVC {
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
        return 60
    }
    
    var categoryType: MainCategoryType {
        return .Search
    }
    
}
