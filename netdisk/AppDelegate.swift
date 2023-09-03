//
//  AppDelegate.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    let windowController = MainWindowController()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.windowController.window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

