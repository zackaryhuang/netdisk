//
//  SearchView.swift
//  netdisk
//
//  Created by Zackary on 2024/3/16.
//

import Cocoa
import SnapKit

protocol SearchViewDelegate: NSObjectProtocol {
    func searchViewDidEndEditing()
    func searchViewStartSearch(keywords: String)
}

class SearchView: NSView {
    var imageView: NSImageView!
    var label: ZigLabel!
    var searchTextField: NSTextField!
    weak var delegate: SearchViewDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        imageView = NSImageView()
        imageView.image = NSImage(named: "icon_search_1")
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(5)
            make.centerY.equalTo(self)
            make.width.height.equalTo(16)
        }
        
        searchTextField = NSTextField()
        searchTextField.drawsBackground = false
        searchTextField.focusRingType = .none
        searchTextField.delegate = self
        searchTextField.isEditable = false
        searchTextField.isBordered = false
        searchTextField.maximumNumberOfLines = 1
        searchTextField.placeholderAttributedString = NSAttributedString(string: "搜索云盘内文件", attributes: [
            NSAttributedString.Key.foregroundColor : NSColor(hex: 0x6B6B6D),
            NSAttributedString.Key.font : NSFont(PingFang: 12) as Any
        ])
        
        addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(5)
            make.centerY.equalTo(imageView)
            make.trailing.equalTo(self).offset(-5)
        }
    }
}

extension SearchView: NSTextFieldDelegate {
    func controlTextDidBeginEditing(_ obj: Notification) {
        debugPrint("开始编辑")
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        debugPrint("结束编辑")
        self.delegate?.searchViewDidEndEditing()
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(insertNewline(_:))) {
            debugPrint("回车")
            if let textField = control as? NSTextField,
               !textField.stringValue.isEmpty {
                self.delegate?.searchViewStartSearch(keywords: textField.stringValue)
            }
            return true
        }
        return false
    }
}
