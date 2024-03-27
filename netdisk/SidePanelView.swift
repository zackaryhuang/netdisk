//
//  SidePanelView.swift
//  netdisk
//
//  Created by Zackary on 2023/12/26.
//

import AppKit


enum MainCategoryType: String {
    case Exit = "退出"
    case Files = "文件"
    case Search = "搜索"
    case Trans = "传输"
}

protocol SidePanelViewDelegate: NSObjectProtocol {
    func didSelect(tab: MainCategoryType)
}

class SidePanelView: NSView {

    weak var delegate: SidePanelViewDelegate?
    
    weak var currentAlter: NSAlert?
    
    let avatarImageView = {
        let imageView = NSImageView()
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 5;
        return imageView
    }()
    
    var tabs: [TabItemView] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(hex: 0x222226).cgColor
        addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(60)
            make.centerX.equalTo(self)
            make.width.height.equalTo(38)
        }
        
        let filesTabItem = TabItemView(image: "icon_tab_files", type: MainCategoryType.Files, delegate: self)
        filesTabItem.isSelected = true
        tabs.append(filesTabItem)
        addSubview(filesTabItem)
        filesTabItem.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.width.equalTo(58)
        }
        
        let transTabItem = TabItemView(image: "icon_tab_trans", type: MainCategoryType.Trans, delegate: self)
        tabs.append(transTabItem)
        addSubview(transTabItem)
        transTabItem.snp.makeConstraints { make in
            make.top.equalTo(filesTabItem.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.width.equalTo(58)
        }
        
        let exitTabItem = TabItemView(image: "icon_exit", type: MainCategoryType.Exit, delegate: self)
        tabs.append(exitTabItem)
        addSubview(exitTabItem)
        exitTabItem.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-20)
            make.centerX.equalTo(self)
            make.width.equalTo(58)
        }
    }
}

extension SidePanelView: TabItemViewDelegate {
    func didClickTabView(tabView: TabItemView) {
        if tabView.type == .Exit {
            let alertOption = AlertOption(title: "确认退出吗", subTitle: nil, leftButtonTitle: "确认", rightButtonTitle: "取消") { window in
                window.orderOut(nil)
                ZigClientManager.shared.clearAccessData()
            } rightActionBlock: { window in
                window.orderOut(nil)
            }
            let window = AlertWindow(with: alertOption)
            window.level = .modalPanel
            window.showIn(window: self.window!)
            return
        }
        tabs.forEach { tabItemView in
            if (tabItemView == tabView) {
                if !tabView.isSelected {
                    self.delegate?.didSelect(tab: tabView.type)
                }
                tabItemView.isSelected = true
            } else {
                tabItemView.isSelected = false
            }
        }
    }
}
