//
//  HoverButton.swift
//  ABCloud
//
//  Created by Zackary on 2024/4/26.
//

import Cocoa

class HoverButton: NSButton {
    
    var normalImage: NSImage?
    var hoveredImage: NSImage?
    var tip: String?
    
    init(normalImage: NSImage?, hoveredImage: NSImage?) {
        self.normalImage = normalImage
        self.hoveredImage = hoveredImage
        super.init(frame: NSZeroRect)
        self.image = self.normalImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        trackingAreas.forEach { area in
            removeTrackingArea(area)
        }
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways], owner: self)
        addTrackingArea(trackingArea)
        let mouseLocation = self.window?.mouseLocationOutsideOfEventStream
        if let location = mouseLocation {
            let newLocation = self.convert(location, from: nil)
            
            if NSPointInRect(newLocation, bounds) {
                self.mouseEntered(with: NSEvent())
            } else {
                self.mouseExited(with: NSEvent())
            }
        }
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.image = hoveredImage
        self.toolTip = tip
    }
    
    override func mouseExited(with event: NSEvent) {
        self.image = normalImage
        self.toolTip = nil
    }
    
}
