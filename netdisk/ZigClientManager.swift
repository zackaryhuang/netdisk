//
//  ClientManager.swift
//  netdisk
//
//  Created by Zackary on 2023/12/21.
//

import Foundation

enum CloudNetdiskType {
    case Baidu
    case Aliyun
}

class ZigClientManager {
    static let shared = ZigClientManager()
    var accessToken: String? {
        get {
            if currentClient() == .Aliyun {
                return UserDefaults.standard.object(forKey: "AliUserAccessToken") as? String
            }
            return UserDefaults.standard.object(forKey: "UserAccessToken") as? String
        }
        set {
            if currentClient() == .Aliyun {
                UserDefaults.standard.set(newValue, forKey: "AliUserAccessToken")
            } else {
                UserDefaults.standard.set(newValue, forKey: "UserAccessToken")
            }
            
        }
    }
    
    var authorization: String? {
        get {
            if currentClient() == .Aliyun {
                return UserDefaults.standard.object(forKey: "AliAuthorization") as? String
            }
            return UserDefaults.standard.object(forKey: "Authorization") as? String
        }
        set {
            if currentClient() == .Aliyun {
                UserDefaults.standard.set(newValue, forKey: "AliAuthorization")
            } else {
                UserDefaults.standard.set(newValue, forKey: "Authorization")
            }
            
        }
    }
    
    var aliUserData: AliUserData? = nil
    var baiduUserData: BaiduUserData? = nil
    
    var userData: (any UserData)? {
        get {
            if currentClient() == .Aliyun {
                aliUserData
            } else {
                baiduUserData
            }
        }
    }
    
    func currentClient() -> CloudNetdiskType {
        return .Aliyun
    }
}
