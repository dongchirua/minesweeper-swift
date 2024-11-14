//
//  AppDelegate.swift
//  Minesweeper
//
//  Created by Alain Gilbert on 3/10/18.
//  Copyright © 2018 None. All rights reserved.
//

import Cocoa

@main
class App: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create your main window and initialize your application here.
        // This is where you would usually create an instance of your main window controller
        // and show the window.
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
