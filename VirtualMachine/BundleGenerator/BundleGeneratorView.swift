//
// This source file is part of the Stanford BDGH VirtualMachine project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct BundleGeneratorView: View {
    @StateObject private var macOSVirtualMachineInstaller = MacOSVirtualMachineInstaller()
    @State private var ipswPath = ""
    
    
    private var presentError: Binding<Bool> {
        Binding(
            get: {
                macOSVirtualMachineInstaller.machineInstallerError != nil
            },
            set: { newValue in
                if !newValue {
                    macOSVirtualMachineInstaller.machineInstallerError = nil
                }
            }
        )
    }
    
    var body: some View {
        VStack {
            Text(macOSVirtualMachineInstaller.state ?? "macOS Virtual Machine Generator idle.")
            HStack {
                TextField(text: $ipswPath) {
                    Text("Optional IPSW Path")
                }
                FilePicker(filePath: $ipswPath)
            }
            Button("Create macOS Virtual Machine") {
                createMacOSVirtualMachine()
            }
                .disabled(macOSVirtualMachineInstaller.state != nil)
        }
            .frame(maxWidth: 500)
            .padding(.horizontal)
            .alert(
                "Virtual Machine Error",
                isPresented: presentError,
                presenting: macOSVirtualMachineInstaller.machineInstallerError,
                actions: { _ in
                    Button("OK") {}
                },
                message: { error in
                    Text("\(error)")
                }
            )
    }
    
    
    private func createMacOSVirtualMachine() {
        if !ipswPath.isEmpty {
            let ipswURL = URL(fileURLWithPath: ipswPath)
            guard ipswURL.isFileURL else {
                macOSVirtualMachineInstaller.machineInstallerError = "The provided IPSW path is not a valid file URL."
                return
            }
            
            macOSVirtualMachineInstaller.setUpVirtualMachineArtifacts()
            macOSVirtualMachineInstaller.installMacOS(ipswURL: ipswURL)
        } else {
            macOSVirtualMachineInstaller.setUpVirtualMachineArtifacts()
            macOSVirtualMachineInstaller.download {
                // Install from the restore image that you downloaded.
                macOSVirtualMachineInstaller.installMacOS(ipswURL: VirtualMachineSettings.restoreImageURL)
            }
        }
    }
}
