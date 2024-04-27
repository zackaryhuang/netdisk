//
//  UploadListViewController.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/23.
//

import Cocoa

class UploadListViewController: NSViewController {

    let tableView = {
        let tableView = NSTableView()
        tableView.selectionHighlightStyle = .none
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    var tableContainerView: NSScrollView!
    
    var uploadTasks = UploadManager.shared.allUploadTask
    
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
//        tableView.target = self
//        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: UploadManager.RunningCountChangeNotificationName, object: nil)
    }
    
    @objc func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.uploadTasks = UploadManager.shared.allUploadTask
            self.tableView.reloadData()
        }
    }
    
}

extension UploadListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return uploadTasks.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DownloadRowView"), owner: self)
        if rowView == nil {
            rowView = UploadRowView()
        }
        
        if let cell = rowView as? UploadRowView {
            let tasks: [UploadTask] = uploadTasks.reversed()
            cell.updateRowView(with: tasks[row])
        }
        
        return rowView as? NSTableRowView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 52
    }
}

extension UploadListViewController: CategoryVC {
    var categoryType: SubSidePanelItemType {
        return .upload
    }
}
