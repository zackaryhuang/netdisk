//
//  MainWindowController.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {

    var loginVC = LoginViewController()
    
    var mainVC = MainViewController()
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func loadWindow() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 280, height: 400)
        let style: NSWindow.StyleMask = [.titled, .closable, .fullSizeContentView]
        let back: NSWindow.BackingStoreType = .buffered
        let window: NSWindow = NSWindow(contentRect: frame, styleMask: style, backing: back, defer: false)
        window.titlebarAppearsTransparent = true
        window.delegate = self
        if isLogin() {
            window.contentView = mainVC.view;
            window.contentViewController = mainVC
            window.setFrame(NSMakeRect(0, 0, 830, 556), display: true, animate: true)
        } else {
            loginVC.windowController = self
            window.contentView = loginVC.view;
            window.contentViewController = loginVC
        }
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.center()
        self.window = window
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        exit(0)
    }
    
    func loginSuccess() {
        window?.contentView = mainVC.view;
        window?.contentViewController = mainVC
        window?.setFrame(NSMakeRect(0, 0, 830, 556), display: true, animate: false)
        window?.center()
    }
    
    func isLogin() -> Bool {
        return UserDefaults.standard.object(forKey: "UserAccessToken") != nil
    }
}
