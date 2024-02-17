//
//  llmosApp.swift
//  llmos
//
//  Created by Ethan Shaotran on 2/16/24.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.borderless], // This makes the window frameless
            backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear // Makes the window background transparent
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.level = .floating // Keeps the window on top of other windows
        window.center() // Centers the window on the screen, but you can set it to the corner
    }
}
