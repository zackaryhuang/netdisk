//
//  MainWindowController.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
//

import Cocoa
import Kingfisher
import Alamofire

class ImagePreviewWindowController: NSWindowController, NSWindowDelegate {
    
    var detailInfo: FileDetailInfo?
    
    let imagePreviewController = ImagePreviewController()
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
    }
    
    override func loadWindow() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 280, height: 400)
        let style: NSWindow.StyleMask = [.titled, .closable, .resizable, .fullSizeContentView]
        let back: NSWindow.BackingStoreType = .buffered
        let window: NSWindow = NSWindow(contentRect: frame, styleMask: style, backing: back, defer: false)
        window.titlebarAppearsTransparent = true
        window.maxSize = NSMakeSize(720, 576)
        window.center()
        window.delegate = self
        imagePreviewController.detailInfo = detailInfo
        imagePreviewController.window = window
        window.contentViewController = imagePreviewController
        window.contentView = imagePreviewController.view
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        self.window = window
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        exit(0)
    }
}
