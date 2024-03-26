//
//  ZHUserManager.swift
//  netdisk
//
//  Created by Zackary on 2023/10/15.
//

import Cocoa
import Alamofire
import Kingfisher

protocol ZigUserManagerDelegate: NSObjectProtocol {
    func loginDataExpired()
}

class ZigUserManager: NSObject {
    
    weak var delegate: ZigUserManagerDelegate?
    
    var currentUserData: BaiduUserData?
    
    public static let sharedInstance = {
        let manager = ZigUserManager()
        return manager
    }()
    
    func handleLoginExpired() {
        delegate?.loginDataExpired()
    }
    
    func requestUserData(_ completion :@escaping((Bool) -> Void)) {
        Task {
            if let res = try? await WebRequest.requestUserData() {
                completion(res)
                return
            }
            completion(false)
        }
    }
}
