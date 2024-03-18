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
        tableView.wantsLayer = true
        tableView.backgroundColor = NSColor(hex: 0x121213)
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    var tableContainerView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            make.leading.top.trailing.bottom.equalTo(view)
        }
        
        refresh()
    }
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.refresh()
        }))
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        
    }
}

extension DownloadListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ZigDownloadManager.shared.downloadSessionManager.tasks.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DownloadRowView"), owner: self)
        if rowView == nil {
            rowView = DownloadRowView()
        }
        
        if let cell = rowView as? DownloadRowView {
            let tasks: [DownloadTask] = ZigDownloadManager.shared.downloadSessionManager.tasks.reversed()
            cell.updateRowView(with: tasks[row])
        }
        
        return rowView as? NSTableRowView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
}

extension DownloadListViewController: CategoryVC {
    var categoryType: MainCategoryType {
        return .Trans
    }
}
