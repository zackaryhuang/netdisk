//
//  SearchView.swift
//  netdisk
//
//  Created by Zackary on 2024/3/16.
//

import Cocoa
import SnapKit

protocol SearchViewDelegate: NSObjectProtocol {
    func searchViewDidCancel()
    func searchViewStartSearch(keywords: String)
}

class SearchView: NSView, NSSearchFieldDelegate {
    var imageView: NSImageView!
    var label: ZigLabel!
    var searchTextField: ZigSearchField!
    weak var delegate: SearchViewDelegate?
    
    var clearButton: NSImageView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
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
        
        searchTextField = ZigSearchField(leadingPadding: 0, trailingPadding: 0)
        searchTextField.cell?.wraps = false
        searchTextField.cell?.isScrollable = true
        searchTextField.cell?.isEditable = false
        searchTextField.focusRingType = .none
        (searchTextField.cell as? NSSearchFieldCell)?.searchButtonCell = nil
        (searchTextField.cell as? NSSearchFieldCell)?.cancelButtonCell = nil
        (searchTextField.cell as? NSSearchFieldCell)?.placeholderAttributedString = NSAttributedString(string: "搜索云盘内文件", attributes: [
            NSAttributedString.Key.foregroundColor : NSColor(hex: 0x6B6B6D),
            NSAttributedString.Key.font : NSFont(PingFang: 12) as Any
        ])
        searchTextField.cell?.font = NSFont(PingFang: 12)
        searchTextField.delegate = self
        
        addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(5)
            make.centerY.equalTo(imageView)
        }
        
        clearButton = NSImageView()
        clearButton.isHidden = true
        clearButton.image = NSImage(named: "btn_clear")
        let ges = NSClickGestureRecognizer(target: self, action: #selector(clear))
        clearButton.addGestureRecognizer(ges)
        addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.equalTo(self)
            make.leading.equalTo(searchTextField.snp.trailing).offset(5)
            make.trailing.equalTo(self).offset(-5)
        }
    }
    
    @objc private func clear() {
        searchTextField.cell?.stringValue = ""
        searchTextField.window?.makeFirstResponder(nil)
        self.clearButton.isHidden = true
        self.delegate?.searchViewDidCancel()
    }
}

extension SearchView: NSTextFieldDelegate {
    func controlTextDidBeginEditing(_ obj: Notification) {
        debugPrint("开始编辑")
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        debugPrint("结束编辑")
    }
    
    func controlTextDidChange(_ obj: Notification) {
        self.clearButton.isHidden = self.searchTextField.stringValue.count <= 0
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
