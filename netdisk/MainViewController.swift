//
//  MainViewController.swift
//  netdisk
//
//  Created by Zackary on 2023/8/30.
//

import Cocoa
import SnapKit
import Alamofire
import Kingfisher

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, FilePathViewDelegate, TabItemViewDelegate {

    var fileResponse: FileResponse?
    
    let avatarImageView = {
        let imageView = NSImageView()
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 5;
        return imageView
    }()
    
    var tabs: [TabItemView] = []
    
    var categoryItems = [CategoryItem(image: "icon_category_files", title: "我的网盘", isSelected: true),
                         CategoryItem(image: "icon_category_image", title: "图片", isSelected: false),
                         CategoryItem(image: "icon_category_video", title: "视频", isSelected: false),
                         CategoryItem(image: "icon_category_audio", title: "音频", isSelected: false),
                         CategoryItem(image: "icon_category_doc", title: "文档", isSelected: false)]
    
    var transItems = [CategoryItem(image: "icon_download", title: "正在下载", isSelected: true),
                      CategoryItem(image: "icon_upload", title: "正在上传", isSelected: false),
                      CategoryItem(image: "icon_finished", title: "传输完成", isSelected: false)]
    
    var currentItems: [CategoryItem] = []
    
    let tableView = {
        let tableView = NSTableView()
        tableView.selectionHighlightStyle = .none
        tableView.wantsLayer = true
        tableView.layer?.backgroundColor = NSColor.blue.cgColor
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    let categoryTableView = {
        let tableView = NSTableView()
        tableView.backgroundColor = .clear
        tableView.selectionHighlightStyle = .none
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "CategoryColumn"))
        tableView.addTableColumn(column)
        return tableView;
    }()
    
    let filePathView = {
        let view = FilePathView()
        return view
    }()
    
    let usageView = {
        let view = UsageView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x111113).cgColor
        return view
    }()
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x2C2C2C).cgColor
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        requestUerData()
        requestFileList(with: nil)
        requestUsage()
    }
    
    func configUI() {
        view.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(38)
            make.leading.equalTo(view).offset(10)
            make.top.equalTo(view).offset(60)
        }
        
        let filesTabItem = TabItemView(image: "icon_tab_files", title: "文件", delegate: self, type: .files)
        filesTabItem.isSelected = true
        tabs.append(filesTabItem)
        view.addSubview(filesTabItem)
        filesTabItem.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.leading.equalTo(view)
            make.width.equalTo(58)
        }
        
        let searchTabItem = TabItemView(image: "icon_tab_search", title: "搜索", delegate: self, type: .search)
        tabs.append(searchTabItem)
        view.addSubview(searchTabItem)
        searchTabItem.snp.makeConstraints { make in
            make.top.equalTo(filesTabItem.snp.bottom).offset(10)
            make.leading.equalTo(view)
            make.width.equalTo(58)
        }
        
        let transTabItem = TabItemView(image: "icon_tab_trans", title: "传输", delegate: self, type: .trans)
        tabs.append(transTabItem)
        view.addSubview(transTabItem)
        transTabItem.snp.makeConstraints { make in
            make.top.equalTo(searchTabItem.snp.bottom).offset(10)
            make.leading.equalTo(view)
            make.width.equalTo(58)
        }
        
        currentItems = categoryItems
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.headerView = nil
        categoryTableView.target = self
        categoryTableView.action = #selector(tableViewClick(_:))
        
        let categoryContainerView = NSScrollView()
        view.addSubview(categoryContainerView)
        categoryContainerView.backgroundColor = NSColor(hex: 0x111113)
        categoryContainerView.hasVerticalScroller = false
        categoryContainerView.documentView = categoryTableView
        categoryContainerView.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.top.equalTo(view)
            make.width.equalTo(view).multipliedBy(1/5.0)
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        filePathView.delegate = self
        view.addSubview(filePathView)
        filePathView.snp.makeConstraints { make in
            make.leading.equalTo(categoryContainerView.snp.trailing)
            make.top.trailing.equalTo(view)
            make.height.equalTo(40)
        }
        
        let tableContainerView = NSScrollView()
        view.addSubview(tableContainerView)
        tableContainerView.drawsBackground = false
        tableContainerView.hasVerticalScroller = true
        tableContainerView.autohidesScrollers = true
        tableContainerView.documentView = tableView
        tableContainerView.snp.makeConstraints { make in
            make.leading.equalTo(categoryContainerView.snp.trailing)
            make.trailing.equalTo(view)
            make.top.equalTo(view).offset(40)
            make.bottom.equalTo(view)
        }
        
        view.addSubview(usageView)
        usageView.snp.makeConstraints { make in
            make.leading.equalTo(categoryContainerView)
            make.trailing.equalTo(categoryContainerView)
            make.top.equalTo(categoryContainerView.snp.bottom)
            make.bottom.equalTo(view)
            make.height.equalTo(60)
            
        }
        
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == categoryTableView {
            return currentItems.count
        }
        return fileResponse?.list?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if tableView == categoryTableView {
            var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("CategoryRowView"), owner: self)
            if rowView == nil {
                rowView = CategoryRowView()
            }
            
            let categoryItem = currentItems[row]
            (rowView as? CategoryRowView)?.updateCategoryRowView(with: categoryItem)
            return rowView as? CategoryRowView
        }
        
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("FileRowView"), owner: self)
        if rowView == nil {
            rowView = FileRowView()
        }
        let fileInfo = fileResponse?.list![row]
        (rowView as? FileRowView)?.updateRowView(with: fileInfo)
        return (rowView as? FileRowView)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView == categoryTableView {
            return 60
        }
        return 50
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileColumn"), owner: nil)
        return columnView
        
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        guard let fileInfo = fileResponse?.list?[tableView.selectedRow] else {
            return
        }
        
        requestFileList(with: fileInfo.path)
    }
    
    @objc func tableViewClick(_ sender: AnyObject) {
        if let categoryTableView = sender as? NSTableView {
            let index = categoryTableView.selectedRow
            for (idx, value) in currentItems.enumerated() {
                value.isSelected = idx == index
            }
            categoryTableView.reloadData()
        }
        
    }
    
    
    func requestUerData() {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String {
            AF.request("https://pan.baidu.com/rest/2.0/xpan/nas", method: .get, parameters: ["method" : "uinfo", "access_token" : accessToken]).responseDecodable(of: BaiduUserData.self) { response in
                
                if let url_string = response.value?.avatarUrl {
                    self.avatarImageView.kf.setImage(with: URL(string: url_string)) { result in
                        switch result {
                        case .success:
                            print(response.value?.netdiskName ?? "")
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func requestFileList(with folderName: String?) {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String {
            AF.request("https://pan.baidu.com/rest/2.0/xpan/file", method: .get, parameters: [
                "method" : "list",
                "access_token" : accessToken,
                "start" : 0,
                "limit" : 20,
                "dir" : folderName ?? "/",
                "web" : 1
            ], encoding: NOURLEncoding()).responseDecodable(of: FileResponse.self) { response in
                if let fileResponse = response.value {
                    if fileResponse.errno == 0 {
                        self.fileResponse = fileResponse
                        self.tableView.reloadData()
                        if let path = self.fileResponse?.list?.first?.path {
                            self.filePathView.path = (path as NSString).deletingLastPathComponent
                        }
                        
                    } else {
                        debugPrint("error - \(fileResponse.errno!)")
                    }
                }
            }
        }
        
    }
    
    func requestUsage() {
        if let accessToken = UserDefaults.standard.object(forKey: "UserAccessToken") as? String {
            AF.request("https://pan.baidu.com/api/quota", method: .get, parameters: [
                "access_token" : accessToken
            ]).responseDecodable(of: UsageInfo.self) { response in
                if let usageInfo = response.value {
                    self.usageView.updateView(with: usageInfo)
                }
            }
        }
    }
    
    func didClickPath(path: String) {
        requestFileList(with: path)
    }
    
    func didClickTabView(tabView: TabItemView) {
        tabs.forEach { tab in
            if tab == tabView {
                tab.isSelected = true
                switch tabView.type {
                case .trans:
                    currentItems = transItems
                default:
                    currentItems = categoryItems
                }
            } else {
                tab.isSelected = false
            }
            
        }
        categoryTableView.reloadData()
    }
}

class BaiduUserData: Codable {
    let baiduName: String?
    let netdiskName: String?
    let avatarUrl: String?
    let vipType: Int?
    let uk: Int?
    
    enum CodingKeys: String, CodingKey {
        case baiduName = "baidu_name"
        case netdiskName = "netdisk_name"
        case avatarUrl = "avatar_url"
        case vipType = "vip_type"
        case uk = "uk"
    }
}

class FileInfo: Codable {
    let fsID: UInt64?
    let path: String?
    let serverFileName: String?
    let size: UInt?
    let isDir: UInt?
    let category: UInt?
    let thumbs: [String : String]?
    
    enum CodingKeys: String, CodingKey {
        case fsID = "fs_id"
        case path = "path"
        case serverFileName = "server_filename"
        case size = "size"
        case isDir = "isdir"
        case category = "category"
        case thumbs = "thumbs"
    }
}

class FileResponse: Codable {
    let errno: Int?
    let guideInfo: String?
    let list: [FileInfo]?
    enum CodingKeys: String, CodingKey {
        case errno = "errno"
        case guideInfo = "guide_info"
        case list = "list"
    }
}

class UsageInfo: Codable {
    let total: Int?
    let used: Int?
    let free: Int?
    let expire: Bool?
}

public struct NOURLEncoding: ParameterEncoding {

    //protocol implementation
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters else { return urlRequest }

        if HTTPMethod(rawValue: urlRequest.httpMethod ?? "GET") != nil {
            guard let url = urlRequest.url else {
                throw AFError.parameterEncodingFailed(reason: .missingURL)
            }

            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                urlRequest.url = urlComponents.url
            }
        }

        return urlRequest
    }

    //append query parameters
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }

        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    //Alamofire logic for query components handling
    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    //escaping function where we can select symbols which we want to escape
    //(I just removed + for example)
    public func escape(_ string: String) -> String {
        let generalDelimitersToEncode = "/:#[]@+" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*,;="

        var allowedCharacterSet = CharacterSet.urlHostAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        var escaped = ""

        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string

        return escaped
    }

}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
