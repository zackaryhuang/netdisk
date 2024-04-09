//
//  Extensions.swift
//  netdisk
//
//  Created by Zackary on 2023/9/18.
//

import Foundation
import AppKit

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

extension Double {
    var binarySizeString: String {
        get {
            let KB = pow(Double(1024.0), 1)
            let MB = pow(Double(1024.0), 2)
            let GB = pow(Double(1024.0), 3)
            let TB = pow(Double(1024.0), 4)
            if self >= TB {
                return String(format: "%.2fTB", self / TB)
            }
            if self >= GB {
                return String(format: "%.2fGB", self / GB)
            }
            if self >= MB {
                return String(format: "%.2fMB", self / MB)
            }
            if self >= KB {
                return String(format: "%.2fKB", self / KB)
            }
            return String(format: "%.2fByte", self)
        }
    }
}
