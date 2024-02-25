//
//  ZHUserManager.swift
//  netdisk
//
//  Created by Zackary on 2023/10/15.
//

import Cocoa
import Alamofire
import Kingfisher

protocol ZHUserManagerDelegate: NSObjectProtocol {
    func loginDataExpired()
}

class ZHUserManager: NSObject {
    
    weak var delegate: ZHUserManagerDelegate?
    
    var currentUserData: BaiduUserData?
    
    public static let sharedInstance = {
        let manager = ZHUserManager()
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
