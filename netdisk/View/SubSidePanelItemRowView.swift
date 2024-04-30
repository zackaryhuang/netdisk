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
        view.layer?.cornerRadius = 10
        view.layer?.backgroundColor = NSColor.clear.cgColor
        return view
    }()
    
    let imageView = {
        let imageView = NSImageView()
        return imageView
    }()
    
    let textLabel = {
        let textfield = ZigLabel()
        textfield.font = NSFont(LXGWRegularSize: 14)
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
            make.edges.equalTo(self).inset(NSEdgeInsets(top: 5, left: 14, bottom: 5, right: 14))
        }
        
        backgroundView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalTo(backgroundView).offset(10)
            make.centerY.equalTo(backgroundView)
            make.width.height.equalTo(20)
        }
        
        backgroundView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(15)
            make.centerY.equalTo(backgroundView)
            make.trailing.equalTo(backgroundView).offset(-10)
        }
    }
    
    func updateItem(item: SubSidePanelItem) {
        self.item = item
        backgroundView.layer?.backgroundColor = item.isSelected ? NSColor(hex: 0x3A3A3F).cgColor : NSColor.clear.cgColor
        imageView.image = NSImage(named: item.icon)
        textLabel.stringValue = item.title
    }
    
}
