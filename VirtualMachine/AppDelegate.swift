//
// This source file is part of the Stanford BDGH VirtualMachine project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import AppKit
import Virtualization


class AppDelegate: NSObject, NSApplicationDelegate {
    var virtualMachineManager = VirtualMachineManager()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Task {
            await virtualMachineManager.applicationDidFinishLaunching()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        virtualMachineManager.applicationShouldTerminate(sender)
    }
}
