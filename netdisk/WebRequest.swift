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
    case statusFail(code: Int, message: String)
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

protocol AccessTokenData: Hashable, Codable {
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
    
    enum CodingKeys : String, CodingKey {
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
    
    enum CodingKeys : String, CodingKey {
        case videoList = "live_transcoding_task_list"
    }
}

struct AliVideoPlayItem: Codable {
    let url: String
    let width: Int
    let height: Int
    
    enum CodingKeys : String, CodingKey {
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
    var previewURL: URL? {
        if let urlString = url {
            return URL(string: urlString)
        }
        return nil
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
    let resourceDriveID: String
    let backupDriveID: String
    var avatarURL: URL? { URL(string: avatar) }
    
    enum CodingKeys : String, CodingKey {
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
    enum CodingKeys : String, CodingKey {
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
    
    enum CodingKeys : String, CodingKey {
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
    
    enum CodingKeys: String, CodingKey {
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

protocol FileListResp: Codable {
    var fileList: [any FileData]? { get }
    var nextMarker: String? { get }
}

struct AliFileListResp: FileListResp {
    var fileList: [any FileData]? {
        return list
    }
    let list: [AliFileData]?
    let nextMarker: String?
    
    enum CodingKeys: String, CodingKey {
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
    
    enum CodingKeys: String, CodingKey {
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
    
    enum CodingKeys: String, CodingKey {
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
    enum CodingKeys: String, CodingKey {
        case size, thumbs, path
        case fsID = "fs_id"
        case fileName = "server_filename"
        case categoryInner = "category"
        case dirFlag = "isdir"
    }
}

protocol QRCodeData: Hashable, Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case deviceCode = "device_code"
        case QRCodeUrl = "qrcode_url"
        case userCode = "user_code"
        case expiresIn = "expires_in"
        case interval = "interval"
    }
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
        static let AliGenerateQRCode = AliyunDomain + "/oauth/authorize/qrcode"
        static let AliGetAccessToken = AliyunDomain + "/oauth/access_token"
        static let AliUserInfo = AliyunDomain + "/adrive/v1.0/user/getDriveInfo"
        static let AliFileList = AliyunDomain + "/adrive/v1.0/openFile/list"
        static let AliFileDetail = AliyunDomain + "/adrive/v1.0/openFile/get"
        static let AliVideoPlayInfo = AliyunDomain + "/adrive/v1.0/openFile/getVideoPreviewPlayInfo"
        static let AliGetDownloadUrl = AliyunDomain + "/adrive/v1.0/openFile/getDownloadUrl"
        static let AliGetSpaceInfo = AliyunDomain + "/adrive/v1.0/user/getSpaceInfo"
        static let AliFileSearch = AliyunDomain + "/adrive/v1.0/openFile/search"
        static let BaiduGenerateQRCode = BaiduDomain + "/oauth/2.0/device/code"
        static let BaiduGetAccessToken = BaiduDomain + "/oauth/2.0/token"
        static let BaiduUserInfo = BaiduDomain2 + "/rest/2.0/xpan/nas?method=uinfo"
        static let BaiduFileList = BaiduDomain2 + "/rest/2.0/xpan/file"
        static let BaiduFileDetail = BaiduDomain2 + "/rest/2.0/xpan/multimedia"
    }
    
    static func requestFileSearch(keywords: String) async throws -> AliFileSearchResp? {
        if ClientManager.shared.currentClient() == .Aliyun {
            guard let driveID = ClientManager.shared.aliUserData?.defaultDriveID else { return nil }
            let params = [
                "drive_id" : driveID,
                "query" : "name match \"\(keywords)\"",
            ] as [String:Any]
            let res: AliFileSearchResp? = try? await request(method: .post, url: EndPoint.AliFileSearch, parameters: params)
            return res
        }
        return nil;
    }
    
    static func requestSpaceInfo() async throws -> SpaceInfo? {
        if ClientManager.shared.currentClient() == .Aliyun {
            let res: AliSpaceInfo? = try? await request(method: .post, url: EndPoint.AliGetSpaceInfo, dataObj: "personal_space_info")
            return res
        }
        return nil
    }
    
    static func requestVideoPlayInfo(fileID: String) async throws -> VideoPlayInfo? {
        if ClientManager.shared.currentClient() == .Aliyun {
            guard let driveID = ClientManager.shared.aliUserData?.defaultDriveID else {
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
    
    static func requestFileDetail(fileID: String) async throws -> (any FileDetail)? {
        if ClientManager.shared.currentClient() == .Aliyun {
            guard let driveID = ClientManager.shared.aliUserData?.defaultDriveID else {
                return nil
            }
            let params = [
                "drive_id" : driveID,
                "file_id" : fileID,
            ] as [String:Any]
            
            let res: AliFileDetail? = try? await request(method: .post, url: EndPoint.AliFileDetail, parameters: params)
            return res
        }
        
        guard let accessToken = ClientManager.shared.accessToken else {
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
    
    static func requestDownloadUrl(driveID: String? = ClientManager.shared.aliUserData?.defaultDriveID, fileID: String) async throws -> DownloadInfo?  {
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
    
    static func requestFileList(startMark: String?, limit: Int, parentFolder: String) async throws -> FileListResp? {
        if ClientManager.shared.currentClient() == .Aliyun {
            guard let driveID = ClientManager.shared.aliUserData?.defaultDriveID else {
                return nil
            }
            var params = [
                "drive_id" : driveID,
                "limit" : limit,
                "parent_file_id": parentFolder
            ] as [String:Any]
            
            if let mark = startMark, !mark.isEmpty {
                params["marker"] = mark
            }
            
            let res: AliFileListResp? = try? await request(method: .post, url: EndPoint.AliFileList, parameters: params)
            return res
        }
        
        guard let accessToken = ClientManager.shared.accessToken else {
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
    
    static func requestUserData() async throws -> Bool {
        if ClientManager.shared.currentClient() == .Aliyun {
            let res: AliUserData? = try? await request(method: .post, url: EndPoint.AliUserInfo)
            if let userData = res {
                ClientManager.shared.aliUserData = userData
                return true
            }
            return false
        }
        
        guard let accessToken = ClientManager.shared.accessToken else {
            return false
        }
        let params = [
            "access_token" : accessToken
        ] as [String : Any]
        let res: BaiduUserData? = try? await request(method: .get, url: EndPoint.BaiduUserInfo, parameters: params)
        if let userData = res {
            ClientManager.shared.baiduUserData = userData
            return true
        }
        return false
    }
    
    static func requestLoginQRCode() async throws -> (any QRCodeData) {
        if ClientManager.shared.currentClient() == .Aliyun {
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
    
    static func requestAccessToken(authCode: String) async throws -> (any AccessTokenData)? {
        if (ClientManager.shared.currentClient() == .Aliyun) {
            let params = [
                "client_secret" : AliClientSecret,
                "client_id": AliClientID,
                "grant_type": "authorization_code",
                "code": authCode
            ]
            
            let res: AliAccessTokenData = try await request(method: .post, url: EndPoint.AliGetAccessToken, parameters: params)
            let authHeader = res.tokenType + " " + res.accessToken
            ClientManager.shared.authorization = authHeader
            return res
        }
        let params = [
            "grant_type" : "device_token",
            "code" : authCode,
            "client_id" : BaiduClientID,
            "client_secret" : BaiduClientSecret] as [String : Any]
        let res: BaiduAccessTokenData = try await request(method: .get, url: EndPoint.BaiduGetAccessToken, parameters: params)
        return res
    }
    
    static func queryQRCodeScanStatus(code: String) async throws -> QRCodeStatus {
        if ClientManager.shared.currentClient() == .Aliyun {
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
                if let accessTokenData = try await requestAccessToken(authCode: authCode) {
                    ClientManager.shared.accessToken = accessTokenData.accessToken
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
        
        if let data = try await requestAccessToken(authCode: code), !data.accessToken.isEmpty {
            ClientManager.shared.accessToken = data.accessToken
            return .AuthSuccess
        }
        return .WaitScan
    }
    
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
                let errorCode = json["code"].intValue
                if errorCode != 0 {
                    let message = json["message"].stringValue
                    print(errorCode, message)
                    complete?(.failure(.statusFail(code: errorCode, message: message)))
                    return
                }
                var data = json
                if let dataObj {
                    data = json[dataObj]
                }
                print("\(url) response: \(data)")
                complete?(.success(data))
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
        
        if let authHeader = ClientManager.shared.authorization {
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
