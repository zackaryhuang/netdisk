//
//  ABImageView.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/29.
//

import Cocoa

class ABImageView: NSImageView {
    
    open override var image: NSImage? {
        set {
            self.layer = CALayer()
            self.layer?.contentsGravity = .resizeAspectFill
            self.layer?.contents = newValue
            self.wantsLayer = true
            
            super.image = newValue
        }
        
        get {
            return super.image
        }
    }
    
}
