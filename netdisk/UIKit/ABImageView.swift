//
//  ABImageView.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/29.
//

import Cocoa

enum ABContentMode {
    case aspectFill
    case aspectFit
    case scaleToFill
}

class ABImageView: NSImageView {
    
    open var contentMode: ABContentMode = .aspectFit {
        didSet {
            layer = layer ?? CALayer()
            switch contentMode {
            case .aspectFill:
                layer?.contentsGravity = .resizeAspectFill
            case .aspectFit:
                layer?.contentsGravity = .resizeAspect
            case .scaleToFill:
                layer?.contentsGravity = .resize
            }
            
            layer?.contents = image
            self.wantsLayer = true
        }
    }
    
    open override var image: NSImage? {
        set {
            layer = layer ?? CALayer()
            switch contentMode {
            case .aspectFill:
                layer?.contentsGravity = .resizeAspectFill
            case .aspectFit:
                layer?.contentsGravity = .resizeAspect
            case .scaleToFill:
                layer?.contentsGravity = .resize
            }
            layer?.contents = newValue
            self.wantsLayer = true
            
            super.image = newValue
        }
        
        get {
            return super.image
        }
    }
    
}
