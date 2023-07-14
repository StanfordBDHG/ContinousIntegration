//
// This source file is part of the Stanford BDGH VirtualMachine project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SettingsView: View {
    private enum Tabs: Hashable {
        case virtualMachine
    }
    
    
    var body: some View {
        TabView {
            VirtualMachineSettingsView()
                .tabItem {
                    Label("Virtual Machine", systemImage: "desktopcomputer")
                }
                .tag(Tabs.virtualMachine)
        }
            .padding(20)
    }
}
