//
//  AppDelegate.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
//

import Cocoa
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate {

    let windowController = MainWindowController()

    var updaterController: SPUStandardUpdaterController!
    
    var statusItem: NSStatusItem?
    
    override init() {
        super.init()
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: self, userDriverDelegate: nil)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.windowController.window?.makeKeyAndOrderFront(nil)
        
        // 设置状态栏菜单
        guard let menu = NSApp.mainMenu else { return }
        let submenu = NSMenu()
        submenu.addItem(NSMenuItem(title: "检查更新", action: #selector(checkUpdate), keyEquivalent: ""))
        menu.setSubmenu(submenu, for: menu.items.first!)
        NSApp.mainMenu = menu
    }

    @objc func checkUpdate() {
        updaterController.checkForUpdates(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

