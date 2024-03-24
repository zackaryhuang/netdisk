//
//  ZHLabel.swift
//  netdisk
//
//  Created by Zackary on 2023/9/20.
//

import Cocoa

class ZigLabel: NSTextField {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isBordered = false
        self.isSelectable = false
        self.drawsBackground = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
