//
// This source file is part of the Stanford BDGH VirtualMachine project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MainView: View {
    @EnvironmentObject private var virtualMachineManager: VirtualMachineManager
    
    private var presentError: Binding<Bool> {
        Binding(
            get: {
                virtualMachineManager.virtualMachineError != nil
            },
            set: { newValue in
                if !newValue {
                    virtualMachineManager.virtualMachineError = nil
                }
            }
        )
    }
    
    
    var body: some View {
        Group {
            if virtualMachineManager.virtualMachine == nil {
                Text("No Virtual Machine")
                Button("Reload") {
                    Task {
                        await virtualMachineManager.applicationDidFinishLaunching()
                    }
                }
            } else {
                VirtualMachineView(virtualMachine: virtualMachineManager.virtualMachine)
            }
        }
            .alert(
                "Virtual Machine Error",
                isPresented: presentError,
                presenting: virtualMachineManager.virtualMachineError,
                actions: { _ in
                    Button("OK") {}
                },
                message: { error in
                    Text("\(error)")
                }
            )
    }
}
