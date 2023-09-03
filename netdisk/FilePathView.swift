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
    
    var paths: [String]? = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        paths?.removeAll()
        var lastView: NSView? = nil
        for (index,value) in temp.enumerated() {
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
            
            let button = NSButton(title: String(value), target: self, action: #selector(buttonClick(_:)))
            button.isBordered = false
            button.font = NSFont(PingFang: 14)
            self.addSubview(button)
            button.tag = index
            button.snp.makeConstraints { make in
                if lastView == nil {
                    make.leading.equalTo(self).offset(10)
                } else {
                    make.leading.equalTo(lastView!.snp.trailing)
                }
                make.top.bottom.equalTo(self)
            }
            lastView = button
            paths?.append(String(value))
        }
        
        if let lastButton = lastView as? NSButton {
            lastButton.isHighlighted = true
        }
    }
    
    @objc func buttonClick(_ sender: AnyObject) {
        if let button = sender as? NSButton {
            if button.tag == 0 {
                self.delegate?.didClickPath(path: "/")
            } else if let path = paths?[1..<(button.tag+1)] {
                debugPrint("/" + path.joined(separator: "/"))
                self.delegate?.didClickPath(path: "/" + path.joined(separator: "/"))
            }
        }
    }
}
