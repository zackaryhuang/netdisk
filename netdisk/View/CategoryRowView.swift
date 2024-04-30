//
//  CategoryTableRowView.swift
//  netdisk
//
//  Created by Zackary on 2023/9/3.
//

import Cocoa

//protocol CategoryTableRowViewDelegate: NSObjectProtocol {
//    func didClickCategoryView(categoryView: CategoryItemView)
//}

class CategoryRowView: NSTableRowView {

//    weak var delegate: CategoryItemViewDelegate?
    var categoryItem: CategoryItem?
    
    let imageView = NSImageView()
    let titleLabel = {
        let label = NSTextField()
        label.drawsBackground = false
        label.isSelectable = false
        label.isBordered = false
        label.font = NSFont(PingFang: 16)
        label.textColor = NSColor.white
        return label
    }()
    
    let backgroundView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 5
        view.layer?.backgroundColor = NSColor(hex: 0x3A3A3F).cgColor
        view.isHidden = true
        return view
    }()
    
//    var isSelected: Bool = false {
//        didSet {
//            self.backgroundView.isHidden = !isSelected
//        }
//    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
//    convenience init(image: String, title: String, delegate: CategoryItemViewDelegate?) {
//        self.init(frame: .zero)
//        imageView.image = NSImage(named: image)
//        titleLabel.stringValue = title
////        self.delegate = delegate
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.leading.equalTo(self).offset(20)
            make.centerY.equalTo(self)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualTo(self).offset(-10)
            make.centerY.equalTo(self)
        }
    }
    
    func updateCategoryRowView(with item: CategoryItem) {
        categoryItem = item
        imageView.image = NSImage(named: item.image)
        titleLabel.stringValue = item.title
        backgroundView.isHidden = !item.isSelected
    }
    
}

class CategoryItem {
    var image: String
    var title: String
    var isSelected: Bool
    var type: CategoryType
    init(image: String, title: String, isSelected: Bool, type: CategoryType) {
        self.image = image
        self.title = title
        self.isSelected = isSelected
        self.type = type
    }
}
