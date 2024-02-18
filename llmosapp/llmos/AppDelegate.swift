
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the application has at least one window
        guard let window = NSApp.windows.first else { return }
        
        window.styleMask = [.borderless] // Make window borderless
        window.isOpaque = false
        window.backgroundColor = .clear // Make the window's background clear
        window.alphaValue = 1  // Make the window fully transparent
        // window.setIsVisible(false) // Hide the window
        
        registerGlobalKeyboardShortcut()
    }
    
    private func registerGlobalKeyboardShortcut() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            // Check for Command + Return
            if event.modifierFlags.contains(.command) && event.keyCode == 0x24 { // 0x24 is the virtual key code for Return
                self.showMainWindow()
            }
        }
    }
    
    func showMainWindow() {
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
