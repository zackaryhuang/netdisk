//
//  Extensions.swift
//  netdisk
//
//  Created by Zackary on 2023/9/18.
//

import Foundation
import AppKit
import CryptoKit

extension NSColor {
    convenience init(hex: Int, alpha: Float) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                  green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                  blue: CGFloat((hex >> 0) & 0xFF) / 255.0,
                  alpha: CGFloat(alpha))
    }
    
    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1)
    }
}

extension NSError {
    convenience init(code: Int, description: String) {
        self.init(domain: "ABCloud.Client.Error", code: code, userInfo: [NSError.UserInfoKey.description(): description])
    }
}

extension NSImage {
    convenience init?(symbolName: String, pointSize: CGFloat) {
        self.init(systemSymbolName: symbolName, accessibilityDescription: nil)
//        self.size = NSSize(width: 40, height: 40)
//        self.init(symbolName: symbolName, variableValue: 1)
    }
}

extension NSFont {
    convenience init?(PingFangSemiBold: Float) {
        self.init(name: "PingFangSC-Semibold", size: CGFloat(PingFangSemiBold))
    }
    
    convenience init?(PingFang: Float) {
        self.init(name: "PingFangSC-Regular", size: CGFloat(PingFang))
    }
    
    convenience init?(Menlo: Float) {
        self.init(name: "Menlo-Regular", size: CGFloat(Menlo))
    }
    
    convenience init?(LXGWRegularSize: Float) {
//        self.init(name: "LXGWWenKaiMono-Regular", size: CGFloat(LXGWRegularSize))
        self.init(name: "PingFangSC-Regular", size: CGFloat(LXGWRegularSize))
    }
    
    convenience init?(LXGWLightSize: Float) {
//        self.init(name: "LXGWWenKaiMono-Light", size: CGFloat(LXGWLightSize))
        self.init(name: "PingFangSC-Light", size: CGFloat(LXGWLightSize))
    }
    
    convenience init?(LXGWBoldSize: Float) {
//        self.init(name: "LXGWWenKaiMono-Bold", size: CGFloat(LXGWBoldSize))
        self.init(name: "PingFangSC-Bold", size: CGFloat(LXGWBoldSize))
    }
}

extension String {
    subscript(_ indexs: ClosedRange<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[beginIndex...endIndex])
    }
    
    subscript(_ indexs: Range<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[beginIndex..<endIndex])
    }
    
    subscript(_ indexs: PartialRangeThrough<Int>) -> String {
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[startIndex...endIndex])
    }
    
    subscript(_ indexs: PartialRangeFrom<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        return String(self[beginIndex..<endIndex])
    }
    
    subscript(_ indexs: PartialRangeUpTo<Int>) -> String {
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    var md5: String {
        let digest = Insecure.MD5.hash(data: data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

extension Data {
    func resumeData(with url:String) -> Data? {
        if (url.isEmpty) {
            return nil
        }
        if let resumeDataDic = try? PropertyListSerialization.propertyList(from: self, options: .mutableContainersAndLeaves, format: nil),  var plist = resumeDataDic as? [String: Any] {
            let requestURL = URL(string: url)!
            let newRequestURL = requestURL.appendingQueryParameters(["access_token" : UserDefaults.standard.object(forKey: "UserAccessToken") as! String])
            let newResumeRequest = NSMutableURLRequest(url: newRequestURL)
            if let bytes = plist["NSURLSessionResumeBytesReceived"] as? Int {
                let bytesStr = "bytes=\(bytes)"
                newResumeRequest.addValue(bytesStr, forHTTPHeaderField: "Range")
                newResumeRequest.addValue("pan.baidu.com", forHTTPHeaderField: "User-Agent")
                if let newResumeData = try? NSKeyedArchiver.archivedData(withRootObject: newResumeRequest, requiringSecureCoding: false) {
                    plist["NSURLSessionDownloadURL"] = url
                    plist["NSURLSessionResumeCurrentRequest"] = newResumeData
                    
                    let data = try? PropertyListSerialization.data(fromPropertyList: resumeDataDic, format: .xml, options: 0)
                    return data
                }
            }
        }
        return nil
    }
}

extension URL {
    public func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self,    resolvingAgainstBaseURL: true)!
        var items = urlComponents.queryItems ?? []
        items += parameters.map({ URLQueryItem(name: $0,    value: $1) })
        urlComponents.queryItems = items
        return urlComponents.url!
    }
}

extension Int {
    var B_KB: Int { self * 1024 }
    var B_MB: Int { self.B_KB * 1024 }
    var B_GB: Int { self.B_MB * 1024 }
    var B_TB: Int { self.B_GB * 1024 }
    
    var D_KB: Int { self * 1000 }
    var D_MB: Int { self.D_KB * 1000 }
    var D_GB: Int { self.D_MB * 1000 }
    var D_TB: Int { self.D_GB * 1000 }
}

extension Double {
    var binarySizeString: String {
        get {
            let B_KB = Double(1.B_KB)
            let B_MB = Double(1.B_KB)
            let B_GB = Double(1.B_GB)
            let B_TB = Double(1.B_TB)
            if self >= B_TB {
                return String(format: "%.2f TB", self / B_TB)
            }
            if self >= B_GB {
                return String(format: "%.2f GB", self / B_GB)
            }
            if self >= B_MB {
                return String(format: "%.2f MB", self / B_MB)
            }
            if self >= B_KB {
                return String(format: "%.2f KB", self / B_KB)
            }
            return String(format: "%.2f Byte", self)
        }
    }
    
    var decimalSizeString: String {
        get {
            let D_KB = Double(1.D_KB)
            let D_MB = Double(1.D_MB)
            let D_GB = Double(1.D_GB)
            let D_TB = Double(1.D_TB)
            if self >= D_TB {
                return String(format: "%.2f TB", self / D_TB)
            }
            if self >= D_GB {
                return String(format: "%.2f GB", self / D_GB)
            }
            if self >= D_MB {
                return String(format: "%.2f MB", self / D_MB)
            }
            if self >= D_KB {
                return String(format: "%.2f KB", self / D_KB)
            }
            return String(format: "%.2f Byte", self)
        }
    }
}

extension NSWindow {
    func animatToSize(_ size: CGSize) {
        let oldX = frame.origin.x
        let oldY = frame.origin.y
        let oldW = frame.size.width
        let oldH = frame.size.height
        
        let oldCenter = CGPoint(x: oldX + oldW / 2.0, y: oldY + oldH / 2.0)
        
        let newW = size.width
        let newH = size.height
        let newX = oldCenter.x - newW / 2.0
        let newY = oldCenter.y - newH / 2.0
        
        NSAnimationContext.runAnimationGroup({context in
          context.duration = 0.25
          context.allowsImplicitAnimation = true
            self.setFrame(NSMakeRect(newX, newY, newW, newH), display: true)
        }, completionHandler:nil)
    }
}
