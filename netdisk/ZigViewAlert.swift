//
//  ZigViewAlert.swift
//  netdisk
//
//  Created by Zackary on 2024/4/11.
//

import Cocoa

class ZigViewAlert: NSView {
    
    var confirmBlock: ((String?) -> ())?
    
    let contentView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x252528).cgColor
        view.layer?.cornerRadius = 13
        return view
    }()
    
    var inputView: ZigTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.0).cgColor
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(342)
            make.height.equalTo(364)
            make.center.equalTo(self)
        }
        
        let label = ZigLabel()
        label.stringValue = "新建文件夹"
        label.font = NSFont(PingFangSemiBold: 17)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(20)
            make.top.equalTo(contentView).offset(19)
        }
        
        let topSepLine = NSView()
        topSepLine.wantsLayer = true
        topSepLine.layer?.backgroundColor = NSColor(hex: 0x37373B).cgColor
        contentView.addSubview(topSepLine)
        topSepLine.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.top.equalTo(label.snp.bottom).offset(19)
            make.height.equalTo(1)
        }
        
        let iconImageView = NSImageView()
        iconImageView.image = NSImage(named: "icon_create_folder")
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(108)
            make.centerX.equalTo(contentView)
            make.top.equalTo(topSepLine.snp.bottom).offset(42)
        }
        
        let inputTextfield = ZigTextField()
        inputTextfield.cell?.wraps = false
        inputTextfield.cell?.isScrollable = true
        inputTextfield.cell?.isEditable = true
        inputTextfield.focusRingType = .none
        inputTextfield.currentEditor()?.selectAll(nil)
        inputTextfield.stringValue = "新建文件夹"
        inputTextfield.cell?.font = NSFont(PingFang: 17)
        inputTextfield.wantsLayer = true
        inputTextfield.layer?.cornerRadius = 9
        inputTextfield.layer?.borderColor = NSColor(hex: 0x5D6FFF).cgColor
        inputTextfield.layer?.borderWidth = 1
        contentView.addSubview(inputTextfield)
        inputTextfield.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.bottom.equalTo(contentView).offset(-91)
            make.height.equalTo(42)
            
        }
        
        inputView = inputTextfield
        
        
        let bottomSepLine = NSView()
        bottomSepLine.wantsLayer = true
        bottomSepLine.layer?.backgroundColor = NSColor(hex: 0x37373B).cgColor
        contentView.addSubview(bottomSepLine)
        bottomSepLine.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-72)
            make.height.equalTo(1)
        }
        
        let confirmButton = NSButton(title: "确认", target: self, action: #selector(confirmBtnClick))
        confirmButton.stringValue = "确认"
        confirmButton.bezelStyle = .smallSquare
        confirmButton.font = NSFont(PingFang: 14)
        confirmButton.wantsLayer = true
        confirmButton.layer?.backgroundColor = NSColor(hex: 0x5D6FFF).cgColor
        confirmButton.layer?.cornerRadius = 5
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-20)
            make.bottom.equalTo(contentView).offset(-21)
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
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.0).cgColor
            self.contentView.alphaValue = 0
        }) {
            self.removeFromSuperview()
        }
    }
    
    @objc func confirmBtnClick() {
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.0).cgColor
            self.contentView.alphaValue = 0
        }) { [self] in
            confirmBlock?(inputView.stringValue)
            self.removeFromSuperview()
        }
    }
    
    func showInView(_ view: NSView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.5).cgColor
            self.contentView.alphaValue = 1
        }, completionHandler:nil)
    }
}
