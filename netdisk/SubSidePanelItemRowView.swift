//
//  SubSidePanelItemRowView.swift
//  netdisk
//
//  Created by Zackary on 2024/3/24.
//

import Cocoa
import SnapKit

enum SubSidePanelItemType {
    case backupDrive
    case resourceDrive
    case upload
    case download
}

class SubSidePanelItem {
    let icon: String
    let title: String
    let type: SubSidePanelItemType
    var isSelected = false
    init(icon: String, title: String, type: SubSidePanelItemType, isSelected: Bool = false) {
        self.icon = icon
        self.title = title
        self.type = type
        self.isSelected = isSelected
    }
}

class SubSidePanelItemRowView: NSTableRowView {

    var item: SubSidePanelItem?
    
    let backgroundView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 5
        view.layer?.backgroundColor = NSColor(hex: 0x3A3A3F).cgColor
        view.isHidden = true
        return view
    }()
    
    let imageView = {
        let imageView = NSImageView()
        return imageView
    }()
    
    let textLabel = {
        let textfield = ZigLabel()
        textfield.font = NSFont(LXGWRegularSize: 16)
        return textfield
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configUI() {
        
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(NSEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.centerY.equalTo(self)
            make.width.height.equalTo(32)
        }
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-20)
        }
    }
    
    func updateItem(item: SubSidePanelItem) {
        self.item = item
        backgroundView.isHidden = !item.isSelected
        imageView.image = NSImage(named: item.icon)
        textLabel.stringValue = item.title
    }
    
}
