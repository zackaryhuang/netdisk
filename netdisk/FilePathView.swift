//
//  FilePathView.swift
//  netdisk
//
//  Created by Zackary on 2023/9/3.
//

import Cocoa

protocol FilePathViewDelegate: NSObjectProtocol {
    func didClickPath(path: String)
}

class FilePathView: NSView {
    
    weak var delegate: FilePathViewDelegate?
    
    var path: String? {
        didSet {
            updateUI()
        }
    }
    
    var paths = [PathItem]()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getFixedPaths( items: inout [PathItem]) {
        var totalWidth = 0.0
        var hasIgnoredItem = false
        for (index,value) in items.enumerated() {
            if value.shouldIgnore == true {
                hasIgnoredItem = true
                continue
            }
            if index != 0 {
                totalWidth += 24.0
            }
            
            let attributedTitle = NSAttributedString(string: String(value.pathUnit), attributes: [
                NSAttributedString.Key.foregroundColor : NSColor.gray,
                NSAttributedString.Key.font : NSFont(PingFang: 16) as Any
            ])
            totalWidth += attributedTitle.size().width
        }
        
        if hasIgnoredItem {
            let attributedTitle = NSAttributedString(string: String("..."), attributes: [
                NSAttributedString.Key.foregroundColor : NSColor.gray,
                NSAttributedString.Key.font : NSFont(PingFang: 16) as Any
            ])
            totalWidth += 24
            totalWidth += attributedTitle.size().width
        }
        
        if (totalWidth + 11) > self.frame.size.width {
            for item in items[1...] {
                if item.shouldIgnore == false {
                    item.shouldIgnore = true
                    break
                }
            }
            getFixedPaths(items: &items)
        }
    }
    
    func updateUI() {
        guard let realPath = path else {
            return
        }
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        var temp = realPath.split(separator: "/")
        temp.insert("我的网盘", at:  0)
        var pathItems = [PathItem]()
        temp.forEach { subString in
            pathItems.append(PathItem(pathUnit: String(subString), shouldIgnore: false))
        }

        getFixedPaths(items: &pathItems)
        
        paths.removeAll()
        var lastView: NSView? = nil
        var ignoredItemSettled = false
        for (index,value) in pathItems.enumerated() {
            paths.append(value)
            if value.shouldIgnore == true && ignoredItemSettled {
                continue
            }
            if index != 0 {
                let imageView = NSImageView(image: NSImage(named: "icon_arrow_right")!)
                addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.leading.equalTo(lastView?.snp.trailing ?? self)
                    make.width.height.equalTo(24)
                    make.centerY.equalTo(self)
                }
                lastView = imageView
            }
            var stringValue = value.pathUnit
            if value.shouldIgnore == true
                && (index + 1 < pathItems.count)
                && pathItems[index + 1].shouldIgnore == false
                && !ignoredItemSettled {
                stringValue = "..."
                ignoredItemSettled = true
            }
            let button = NSButton(title: String(stringValue), target: self, action: #selector(buttonClick(_:)))
            button.attributedTitle = NSAttributedString(string: String(stringValue), attributes: [
                NSAttributedString.Key.font : NSFont(PingFang: 16) as Any
            ])
            button.isBordered = false
            self.addSubview(button)
            button.tag = index
            button.snp.makeConstraints { make in
                if lastView == nil {
                    make.leading.equalTo(self).offset(10)
                } else {
                    make.leading.equalTo(lastView!.snp.trailing)
                }
                make.top.bottom.equalTo(self)
                make.width.equalTo(button.attributedTitle.size().width)
            }
            lastView = button
        }
        
        if let lastButton = lastView as? NSButton {
            lastButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
            lastButton.snp.makeConstraints { make in
                make.trailing.lessThanOrEqualTo(self).offset(-10)
            }
            lastButton.attributedTitle = NSAttributedString(string: String(lastButton.attributedTitle.string), attributes: [
                NSAttributedString.Key.foregroundColor : NSColor.white,
                NSAttributedString.Key.font : NSFont(PingFang: 16) as Any
            ])
        }
    }
    
    @objc func buttonClick(_ sender: AnyObject) {
        if let button = sender as? NSButton {
            if button.tag == 0 {
                self.delegate?.didClickPath(path: "/")
            } else {
                let path = paths[1..<(button.tag+1)]
                var originPath = [String]()
                path.forEach { item in
                    originPath.append(item.pathUnit)
                }
                debugPrint("/" + originPath.joined(separator: "/"))
                self.delegate?.didClickPath(path: "/" + originPath.joined(separator: "/"))
            }
        }
    }
}

class PathItem {
    let pathUnit: String
    var shouldIgnore: Bool?
    
    init(pathUnit: String, shouldIgnore: Bool? = nil) {
        self.pathUnit = pathUnit
        self.shouldIgnore = shouldIgnore
    }
}
