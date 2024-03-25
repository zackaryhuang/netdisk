//
//  DownloadListViewController.swift
//  netdisk
//
//  Created by Zackary on 2024/2/21.
//

import Cocoa
import Tiercel

class DownloadListViewController: NSViewController {
    
    let tableView = {
        let tableView = NSTableView()
        tableView.selectionHighlightStyle = .none
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"))
        tableView.addTableColumn(column)
        return tableView;
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
            make.leading.top.trailing.bottom.equalTo(view)
        }
        
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(taskDidStartDownload(_:)), name: DownloadTask.runningNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: DownloadTask.didCompleteNotification, object: nil)
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
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DownloadRowView"), owner: self)
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
        return 80
    }
}

extension DownloadListViewController: CategoryVC {
    var categoryType: SubSidePanelItemType {
        return .download
    }
}
