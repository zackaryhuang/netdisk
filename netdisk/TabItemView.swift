//
//  TabItemView.swift
//  netdisk
//
//  Created by Zackary on 2023/9/3.
//

import Cocoa
import SnapKit

protocol TabItemViewDelegate: NSObjectProtocol {
    func didClickTabView(tabView: TabItemView)
}

enum TabType {
    case files
    case search
    case trans
}

class TabItemView: NSView {

    let imageView = NSImageView()
    
    weak var delegate: TabItemViewDelegate?
    
    var type: MainCategoryType!
    
    let backgroundView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 5
        view.layer?.backgroundColor = NSColor(hex: 0x3A3A3F).cgColor
        view.isHidden = true
        return view
    }()
    
    var isSelected: Bool = false {
        didSet {
            self.backgroundView.isHidden = !isSelected
        }
    }
    
    let titleLabel = {
        let label = NSTextField()
        label.isBordered = false
        label.isSelectable = false
        label.isEditable = false
        label.alignment = .center
        label.backgroundColor = .clear
        label.font = NSFont(LXGWBoldSize: 14)
        return label
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    convenience init(image: String, type: MainCategoryType, delegate: TabItemViewDelegate?) {
        self.init(frame: .zero)
        imageView.image = NSImage(named: image)
        titleLabel.stringValue = type.rawValue
        self.type = type
        self.delegate = delegate
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(NSEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(10)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.delegate?.didClickTabView(tabView: self)
    }
}
