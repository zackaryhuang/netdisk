//
//  DownloadListViewController.swift
//  netdisk
//
//  Created by Zackary on 2024/2/21.
//

import Cocoa
import Tiercel

class DownloadListViewController: NSViewController {
    static let Identifier = NSUserInterfaceItemIdentifier("DownloadRowView")
    let tableView = {
        let tableView = NSTableView()
        tableView.style = .fullWidth
        tableView.selectionHighlightStyle = .none
        return tableView;
    }()
    
    let titleLabel = {
        let label = ZigLabel()
        label.font = NSFont(PingFangSemiBold: 18)
        label.textColor = .white
        label.stringValue = "下载"
        return label
    }()
    
    var tableContainerView: NSScrollView!
    
    var downloadTasks = ZigDownloadManager.shared.downloadSessionManager.tasks
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        let view = NSView()
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(41)
            make.top.equalTo(view).offset(34)
        }
        
        tableView.focusRingType = .none
        tableView.backgroundColor = .clear
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
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalTo(view)
        }
        
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: DownloadTask.statusDidChangeNotification, object: nil)
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        
    }
    
    @objc func taskDidStartDownload(_ notification: Notification) {
        DispatchQueue.main.async {
            if let downloadTask = notification.userInfo?.values.first as? DownloadTask {
                if !self.downloadTasks.contains(downloadTask) {
                    self.downloadTasks = ZigDownloadManager.shared.downloadSessionManager.tasks.filter({$0.status != .removed})
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.downloadTasks = ZigDownloadManager.shared.downloadSessionManager.tasks.filter({$0.status != .removed})
            self.tableView.reloadData()
        }
    }
}

extension DownloadListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return downloadTasks.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var rowView = tableView.makeView(withIdentifier: Self.Identifier, owner: self)
        if rowView == nil {
            rowView = DownloadRowView()
        }
        
        if let cell = rowView as? DownloadRowView {
            let tasks: [DownloadTask] = downloadTasks.reversed()
            cell.updateRowView(with: tasks[row])
        }
        
        return rowView as? NSTableRowView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 52
    }
}

extension DownloadListViewController: CategoryVC {
    var categoryType: SubSidePanelItemType {
        return .download
    }
}
