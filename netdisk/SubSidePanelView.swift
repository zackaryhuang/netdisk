//
//  SubSidePanelView.swift
//  netdisk
//
//  Created by Zackary on 2024/3/24.
//

import Cocoa

protocol SubSidePanelViewDelegate: NSObjectProtocol {
    func didSelect(itemType: SubSidePanelItemType)
}

class SubSidePanelView: NSView {

    weak var delegate: SubSidePanelViewDelegate?
    
    let tableView = {
        let tableView = NSTableView()
        tableView.selectionHighlightStyle = .none
        tableView.wantsLayer = true
        tableView.backgroundColor = NSColor(hex: 0x121213)
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "SubSidePanelItem"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    let usageView = UsageView()
    
    var tableContainerView: NSScrollView!
    
    var dataList = {
        var list = [SubSidePanelItem]()
        if ZigClientManager.shared.aliUserData?.backupDriveID != nil {
            list.append(SubSidePanelItem(icon: "icon_backup_drive", title: "备份盘", type: .backupDrive, isSelected: true))
        }
        
        if ZigClientManager.shared.aliUserData?.resourceDriveID != nil {
            list.append(SubSidePanelItem(icon: "icon_resource_drive", title: "资源库", type: .backupDrive, isSelected: list.count == 0))
        }
        return list
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
        tableView.reloadData()
        Task {
            if let aliSpaceInfo = try? await WebRequest.requestSpaceInfo() {
                usageView.updateView(with: aliSpaceInfo)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        tableView.focusRingType = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.target = self
        tableView.action = #selector(tableViewDoubleClick(_:))
        
        tableContainerView = NSScrollView()
        addSubview(tableContainerView!)
        tableContainerView.focusRingType = .none
        tableContainerView.drawsBackground = false
        tableContainerView.hasVerticalScroller = true
        tableContainerView.autohidesScrollers = true
        tableContainerView.documentView = tableView
        tableContainerView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(-28)
            make.leading.trailing.equalTo(self)
        }
        
        addSubview(usageView)
        usageView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(30)
            make.top.equalTo(tableContainerView.snp.bottom)
        }
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        let row = tableView.selectedRow
        for (index, item) in dataList.enumerated() {
            if index == row {
                item.isSelected = true
                continue
            }
            item.isSelected = false
        }
        tableView.reloadData()
        self.delegate?.didSelect(itemType: dataList[row].type)
    }
    
}

extension SubSidePanelView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return NSView()
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("SubSidePanelItem"), owner: self)
        if rowView == nil {
            rowView = SubSidePanelItemRowView()
        }
        
        if let cell = rowView as? SubSidePanelItemRowView {
            cell.updateItem(item: dataList[row])
        }
        
        return rowView as? NSTableRowView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 47
    }
}

extension SubSidePanelView: SidePanelViewDelegate {
    func didSelect(tab: MainCategoryType) {
        if tab == .Files {
            dataList = []
            if ZigClientManager.shared.aliUserData?.backupDriveID != nil {
                dataList.append(SubSidePanelItem(icon: "icon_backup_drive", title: "备份盘", type: .backupDrive, isSelected: true))
            }
            
            if ZigClientManager.shared.aliUserData?.resourceDriveID != nil {
                dataList.append(SubSidePanelItem(icon: "icon_resource_drive", title: "资源库", type: .backupDrive, isSelected: dataList.count == 0))
            }
            self.delegate?.didSelect(itemType: .backupDrive)
        } else {
            dataList = [SubSidePanelItem(icon: "icon_download", title: "下载", type: .download, isSelected: true),
                            SubSidePanelItem(icon: "icon_upload", title: "上传", type: .upload)]
            self.delegate?.didSelect(itemType: .download)
        }
        tableView.reloadData()
    }
}
