//
//  SidePanelView.swift
//  netdisk
//
//  Created by Zackary on 2023/12/26.
//

import AppKit


enum MainCategoryType: String {
    case Files = "文件"
    case Search = "搜索"
    case Trans = "传输"
}

protocol SidePanelViewDelegate: NSObjectProtocol {
    func didSelect(tab: MainCategoryType)
}

class SidePanelView: NSView {

    weak var delegate: SidePanelViewDelegate?
    
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
    }
}

extension SidePanelView: TabItemViewDelegate {
    func didClickTabView(tabView: TabItemView) {
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
