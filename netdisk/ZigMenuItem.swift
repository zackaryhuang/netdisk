//
//  ZigMenuItem.swift
//  netdisk
//
//  Created by Zackary on 2024/4/12.
//

import Cocoa

class ZigMenuItem: NSMenuItem {
    
    var zig_isHiglight: Bool = false {
        didSet {
            if zig_isHiglight {
                if let menuItemView = self.view as? ZigMenuItemView {
                    menuItemView.contentView.layer?.backgroundColor = NSColor(hex: 0x3B3B40).cgColor
                }
            } else {
                if let menuItemView = self.view as? ZigMenuItemView {
                    menuItemView.contentView.layer?.backgroundColor = NSColor.clear.cgColor
                }
            }
        }
    }
    
    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
        configView()
    }
    
    convenience init(title string: String, target: AnyObject?, action selector: Selector?, keyEquivalent charCode: String) {
        self.init(title: string, action: selector, keyEquivalent: charCode)
        self.target = target
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configView() {
        let menuView = ZigMenuItemView(frame: NSMakeRect(0, 0, 150, 35))
        
        let label = ZigLabel()
        label.stringValue = title
        label.font = NSFont(PingFang: 16)
        label.textColor = NSColor(hex: 0xFFFFFF)
        
        menuView.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(menuView.contentView).offset(8)
            make.centerY.equalTo(menuView.contentView)
            make.trailing.equalTo(menuView.contentView).offset(-8)
        }
        
        let gest = NSClickGestureRecognizer(target: self, action: #selector(trigger))
        menuView.addGestureRecognizer(gest)
        view = menuView
    }
    
    @objc func trigger() {
        _ = target?.perform(action)
        self.menu?.cancelTracking()
    }
}


class ZigMenuItemView: NSView {
    
    var contentView: NSView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        contentView = NSView(frame: NSMakeRect(5, 0, frameRect.size.width - 10, frameRect.size.height))
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 4
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
