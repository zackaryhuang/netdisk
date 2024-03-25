//
//  UsageView.swift
//  netdisk
//
//  Created by Zackary on 2023/9/1.
//

import Cocoa
import SnapKit

class UsageView: NSView {
    let totalView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 2
        view.layer?.backgroundColor = NSColor(hex: 0x1A1A1C).cgColor
        return view
    }()
    
    let usedView = {
        let view = NSView()
        view.isHidden = true
        view.wantsLayer = true
        view.layer?.cornerRadius = 2
        view.layer?.backgroundColor = NSColor(hex: 0xFCA12E).cgColor
        return view
    }()
    
    let descLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.font = NSFont(PingFang: 12)
        label.textColor = .white
        label.drawsBackground = false
        label.isEditable = false
        label.stringValue = "* / *"
        return label
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        addSubview(totalView)
        totalView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(14)
            make.trailing.equalTo(self).offset(-14)
            make.height.equalTo(4)
            make.bottom.equalTo(self).offset(-10)
        }
        
        totalView.addSubview(usedView)
        usedView.snp.makeConstraints { make in
            make.edges.equalTo(totalView)
        }
        
        addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(14)
            make.trailing.equalTo(self).offset(-14)
            make.bottom.equalTo(totalView).offset(-12)
        }
    }
    
    func updateView(with usageInfo: SpaceInfo) {
        let used = usageInfo.usedSize
        let total = usageInfo.totalSize
        usedView.isHidden = false
        usedView.snp.remakeConstraints { make in
            make.leading.equalTo(totalView)
            make.top.bottom.equalTo(totalView)
            make.width.equalTo(totalView).multipliedBy(Double(used) / Double(total))
        }
        var usedString = "*"
        if used / (1024 * 1024 * 1024 * 1024) >= 1 {
            usedString = String(format: "%.2f", Double(used) / Double(1024 * 1024 * 1024 * 1024)) + " TB"
        } else if used / (1024 * 1024 * 1024) >= 1 {
            usedString = String(format: "%.2f", Double(used) / Double(1024 * 1024 * 1024)) + " GB"
        } else if used / (1024 * 1024) >= 1 {
            usedString = String(format: "%.2f", Double(used) / Double(1024 * 1024)) + " MB"
        } else if used / (1024) >= 1 {
            usedString = String(format: "%.2f", Double(used) / Double(1024)) + " KB"
        } else {
            usedString = String(format: "%.2f", Double(used) ) + " Byte"
        }
        
        var totalString = "*"
        if total / (1024 * 1024 * 1024 * 1024) >= 1 {
            totalString = String(format: "%.2f", Double(total) / Double(1024 * 1024 * 1024 * 1024)) + " TB"
        } else if total / (1024 * 1024 * 1024) >= 1 {
            totalString = String(format: "%.2f", Double(total) / Double(1024 * 1024 * 1024)) + " GB"
        } else if total / (1024 * 1024) >= 1 {
            totalString = String(format: "%.2f", Double(total) / Double(1024 * 1024)) + " MB"
        } else if total / (1024) >= 1 {
            totalString = String(format: "%.2f", Double(total) / Double(1024)) + " KB"
        } else {
            totalString = String(format: "%.2f", Double(total) ) + " Byte"
        }
        
        
        descLabel.stringValue = usedString + " / " + totalString
    }
    
}
