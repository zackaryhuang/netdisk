//
//  MainWindowController.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    var loginVC: LoginViewController!
    
    var mainVC: MainViewController!
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func loadWindow() {
        debugPrint(NSFontManager.shared.availableFontFamilies.description)
        ZigUserManager.sharedInstance.delegate = self
        let frame: CGRect = CGRect(x: 0, y: 0, width: 280, height: 400)
        let style: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
        let back: NSWindow.BackingStoreType = .buffered
        let window: NSWindow = NSWindow(contentRect: frame, styleMask: style, backing: back, defer: false)
        window.titlebarAppearsTransparent = true
        window.delegate = self
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.center()
        self.window = window
        ZigUserManager.sharedInstance.requestUserData { success in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if success {
                    // 已登录
                    self.mainVC = MainViewController()
                    window.contentView = self.mainVC.view;
                    window.contentViewController = self.mainVC
                    window.setFrame(NSMakeRect(0, 0, 1120, 640), display: true, animate: false)
                    NotificationCenter.default.post(name: NSNotification.Name(Const.DidLoginNotificationName), object: nil)
                } else {
                    // 未登录
                    self.loginVC = LoginViewController()
                    self.loginVC.windowController = self
                    window.contentView = self.loginVC.view;
                    window.contentViewController = self.loginVC
                }
                window.center()
            }
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        exit(0)
    }
    
    func loginSuccess() {
        ZigUserManager.sharedInstance.requestUserData { success in
            if success {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.mainVC = MainViewController()
                    self.window?.contentView = self.mainVC.view;
                    self.window?.contentViewController = self.mainVC
                    NotificationCenter.default.post(name: NSNotification.Name(Const.DidLoginNotificationName), object: nil)
                    
                    let oldX = self.window?.frame.origin.x ?? 0.0
                    let oldY = self.window?.frame.origin.y ?? 0.0
                    let oldW = self.window?.frame.size.width ?? 0.0
                    let oldH = self.window?.frame.size.height ?? 0.0
                    
                    let oldCenter = CGPoint(x: oldX + oldW / 2.0, y: oldY + oldH / 2.0)
                    
                    let newW = 1120.0
                    let newH = 640.0
                    let newX = oldCenter.x - newW / 2.0
                    
                    let newY = oldCenter.y - newH / 2.0
                    
                    NSAnimationContext.runAnimationGroup({context in
                      context.duration = 0.25
                      context.allowsImplicitAnimation = true
                        self.window?.setFrame(NSMakeRect(newX, newY, newW, newH), display: true)
                    }, completionHandler:nil)
                }
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.windowController.window?.makeFirstResponder(nil)
        }
    }
}

extension MainWindowController: ZigUserManagerDelegate {
    func loginDataExpired() {
        window?.contentView = loginVC.view;
        window?.contentViewController = loginVC
        loginVC.windowController = self
        
        let oldX = window?.frame.origin.x ?? 0.0
        let oldY = window?.frame.origin.y ?? 0.0
        let oldW = window?.frame.size.width ?? 0.0
        let oldH = window?.frame.size.height ?? 0.0
        
        let oldCenter = CGPoint(x: oldX + oldW / 2.0, y: oldY + oldH / 2.0)
        
        let newW = 292.0
        let newH = 412.0
        let newX = oldCenter.x - newW / 2.0
        
        let newY = oldCenter.y - newH / 2.0
        
        NSAnimationContext.runAnimationGroup({context in
          context.duration = 0.25
          context.allowsImplicitAnimation = true
            self.window?.setFrame(NSMakeRect(newX, newY, newW, newH), display: true)
        }, completionHandler:nil)
    }
}
