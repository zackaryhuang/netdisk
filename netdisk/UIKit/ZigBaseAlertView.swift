//
//  ZigBaseAlertView.swift
//  netdisk
//
//  Created by Zackary on 2024/4/13.
//

import Cocoa

class ZigBaseAlertView: NSView {

    let contentView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x252528).cgColor
        view.layer?.cornerRadius = 13
        return view
    }()
    
    func showInView(_ view: NSView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        FileRowView.shouldHandleTracking = false
        
        NSView.animate(withDuration: 0.3) {
            self.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.5).cgColor
            self.contentView.alphaValue = 1
        }
    }
    
    func dismiss() {
        NSView.animate(withDuration: 0.3) {
            self.layer?.backgroundColor = NSColor(hex: 0x000000, alpha: 0.0).cgColor
            self.contentView.alphaValue = 0
        } completion: {
            FileRowView.shouldHandleTracking = true
            self.removeFromSuperview()
        }

    }
}
