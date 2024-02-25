//
//  AlertWindow.swift
//  netdisk
//
//  Created by Zackary on 2023/9/20.
//

import Cocoa

class AlertOption {
    let title: String
    let subTitle: String?
    let leftButtonTitle: String?
    let rightButtonTitle: String?
    let leftActionBlock: (_ window: NSWindow) -> Void
    let rightActionBlock: (_ window: NSWindow) -> Void
    init(title: String, subTitle: String?, leftButtonTitle: String?, rightButtonTitle: String?, leftActionBlock: @escaping (_: NSWindow) -> Void, rightActionBlock: @escaping (_: NSWindow) -> Void) {
        self.title = title
        self.subTitle = subTitle
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftActionBlock = leftActionBlock
        self.rightActionBlock = rightActionBlock
    }
}

class AlertWindow: NSWindow {
    
    let titleLabel = {
        let label = ZHLabel()
        label.maximumNumberOfLines = 1
        label.alignment = .center
        label.textColor = .white
        label.font = NSFont(PingFangSemiBold: 24)
        return label
    }()
    
    let subTitleLabel = {
        let label = ZHLabel()
        label.alignment = .center
        label.textColor = NSColor(hex: 0xB4B4B4)
        label.font = NSFont(PingFang: 16)
        return label
    }()
    
    let leftButton = {
        let button = NSButton()
        button.isBordered = false
        button.wantsLayer = true
        button.contentTintColor = .white
        button.layer?.cornerRadius = 15
        button.layer?.backgroundColor = NSColor(hex: 0x60605F).cgColor
        button.imagePosition = .noImage
        button.title = "确认"
        return button
    }()
    
    let rightButton = {
        let button = NSButton()
        button.isBordered = false
        button.wantsLayer = true
        button.contentTintColor = .white
        button.layer?.cornerRadius = 15
        button.layer?.backgroundColor = NSColor(hex: 0xEB7974).cgColor
        button.imagePosition = .noImage
        button.title = "删除记录"
        return button
    }()
    
    var option: AlertOption?
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        configUI()
    }
    
    convenience init(with option: AlertOption) {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 329)
        let style: NSWindow.StyleMask = [.closable, .fullSizeContentView]
        let back: NSWindow.BackingStoreType = .buffered
        
        self.init(contentRect: frame, styleMask: style, backing: back, defer: false)
        self.option = option
        self.titlebarAppearsTransparent = true
        self.backgroundColor = .clear
        self.isMovableByWindowBackground = true
        configUI()
    }
    
    func configUI() {
        self.contentView = NSView()
        if let contentV = self.contentView, 
            let alertOption = option {
            contentV.wantsLayer = true
            contentV.layer?.cornerRadius = 15
            contentV.layer?.backgroundColor = NSColor(hex: 0x272725).cgColor
            
            titleLabel.stringValue = alertOption.title
            contentV.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(contentV).offset(20)
                make.leading.equalTo(contentV).offset(30)
                make.trailing.equalTo(contentV).offset(-30)
            }
            
            var attribute = titleLabel.snp.bottom
            var offset = 20
            
            if let sub = alertOption.subTitle {
                subTitleLabel.stringValue = sub
                contentV.addSubview(subTitleLabel)
                subTitleLabel.snp.makeConstraints { make in
                    make.leading.equalTo(contentV).offset(20)
                    make.trailing.equalTo(contentV).offset(-20)
                    make.top.equalTo(attribute).offset(offset)
                }
                
                attribute = subTitleLabel.snp.bottom
                offset = 20
            }
            
            if let leftBtnTitle = alertOption.leftButtonTitle {
                leftButton.title = leftBtnTitle
                leftButton.target = self
                leftButton.action = #selector(leftButtonClick)
                contentV.addSubview(leftButton)
                leftButton.snp.makeConstraints { make in
                    make.top.equalTo(attribute).offset(offset)
                    make.leading.equalTo(contentV).offset(50)
                    make.bottom.equalTo(contentV).offset(-20)
                    make.height.equalTo(35)
                    if option?.rightButtonTitle == nil {
                        make.trailing.equalTo(contentV).offset(-50)
                    }
                }
            }
            
            if let rightBtnTitle = alertOption.rightButtonTitle {
                rightButton.title = rightBtnTitle
                rightButton.target = self
                rightButton.action = #selector(rightButtonClick)
                contentV.addSubview(rightButton)
                rightButton.snp.makeConstraints { make in
                    make.leading.equalTo(leftButton.snp.trailing).offset(20)
                    make.trailing.equalTo(contentV).offset(-50)
                    make.width.equalTo(leftButton)
                    make.top.equalTo(leftButton)
                    make.bottom.equalTo(leftButton)
                }
            }
        }
        
    }
    
    @objc private func leftButtonClick() {
        if let action = self.option?.leftActionBlock {
            action(self)
        }
    }
    
    @objc private func rightButtonClick() {
        if let action = self.option?.rightActionBlock {
            action(self)
        }
    }
    
    func showIn(window: NSWindow) {
        self.orderFront(window)
        let width = self.frame.width
        let height = self.frame.height
        
        let parent_w = window.frame.width
        let parent_h = window.frame.height
        let parent_x = window.frame.origin.x
        let parent_y = window.frame.origin.y
        
        let new_x = (parent_w - width) / 2.0 + parent_x
        let new_y = (parent_h - height) / 2.0 + parent_y
        
        self.setFrame(NSMakeRect(new_x, new_y, width, height), display: true)
    }
    
    deinit {
        debugPrint("alertWindow deinit")
    }
}
