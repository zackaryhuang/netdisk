//
//  CommonDefine.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
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
}
