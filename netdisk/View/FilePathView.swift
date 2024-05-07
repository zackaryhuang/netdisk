//
//  FilePathView.swift
//  netdisk
//
//  Created by Zackary on 2023/9/3.
//

import Cocoa

protocol FilePathViewDelegate: NSObjectProtocol {
    func filePathViewPathDidChange(path: String, folderID: String?)
    func searchViewStartSearch(keywords: String)
    func searchViewDidEndSearch()
}

class FilePathView: NSView {
    static let SearchViewHeight = 30.0
    static let SearchViewWidth = 140.0
    var searchView: SearchView!
    
    var rootName: String
    
    var inSearchMode = false
    var isSearchViewAnimating = false
    
    weak var delegate: FilePathViewDelegate?
    
    lazy var filePaths:[(String, String?)] = [(self.rootName, "root")] {
        didSet {
            updateUI()
        }
    }
    
    var paths = [PathItem]()
    
    init(rootName: String) {
        self.rootName = rootName
        super.init(frame: NSZeroRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        searchView = SearchView()
        searchView.delegate = self
        searchView.wantsLayer = true
        searchView.layer?.name = "Search"
        searchView.layer?.backgroundColor = NSColor(hex: 0x19191C).cgColor
        searchView.layer?.cornerRadius = 5
        
        let click = NSClickGestureRecognizer(target: self, action: #selector(searchClick))
        searchView.addGestureRecognizer(click)
        addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.trailing.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
            make.height.equalTo(FilePathView.SearchViewHeight)
            make.width.equalTo(FilePathView.SearchViewWidth)
        }
    }
    
    private func getFixedPaths( items: inout [PathItem]) {
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
                NSAttributedString.Key.font : NSFont(PingFang: 18) as Any
            ])
            totalWidth += attributedTitle.size().width
        }
        
        if hasIgnoredItem {
            let attributedTitle = NSAttributedString(string: String("..."), attributes: [
                NSAttributedString.Key.foregroundColor : NSColor.gray,
                NSAttributedString.Key.font : NSFont(PingFang: 18) as Any
            ])
            totalWidth += 24
            totalWidth += attributedTitle.size().width
        }
        
        if (totalWidth + 21 + FilePathView.SearchViewWidth + 20) > self.frame.size.width {
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
        subviews.forEach { view in
            if view.layer?.name != "Search" {
                view.removeFromSuperview()
            }
        }
        
        var pathItems = [PathItem]()
        filePaths.forEach { (path: String, folderID: String?) in
            pathItems.append(PathItem(pathUnit: path, shouldIgnore: false, folderID: folderID))
        }

        getFixedPaths(items: &pathItems)
        
        paths.removeAll()
        var lastView: NSView? = nil
        for (index,value) in pathItems.enumerated() {
            paths.append(value)
            if value.shouldIgnore == true && pathItems.count > (index + 1) && pathItems[index + 1].shouldIgnore == true {
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
            if value.shouldIgnore == true {
                stringValue = "..."
            }
            let button = NSButton(title: String(stringValue), target: self, action: #selector(buttonClick(_:)))
            button.attributedTitle = NSAttributedString(string: String(stringValue), attributes: [
                NSAttributedString.Key.font : NSFont(LXGWRegularSize: 18) as Any
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
                NSAttributedString.Key.font : NSFont(LXGWRegularSize: 18) as Any
            ])
        }
    }
    
    @objc private func buttonClick(_ sender: AnyObject) {
        if let button = sender as? NSButton {
            if button.tag == 0 {
                self.delegate?.filePathViewPathDidChange(path: "/", folderID: "root")
                filePaths = [(self.rootName, "root")]
            } else {
                let path = paths[1..<(button.tag+1)]
                var originPath = [String]()
                var newFilePaths = [(String, String?)]()
                path.forEach { item in
                    originPath.append(item.pathUnit)
                    newFilePaths.append((item.pathUnit, item.folderID))
                }
                newFilePaths.insert((self.rootName, "root"), at: 0)
                debugPrint("/" + originPath.joined(separator: "/"))
                let fullPath = "/" + originPath.joined(separator: "/")
                self.delegate?.filePathViewPathDidChange(path: fullPath, folderID: path.last?.folderID)
                filePaths = newFilePaths
            }
        }
    }
    
    @objc private func searchClick() {
        if isSearchViewAnimating || inSearchMode {
            return
        }
        inSearchMode = !inSearchMode
        startSearchAnimation()
    }
    
    private func startSearchAnimation() {
        isSearchViewAnimating = true
        searchView.searchTextField.isEditable = inSearchMode
        NSAnimationContext.runAnimationGroup({[weak self] context in
            guard let self = self else { return }
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            self.searchView.snp.remakeConstraints { make in
                if self.inSearchMode {
                    make.leading.equalTo(self).offset(20)
                } else {
                    make.width.equalTo(FilePathView.SearchViewWidth)
                }
                make.trailing.equalTo(self).offset(-20)
                make.centerY.equalTo(self)
                make.height.equalTo(FilePathView.SearchViewHeight)
            }
            
            subviews.forEach { view in
                if view.layer?.name != "Search" {
                    view.alphaValue = self.inSearchMode ? 0.0 : 1.0
                    if let button = view as? NSButton {
                        button.isEnabled = !self.inSearchMode
                    }
                }
            }
            
            self.searchView.needsLayout = true
            self.searchView.layoutSubtreeIfNeeded()
        }) { [weak self] in
            guard let self = self else { return }
            self.isSearchViewAnimating = false
            if (self.inSearchMode) {
                self.searchView.searchTextField.becomeFirstResponder()
            }
        }
    }
    
    func endSearch() {
        inSearchMode = false
        searchView.searchTextField.stringValue = ""
        startSearchAnimation()
        delegate?.searchViewDidEndSearch()
    }
}
extension FilePathView: SearchViewDelegate {
    func searchViewDidCancel() {
        delegate?.searchViewDidEndSearch()
        endSearch()
    }
    
    func searchViewStartSearch(keywords: String) {
        delegate?.searchViewStartSearch(keywords: keywords)
    }
}

class PathItem {
    let pathUnit: String
    let folderID: String?
    var shouldIgnore: Bool?
    
    init(pathUnit: String, shouldIgnore: Bool? = nil, folderID: String? = nil) {
        self.pathUnit = pathUnit
        self.shouldIgnore = shouldIgnore
        self.folderID = folderID
    }
}
