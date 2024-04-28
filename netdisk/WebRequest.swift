//
//  WebRequest.swift
//  netdisk
//
//  Created by Zackary on 2023/12/21.
//

import Foundation
import Alamofire
import SwiftyJSON

enum RequestError: Error {
    case networkFail
    case statusFail(code: String, message: String)
    case decodeFail(message: String)
}

enum QRCodeStatus {
    case WaitScan
    case ScanSuccess
    case LoginSuccess
    case QRCodeExpired
    case AuthSuccess
}

enum FileCategory {
    case Video
    case Audio
    case Picture
    case Document
    case Application
    case Torrent
    case Others
}

protocol AccessTokenData: Codable {
    var accessToken: String { get }
    var refreshToken: String { get }
    var expiresIn: Int { get }
}

protocol UserData: Hashable, Codable {
    var avatarURL: URL? { get }
    var name: String { get }
}

protocol FileDetail: Codable {
    var previewURL: URL? { get }
    var fileID: String? { get }
}

protocol CreateFolderResp: Codable {
    
}

protocol VideoPlayInfo: Codable {
    var playURL: URL? { get }
}

protocol DownloadInfo: Codable {
    var downloadURL: URL? { get }
    var expiration: String? { get }
    var method: String? { get }
}

protocol SpaceInfo: Codable {
    var usedSize: Int { get }
    var totalSize: Int { get }
}

struct AliCreateFolderResp: CreateFolderResp {
    let status: String?
    let parentFolderID: String?
    private enum CodingKeys : String, CodingKey {
        case status
        case parentFolderID = "parent_file_id"
    }
}

struct AliFileSearchResp: Codable {
    var items: [AliFileData]
}

struct AliSpaceInfo: SpaceInfo {
    let used: Int
    let total: Int
    var usedSize: Int {
        return used
    }
    
    var totalSize: Int {
        return total
    }
    
    private enum CodingKeys : String, CodingKey {
        case used = "used_size"
        case total = "total_size"
    }
}

struct AliVideoPlayInfo: VideoPlayInfo {
    var videoList: [AliVideoPlayItem?]
    var playURL: URL? {
        if let url = videoList.last,
        let u = url {
            return URL(string: u.url)
        }
        return nil
    }
    
    private enum CodingKeys : String, CodingKey {
        case videoList = "live_transcoding_task_list"
    }
}

struct AliVideoPlayItem: Codable {
    let url: String
    let width: Int
    let height: Int
    
    private enum CodingKeys : String, CodingKey {
        case url
        case width = "template_width"
        case height = "template_height"
    }
}

struct AliDownloadInfo: DownloadInfo {
    var downloadURL: URL? {
        if let urlString = url {
            return URL(string: urlString)
        }
        return nil
    }
    let url: String?
    let method: String?
    let expiration: String?
}

struct BaiduDownloadInfo: DownloadInfo {
    var downloadURL: URL? { URL(string: url) }
    let url: String
    let method: String?
    let expiration: String?
}

struct AliFileDetail: FileDetail {
    let url: String?
    let id: String?
    var previewURL: URL? {
        if let urlString = url {
            return URL(string: urlString)
        }
        return nil
    }
    
    var fileID: String? {
        return id
    }
    
    private enum CodingKeys : String, CodingKey {
        case url
        case id = "file_id"
    }
}

struct BaiduFileDetail: FileDetail {
    var list: [BaiduFile?]?
    var previewURL: URL? {
        if let file = list?.first, let thumb = file?.thumbs {
            if let icon = thumb.icon {
                return URL(string: icon)
            }
            
            if let url1 = thumb.url1 {
                return URL(string: url1)
            }
            
            if let url2 = thumb.url2 {
                return URL(string: url2)
            }
            
            if let url3 = thumb.url3 {
                return URL(string: url3)
            }
            return nil
        }
        return nil
    }
    
    var fileID: String? {
        return nil
    }
}

struct BaiduFile: Codable {
    var thumbs: BaiduThumbs?
}

struct BaiduThumbs: Codable {
    var icon: String?
    var url1: String?
    var url2: String?
    var url3: String?
}

struct AliUserData: UserData {
    let avatar: String
    let name: String
    let userID: String
    let defaultDriveID: String
    let resourceDriveID: String?
    let backupDriveID: String?
    var avatarURL: URL? { URL(string: avatar) }
    
    private enum CodingKeys : String, CodingKey {
        case avatar, name
        case backupDriveID = "backup_drive_id"
        case defaultDriveID = "default_drive_id"
        case resourceDriveID = "resource_drive_id"
        case userID = "user_id"
    }
}

struct BaiduUserData: UserData {
    let name: String
    let avatar: String
    private enum CodingKeys : String, CodingKey {
        case name = "netdisk_name"
        case avatar = "avatar_url"
    }
    var avatarURL: URL? { URL(string: avatar) }
}

struct AliAccessTokenData: AccessTokenData {
    let tokenType: String
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    private enum CodingKeys : String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

struct BaiduAccessTokenData: AccessTokenData {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

protocol FileData: Codable {
    var fileName: String { get }
    var fileID: String { get }
    var category: FileCategory { get }
    var thumbnail: URL? { get }
    var size: Int? { get }
    var isDir: Bool { get }
}

protocol FileCreateResp: Codable {
    
}

protocol FileListResp: Codable {
    var fileList: [any FileData]? { get }
    var nextMarker: String? { get }
}

struct AliFileCreateResp: FileCreateResp {
    let driveID: String
    let fileID: String
    let status: Int?
    let parentFileID: String
    let uploadID: String?
    let fileName: String
    let available: Bool?
    let isExist: Bool?
    let isRapidUpload: Bool
    let partInfoList: [AliPartInfo]
    
    private enum CodingKeys: String, CodingKey {
        case status, available
        case driveID = "drive_id"
        case fileID = "file_id"
        case parentFileID = "parent_file_id"
        case uploadID = "upload_id"
        case fileName = "file_name"
        case isExist = "exist"
        case isRapidUpload = "rapid_upload"
        case partInfoList = "part_info_list"
    }
}

struct AliPartInfo: Codable {
    let partNumber: Int
    let uploadUrl: String
    let partSize: Int?
    
    private enum CodingKeys: String, CodingKey {
        case partNumber = "part_number"
        case uploadUrl = "upload_url"
        case partSize = "part_size"
    }
}

struct AliFileListResp: FileListResp {
    var fileList: [any FileData]? {
        return list
    }
    let list: [AliFileData]?
    let nextMarker: String?
    
    private enum CodingKeys: String, CodingKey {
        case list = "items"
        case nextMarker = "next_marker"
    }
}

struct AliFileData: FileData {
    let fileID: String
    let parentFileID: String
    let fileName: String
    var thumbnail: URL? {
        get {
            return (previewThumbnail != nil) ? URL(string: previewThumbnail!) : nil
        }
    }
    let type: String?
    
    var isDir: Bool {
        if let t = type, t == "folder" {
            return true
        }
        return false
    }
    let previewThumbnail: String?
    let size: Int?
    let categoryInner: String?
    var category: FileCategory {
        if (categoryInner == "video") { return .Video }
        if (categoryInner == "doc") { return .Document }
        if (categoryInner == "audio") { return .Audio }
        if (categoryInner == "image") { return .Picture }
        return .Others
    }
    
    private enum CodingKeys: String, CodingKey {
        case size, type
        case fileID = "file_id"
        case parentFileID = "parent_file_id"
        case fileName = "name"
        case categoryInner = "category"
        case previewThumbnail = "thumbnail"
    }
}

struct BaiduFileListResp: FileListResp {
    let list: [BaiduFileData]?
    var fileList: [any FileData]? {
        return list
    }
    let nextMarker: String?
    
    private enum CodingKeys: String, CodingKey {
        case list = "list"
        case nextMarker = "next_marker"
    }
}

struct BaiduFileData: FileData {
    var fileID: String {
        return String(fsID)
    }
    let fsID: Int
    let path: String
    let fileName: String
    var isDir: Bool {
        return dirFlag > 0
    }
    var category: FileCategory {
        if (categoryInner == 1) { return .Video }
        if (categoryInner == 2) { return .Audio }
        if (categoryInner == 3) { return .Picture }
        if (categoryInner == 4) { return .Document }
        if (categoryInner == 5) { return .Application }
        if (categoryInner == 6) { return .Others }
        if (categoryInner == 7) { return .Torrent }
        return .Others
    }
    let categoryInner: Int
    var thumbs: [String?]?
    let size: Int?
    var thumbnail: URL? {
        if let imageUrl = thumbs?.last {
            return imageUrl != nil ? URL(string: imageUrl!) : nil
        }
        return nil
    }
    let dirFlag: Int
    private enum CodingKeys: String, CodingKey {
        case size, thumbs, path
        case fsID = "fs_id"
        case fileName = "server_filename"
        case categoryInner = "category"
        case dirFlag = "isdir"
    }
}

protocol QRCodeData: Codable {
    var qrCodeUrl: String { get }
    var code: String { get }
}

struct AliQRCodeData: Codable, QRCodeData {
    let qrCodeUrl: String
    let sid: String
    var code: String { sid }
}

struct BaiduQRCodeData: Codable, QRCodeData {
    let deviceCode: String
    let QRCodeUrl: String
    let userCode: String
    let expiresIn: Int
    let interval: Int
    var code: String { deviceCode }
    var qrCodeUrl: String { QRCodeUrl }
    
    private enum CodingKeys: String, CodingKey {
        case deviceCode = "device_code"
        case QRCodeUrl = "qrcode_url"
        case userCode = "user_code"
        case expiresIn = "expires_in"
        case interval = "interval"
    }
}

enum AliAuthType: String {
    case code = "authorization_code"
    case refreshToken = "refresh_token"
}

class WebRequest {
    
    static let shared = WebRequest()
    
    var baiduQRCodeExpiredTimestamp: Int = 0
    var baiduQueryInterval: Int = 0
    
    static let AliyunDomain = "https://openapi.alipan.com"
    static let BaiduDomain = "https://openapi.baidu.com"
    static let BaiduDomain2 = "https://pan.baidu.com"
    static let AliClientSecret = "cf51d8d95ca04c26a227bb57c0d11b5e"
    static let AliClientID = "3d30e06a2c8d459596216479606a5911"
    static let BaiduClientSecret = "OsQkHVyNecu5U3rHyquwdegQGy9HPItD"
    static let BaiduClientID = "8xVGfuF1lIpiyqO1KSSTs8fC0H3VIRHd"
    static let AliScopes = ["user:base", "file:all:read", "file:all:write"]
    static let BaiduScopes = ["basic,netdisk"]
    
    enum EndPoint {
        static let AliCreateFolder = AliyunDomain + "/adrive/v1.0/openFile/create"
        static let AliGenerateQRCode = AliyunDomain + "/oauth/authorize/qrcode"
        static let AliGetAccessToken = AliyunDomain + "/oauth/access_token"
        static let AliUserInfo = AliyunDomain + "/adrive/v1.0/user/getDriveInfo"
        static let AliFileList = AliyunDomain + "/adrive/v1.0/openFile/list"
        static let AliFileDetail = AliyunDomain + "/adrive/v1.0/openFile/get"
        static let AliVideoPlayInfo = AliyunDomain + "/adrive/v1.0/openFile/getVideoPreviewPlayInfo"
        static let AliGetDownloadUrl = AliyunDomain + "/adrive/v1.0/openFile/getDownloadUrl"
        static let AliGetSpaceInfo = AliyunDomain + "/adrive/v1.0/user/getSpaceInfo"
        static let AliFileSearch = AliyunDomain + "/adrive/v1.0/openFile/search"
        static let AliFileUpdate = AliyunDomain + "/adrive/v1.0/openFile/update"
        static let AliFileTrash = AliyunDomain + "/adrive/v1.0/openFile/recyclebin/trash"
        static let AliFileCreate = AliyunDomain + "/adrive/v1.0/openFile/create"
        static let AliFileGetUploadUrl = AliyunDomain + "/adrive/v1.0/openFile/getUploadUrl"
        static let AliFileUploadComplete = AliyunDomain + "/adrive/v1.0/openFile/complete"
        static let BaiduGenerateQRCode = BaiduDomain + "/oauth/2.0/device/code"
        static let BaiduGetAccessToken = BaiduDomain + "/oauth/2.0/token"
        static let BaiduUserInfo = BaiduDomain2 + "/rest/2.0/xpan/nas?method=uinfo"
        static let BaiduFileList = BaiduDomain2 + "/rest/2.0/xpan/file"
        static let BaiduFileDetail = BaiduDomain2 + "/rest/2.0/xpan/multimedia"
    }
    
//    static func uploadFile(data: Data,
//                           uploadUrl: String,
//                           progress: @escaping((CGFloat) -> Void),
//                           completion: @escaping((Bool) -> Void)) {
//        
//        guard let urlRequest = try? URLRequest(url: uploadUrl, method: .put, headers: HTTPHeaders(dictionaryLiteral: ("Content-Length", "\(data.count)"))) else { completion(false)
//            return
//        }
//        
//        AF.upload(data,
//                  with: urlRequest)
//        .uploadProgress { p in
//            progress(p.fractionCompleted)
//        }
//        .response(completionHandler: { res in
//            switch res.result {
//            case .success(let content):
//                completion(true)
//            case .failure(let err):
//                completion(false)
//            }
//        })
//    }
    
    static func uploadFileComplete(driveID: String, fileID: String, uploadID: String) async throws -> Bool {
        let params = [
            "drive_id" : driveID,
            "file_id" : fileID,
            "upload_id" : uploadID
        ]
        
        let res: JSON? = try? await request(method: .post, url: EndPoint.AliFileUploadComplete, parameters: params)
        return res == nil
    }
    
    static func requestCreateFile(driveID: String, parentFileID: String, name: String, preHash: String?) async throws -> AliFileCreateResp? {
        var params = [
            "drive_id" : driveID,
            "parent_file_id" : parentFileID,
            "name" : name,
            "type" : "file",
            "check_name_mode" : "auto_rename"
        ]
        
        if let hash = preHash {
            params["pre_hash"] = hash
        }
        
        let res: AliFileCreateResp? = try? await request(method: .post, url: EndPoint.AliFileCreate, parameters: params)
        return res
    }
    
    /// 文件搜索
    /// - Parameters:
    ///   - keywords: 搜索关键词
    ///   - driveID: 资源盘/备份盘
    /// - Returns: 搜索结果列表
    static func requestFileSearch(keywords: String, driveID: String) async throws -> AliFileSearchResp? {
        if ZigClientManager.shared.currentClient() == .Aliyun {
            let params = [
                "drive_id" : driveID,
                "query" : "name match \"\(keywords)\"",
            ] as [String:Any]
            let res: AliFileSearchResp? = try? await request(method: .post, url: EndPoint.AliFileSearch, parameters: params)
            return res
        }
        return nil;
    }
    
    /// 获取当前空间使用情况
    /// - Returns: 空间信息
    static func requestSpaceInfo() async throws -> SpaceInfo? {
        if ZigClientManager.shared.currentClient() == .Aliyun {
            let res: AliSpaceInfo? = try? await request(method: .post, url: EndPoint.AliGetSpaceInfo, dataObj: "personal_space_info")
            return res
        }
        return nil
    }
    
    /// 获取视频播放信息（一般是转码后的播放链接，如需原画，直接获取下载链接播放）
    /// - Parameter fileID: 视频文件 ID
    /// - Returns: 播放信息
    static func requestVideoPlayInfo(fileID: String) async throws -> VideoPlayInfo? {
        if ZigClientManager.shared.currentClient() == .Aliyun {
            guard let driveID = ZigClientManager.shared.aliUserData?.defaultDriveID else {
                return nil
            }
            let params = [
                "drive_id" : driveID,
                "file_id" : fileID,
                "category" : "live_transcoding"
            ] as [String:Any]
            
            let res: AliVideoPlayInfo? = try? await request(method: .post, url: EndPoint.AliVideoPlayInfo, parameters: params, dataObj: "video_preview_play_info")
            return res
        }
        return nil
    }
    
    /// 获取指定文件详细信息
    /// - Parameters:
    ///   - fileID: 文件 ID
    ///   - driveID: 资源盘/备份盘
    /// - Returns: 文件详情
    static func requestFileDetail(fileID: String, driveID: String? = ZigClientManager.shared.aliUserData?.defaultDriveID) async throws -> FileDetail? {
        if ZigClientManager.shared.currentClient() == .Aliyun {
            guard let id = driveID else {
                return nil
            }
            let params = [
                "drive_id" : id,
                "file_id" : fileID,
            ] as [String:Any]
            
            let res: AliFileDetail? = try? await request(method: .post, url: EndPoint.AliFileDetail, parameters: params)
            return res
        }
        
        guard let accessToken = ZigClientManager.shared.accessToken else {
            return nil
        }
        
        let params = [
            "method": "filemetas",
            "access_token": accessToken,
            "fsids": [fileID]
        ] as [String : Any]
        let res: BaiduFileDetail? = try? await request(method: .get, url: EndPoint.BaiduFileDetail, parameters: params)
        return res
    }
    
    /// 获取下载链接
    /// - Parameters:
    ///   - fileID: 文件 ID
    ///   - driveID: 资源盘/备份盘
    /// - Returns: 下载相关信息
    static func requestDownloadUrl(fileID: String, driveID: String? = ZigClientManager.shared.aliUserData?.defaultDriveID) async throws -> DownloadInfo?  {
        guard let id = driveID, !fileID.isEmpty else {
            return nil
        }
        
        let params = [
            "drive_id" : id,
            "file_id" : fileID
        ] as [String:Any]
        
        let res: AliDownloadInfo? = try? await request(method: .post, url: EndPoint.AliGetDownloadUrl, parameters: params)
        return res
    }
    
    static func requestFileList(startMark: String?, limit: Int, parentFolder: String, useResourceDrive: Bool = false) async throws -> FileListResp? {
        if ZigClientManager.shared.currentClient() == .Aliyun {
            var params = [
                "limit" : limit,
                "parent_file_id": parentFolder
            ] as [String:Any]
            
            if useResourceDrive {
                guard let driveID = ZigClientManager.shared.aliUserData?.resourceDriveID else {
                    return nil
                }
                params["drive_id"] = driveID
            } else {
                guard let driveID = ZigClientManager.shared.aliUserData?.defaultDriveID else {
                    return nil
                }
                params["drive_id"] = driveID
            }
            
            if let mark = startMark, !mark.isEmpty {
                params["marker"] = mark
            }
            
            let res: AliFileListResp? = try? await request(method: .post, url: EndPoint.AliFileList, parameters: params)
            return res
        }
        
        guard let accessToken = ZigClientManager.shared.accessToken else {
            return nil
        }
        
        let params = [
            "method": "list",
            "access_token": accessToken,
            "start": Int(startMark ?? "0") ?? 0,
            "dir": parentFolder,
            "limit": limit
        ] as [String : Any]
        let res: BaiduFileListResp? = try? await request(method: .get, url: EndPoint.BaiduFileList, parameters: params)
        return res
    }
    
    /// 获取登录用户信息
    /// - Returns: true 代表已登录，反之则未登录
    static func requestUserData() async throws -> Bool {
        if ZigClientManager.shared.currentClient() == .Aliyun {
            let res: AliUserData? = try? await request(method: .post, url: EndPoint.AliUserInfo)
            if let userData = res {
                ZigClientManager.shared.aliUserData = userData
                return true
            }
            return false
        }
        
        guard let accessToken = ZigClientManager.shared.accessToken else {
            return false
        }
        let params = [
            "access_token" : accessToken
        ] as [String : Any]
        let res: BaiduUserData? = try? await request(method: .get, url: EndPoint.BaiduUserInfo, parameters: params)
        if let userData = res {
            ZigClientManager.shared.baiduUserData = userData
            return true
        }
        return false
    }
    
    /// 获取登录二维码
    /// - Returns: 二维码信息
    static func requestLoginQRCode() async throws -> QRCodeData? {
        if ZigClientManager.shared.currentClient() == .Aliyun {
            let params = [
                "client_secret" : AliClientSecret,
                "client_id": AliClientID,
                "scopes": AliScopes] as [String : Any]
            let res: AliQRCodeData = try await request(method: .post, url: EndPoint.AliGenerateQRCode, parameters: params)
            return res
        }
        
        let params = [
            "response_type" : "device_code",
            "client_id": BaiduClientID,
            "scope": BaiduScopes] as [String : Any]
        let res: BaiduQRCodeData = try await request(method: .get, url: EndPoint.BaiduGenerateQRCode, parameters: params)
        WebRequest.shared.baiduQRCodeExpiredTimestamp = Int(Date.now.timeIntervalSince1970) + res.expiresIn
        WebRequest.shared.baiduQueryInterval = res.interval
        return res
    }
    
    static func requestAccessToken(authCode: String?, grantType: AliAuthType = .code) async throws -> AccessTokenData? {
        if (ZigClientManager.shared.currentClient() == .Aliyun) {
            var params = [
                "client_secret" : AliClientSecret,
                "client_id": AliClientID,
                "grant_type": grantType.rawValue,
            ]
            
            if let code = authCode {
                params["code"] = code
            }
            
            if grantType == .refreshToken {
                guard let aliRefreshToken = ZigClientManager.shared.refreshToken else { return nil }
                params["refresh_token"] = aliRefreshToken
            }
            
            let res: AliAccessTokenData = try await request(method: .post, url: EndPoint.AliGetAccessToken, parameters: params)
            let authHeader = res.tokenType + " " + res.accessToken
            ZigClientManager.shared.authorization = authHeader
            ZigClientManager.shared.refreshToken = res.refreshToken
            ZigClientManager.shared.accessToken = res.accessToken
            return res
        }
//        let params = [
//            "grant_type" : "device_token",
//            "code" : authCode,
//            "client_id" : BaiduClientID,
//            "client_secret" : BaiduClientSecret] as [String : Any]
//        let res: BaiduAccessTokenData = try await request(method: .get, url: EndPoint.BaiduGetAccessToken, parameters: params)
//        return res
        return nil
    }
    
    static func queryQRCodeScanStatus(code: String) async throws -> QRCodeStatus {
        if ZigClientManager.shared.currentClient() == .Aliyun {
            let path = AliyunDomain + "/oauth/qrcode/\(code)/status"
            let res: JSON = try await request(method: .get, url: path)
            if res["status"] == "WaitLogin" {
                return .WaitScan
            }
            
            if res["status"] == "ScanSuccess" {
                return .ScanSuccess
            }
            
            if res["status"] == "LoginSuccess" {
                let authCode = res["authCode"].stringValue
                if (try await requestAccessToken(authCode: authCode)) != nil {
                    return .AuthSuccess
                }
                return .LoginSuccess
            }
            
            if res["status"] == "QRCodeExpired" {
                return .QRCodeExpired
            }
            
            return .WaitScan
        }
        
        if (WebRequest.shared.baiduQRCodeExpiredTimestamp > 0 && Int(Date.now.timeIntervalSince1970) >= WebRequest.shared.baiduQRCodeExpiredTimestamp) {
            return .QRCodeExpired
        }
        
        if let data = try? await requestAccessToken(authCode: code), !data.accessToken.isEmpty {
            ZigClientManager.shared.accessToken = data.accessToken
            return .AuthSuccess
        }
        return .WaitScan
    }
    
    /// 创建文件夹
    /// - Parameters:
    ///   - driveID: 资源盘/备份盘
    ///   - parentFileID: 父文件夹 ID
    ///   - folderName: 文件夹名
    /// - Returns: 是否创建成功
    static func createFolder(driveID: String? = ZigClientManager.shared.aliUserData?.defaultDriveID, parentFileID: String, folderName: String) async throws -> Bool {
        guard let id = driveID else { return false }
        let params = [
            "drive_id": id,
            "parent_file_id": parentFileID,
            "name": folderName,
            "type": "folder",
            "check_name_mode": "auto_rename"
        ]
        
        if let _: AliCreateFolderResp = try? await request(method: .post, url: EndPoint.AliCreateFolder, parameters: params) {
            return true
        }
        return false
    }
    
    static func rename(driveID: String, fileID: String, newName: String) async throws -> Bool {
        let params = [
            "drive_id": driveID,
            "file_id": fileID,
            "name": newName,
            "check_name_mode": "auto_rename"
        ]
        
        if let _: AliCreateFolderResp = try? await request(method: .post, url: EndPoint.AliFileUpdate, parameters: params) {
            return true
        }
        return false
    }
    
    static func trash(driveID: String, fileID: String) async throws -> Bool {
        let params = [
            "drive_id": driveID,
            "file_id": fileID,
        ]
        
        if let res: JSON = try? await request(method: .post, url: EndPoint.AliFileTrash, parameters: params) {
            return res["status"].numberValue == 0
        }
        return false
    }
}


extension WebRequest {
    static func request<T: Decodable>(method: HTTPMethod = .get,
                                      url: URLConvertible,
                                      parameters: Parameters = [:],
                                      headers: [String: String]? = nil,
                                      decoder: JSONDecoder? = nil,
                                      dataObj: String? = nil) async throws -> T
    {
        return try await withCheckedThrowingContinuation { configure in
            request(method: method, url: url, parameters: parameters, headers: headers, decoder: decoder, dataObj: dataObj) {
                (res: Result<T, RequestError>) in
                switch res {
                case let .success(content):
                    configure.resume(returning: content)
                case let .failure(err):
                    configure.resume(throwing: err)
                }
            }
        }
    }
    
    static func request<T: Decodable>(method: HTTPMethod = .get,
                                      url: URLConvertible,
                                      parameters: Parameters = [:],
                                      headers: [String: String]? = nil,
                                      decoder: JSONDecoder? = nil,
                                      dataObj: String? = nil,
                                      complete: ((Result<T, RequestError>) -> Void)?)
    {
        requestJSON(method: method, url: url, parameters: parameters, headers: headers, dataObj: dataObj) { response in
            switch response {
            case let .success(data):
                do {
                    let data = try data.rawData()
                    let object = try (decoder ?? JSONDecoder()).decode(T.self, from: data)
                    complete?(.success(object))
                } catch let err {
                    print("decode fail:", err)
                    complete?(.failure(.decodeFail(message: err.localizedDescription + String(describing: err))))
                }
            case let .failure(err):
                complete?(.failure(err))
            }
        }
    }
    
    static func requestJSON(method: HTTPMethod = .get,
                            url: URLConvertible,
                            parameters: Parameters = [:],
                            headers: [String: String]? = nil,
                            dataObj: String? = nil,
                            complete: ((Result<JSON, RequestError>) -> Void)? = nil)
    {
        requestData(method: method, url: url, parameters: parameters, headers: headers) { response in
            switch response {
            case let .success(data):
                let json = JSON(data)
                let errorCode = json["code"].stringValue
                if !errorCode.isEmpty {
                    let message = json["message"].stringValue
                    print(errorCode, message)
                    if errorCode == "AccessTokenExpired" {
                        Task {
                            if let _ = try? await requestAccessToken(authCode: nil, grantType: .refreshToken) {
                                requestJSON(method: method, url: url, headers: headers, dataObj: dataObj, complete: complete)
                            } else {
                                complete?(.failure(.statusFail(code: errorCode, message: message)))
                            }
                        }
                    } else {
                        complete?(.failure(.statusFail(code: errorCode, message: message)))
                    }
                } else {
                    var data = json
                    if let dataObj {
                        data = json[dataObj]
                    }
                    print("\(url) response: \(data)")
                    complete?(.success(data))
                }
            case let .failure(err):
                complete?(.failure(err))
            }
        }
    }
    
    static func requestData(method: HTTPMethod = .get,
                            url: URLConvertible,
                            parameters: Parameters = [:],
                            headers: [String: String]? = nil,
                            complete: ((Result<Data, RequestError>) -> Void)? = nil)
    {
        let parameters = parameters
//        if method != .get {
//            parameters["biliCSRF"] = CookieHandler.shared.csrf()
//            parameters["csrf"] = CookieHandler.shared.csrf()
//        }

        var AFHeaders = HTTPHeaders()
        AFHeaders.add(name: "Content-Type", value: "application/json")
        if let headers {
            for (k, v) in headers {
                AFHeaders.add(HTTPHeader(name: k, value: v))
            }
        }

//        if !AFHeaders.contains(where: { $0.name == "User-Agent" }) {
//            AFHeaders.add(.userAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Safari/605.1.15"))
//        }

//        if !AFHeaders.contains(where: { $0.name == "Referer" }) {
//            AFHeaders.add(HTTPHeader(name: "Referer", value: "https://www.bilibili.com"))
//        }
        
        if let authHeader = ZigClientManager.shared.authorization {
            AFHeaders.add(HTTPHeader(name: "Authorization", value: authHeader))
        }

        AF.request(url,
                   method: method,
                   parameters: parameters,
                   encoding: method == .get ? URLEncoding.default : JSONEncoding.default,
                   headers: AFHeaders,
                   interceptor: nil)
            .responseData { response in
                switch response.result {
                case let .success(data):
                    complete?(.success(data))
                case let .failure(err):
                    print(err)
                    complete?(.failure(.networkFail))
                }
            }
    }
}
