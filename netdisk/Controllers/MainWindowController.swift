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
        ZigClientManager.shared.mainWindowController = self
        ZigUserManager.sharedInstance.delegate = self
        ABProgressHUD.showHUD()
        ZigUserManager.sharedInstance.requestUserData { success in
            DispatchQueue.main.async { [weak self] in
                ABProgressHUD.hideHUD()
                guard let self = self, let window = self.window else { return }
                if success {
                    // 已登录
                    self.mainVC = MainViewController()
                    window.contentView = self.mainVC.view;
                    window.contentViewController = self.mainVC
                    window.animateToSize(CGSize(width: 1120, height: 640))
                    window.minSize = CGSize(width: 998, height: 636)
                    NotificationCenter.default.post(name: NSNotification.Name(Const.DidLoginNotificationName), object: nil)
                } else {
                    // 未登录
                    self.loginVC = LoginViewController()
                    self.loginVC.windowController = self
                    window.contentView = self.loginVC.view;
                    window.contentViewController = self.loginVC
                    window.animateToSize(CGSize(width: 280, height: 400))
                    window.minSize = CGSize(width: 280, height: 400)
                }
            }
        }
    }
    
    override func loadWindow() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 280, height: 400)
        let style: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        let back: NSWindow.BackingStoreType = .buffered
        let window = NSWindow(contentRect: frame, styleMask: style, backing: back, defer: false)
        window.minSize = CGSize(width: 280, height: 400)
        window.titlebarAppearsTransparent = true
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        self.window?.miniaturize(nil)
        return false
    }
    
    func loginSuccess() {
        ABProgressHUD.showHUD()
        ZigUserManager.sharedInstance.requestUserData { success in
            DispatchQueue.main.async { [weak self] in
                ABProgressHUD.hideHUD()
                if success {
                    guard let self = self else { return }
                    window?.animateToSize(CGSize(width: 1120, height: 640))
                    self.mainVC = MainViewController()
                    self.window?.contentView = self.mainVC.view;
                    self.window?.contentViewController = self.mainVC
                    NotificationCenter.default.post(name: NSNotification.Name(Const.DidLoginNotificationName), object: nil)
                }
            }
        }
    }
    
    func exitLogin() {
        self.window?.animateToSize(CGSize(width: 280, height: 400))
        self.loginVC = LoginViewController()
        self.loginVC.windowController = self
        self.window?.contentView = self.loginVC.view;
        self.window?.contentViewController = self.loginVC
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
        self.window?.animateToSize(CGSize(width: 280, height: 400))
    }
}
