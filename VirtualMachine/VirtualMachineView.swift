//
// This source file is part of the Stanford BDGH VirtualMachine project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Virtualization


struct VirtualMachineView: NSViewRepresentable {
    let virtualMachine: VZVirtualMachine?
    
    
    func makeNSView(context: Context) -> VZVirtualMachineView {
        let virtualMachineView = VZVirtualMachineView()
        
        virtualMachineView.capturesSystemKeys = true
        
        if #available(macOS 14.0, *) {
            // Configure the app to automatically respond to changes in the display size.
            virtualMachineView.automaticallyReconfiguresDisplay = true
        }
        
        return virtualMachineView
    }
    
    func updateNSView(_ virtualMachineView: VZVirtualMachineView, context: Context) {
        virtualMachineView.virtualMachine = virtualMachine
    }
}
