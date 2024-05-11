//
//  AppDelegate.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
//

import Cocoa
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {

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
        submenu.addItem(NSMenuItem(title: "退出 ABCloud", action: #selector(exit), keyEquivalent: ""))
        menu.setSubmenu(submenu, for: menu.items.first!)
        NSApp.mainMenu = menu
        
        checkUpdate()
    }

    @objc func exit() {
        guard let contentView = NSApplication.shared.windows.first?.contentView else { return }
        let alert = ZigTextAlertView(title: "退出", message: "确认退出吗？")
        alert.confirmBlock = {
            _SwiftConcurrencyShims.exit(0)
        }
        alert.showInView(contentView)
    }
    
    @objc func checkUpdate() {
        updaterController.checkForUpdates(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        debugPrint(appcast.items)
    }
    
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        debugPrint("failed")
    }
    
    func updater(_ updater: SPUUpdater, didFinishUpdateCycleFor updateCheck: SPUUpdateCheck, error: (any Error)?) {
        debugPrint("\(error?.localizedDescription ?? "succeed")")
    }
}

