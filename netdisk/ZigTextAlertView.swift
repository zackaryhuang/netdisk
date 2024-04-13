//
//  ZigAlertView.swift
//  netdisk
//
//  Created by Zackary on 2024/4/12.
//

import Cocoa

class ZigTextAlertView: ZigBaseAlertView {

    var confirmBlock: (() -> ())?
    
    var title = "新建文件夹"
    var message = "新建文件夹"
    
    let label = ZigLabel()
    let messageLabel = ZigLabel()
    
    var inputView: ZigTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.0).cgColor
        configUI()
    }
    
    convenience init(title: String, message: String) {
        self.init(frame: NSZeroRect)
        self.title = title
        self.message = message
        self.label.stringValue = title
        self.messageLabel.stringValue = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(338)
            make.center.equalTo(self)
        }
        
        label.stringValue = title
        label.font = NSFont(PingFangSemiBold: 19)
        label.textColor = NSColor(hex: 0xFFFFFF)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(20)
            make.top.equalTo(contentView).offset(17)
        }
        
        
        messageLabel.stringValue = message
        messageLabel.maximumNumberOfLines = 0
        messageLabel.font = NSFont(PingFang: 14)
        messageLabel.textColor = NSColor(hex: 0xC3C3C5)
        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(20)
            make.top.equalTo(label.snp.bottom).offset(15)
            make.trailing.equalTo(contentView).offset(-20)
        }
        
        let confirmButton = NSButton(title: "确认", target: self, action: #selector(confirmBtnClick))
        confirmButton.stringValue = "确认"
        confirmButton.bezelStyle = .smallSquare
        confirmButton.font = NSFont(PingFang: 14)
        confirmButton.wantsLayer = true
        confirmButton.layer?.backgroundColor = NSColor(hex: 0xEE675E).cgColor
        confirmButton.layer?.cornerRadius = 5
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-20)
            make.bottom.equalTo(contentView).offset(-21)
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        let cancelButton = NSButton(title: "取消", target: self, action: #selector(cancelBtnClick))
        cancelButton.bezelStyle = .smallSquare
        cancelButton.font = NSFont(PingFang: 14)
        cancelButton.wantsLayer = true
        cancelButton.layer?.backgroundColor = NSColor(hex: 0x252528).cgColor
        cancelButton.layer?.borderColor = NSColor(hex: 0xFFFFFF, alpha: 0.5).cgColor
        cancelButton.layer?.borderWidth = 1
        cancelButton.layer?.cornerRadius = 5
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.trailing.equalTo(confirmButton.snp.leading).offset(-17)
            make.centerY.equalTo(confirmButton)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        contentView.alphaValue = 0
    }
    
    
    @objc func cancelBtnClick() {
        dismiss()
    }
    
    @objc func confirmBtnClick() {
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.0).cgColor
            self.contentView.alphaValue = 0
        }) { [self] in
            confirmBlock?()
            self.removeFromSuperview()
        }
    }
}
