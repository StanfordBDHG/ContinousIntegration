//
// This source file is part of the Stanford BDGH VirtualMachine project
// Based on https://developer.apple.com/documentation/virtualization/running_macos_in_a_virtual_machine_on_apple_silicon
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Virtualization


class VirtualMachineManager: ObservableObject {
    @Published var virtualMachineError: String?
    @Published var virtualMachine: VZVirtualMachine?
    
    private var virtualMachineResponder: MacOSVirtualMachineDelegate?
    
    
    @MainActor
    func applicationDidFinishLaunching() async {
        #if arch(arm64)
        createVirtualMachine()
        virtualMachineResponder = MacOSVirtualMachineDelegate()
        virtualMachine?.delegate = virtualMachineResponder
        
        if #available(macOS 14.0, *) {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: VirtualMachineSettings.saveFileURL.path) {
                await restoreVirtualMachine()
            } else {
                await startVirtualMachine()
            }
        } else {
            await startVirtualMachine()
        }
        #else
        virtualMachineError = "The Virtuale Machine App is only supported on Apple Silicon Macs"
        #endif
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        #if arch(arm64)
        if #available(macOS 14.0, *) {
            if virtualMachine?.state == .running {
                Task {
                    await pauseAndSaveVirtualMachine()
                    await sender.reply(toApplicationShouldTerminate: true)
                }
                
                return .terminateLater
            }
        }
        #endif
        
        return .terminateNow
    }
    
    #if arch(arm64)
    // Create the Mac platform configuration.
    private func createMacPlaform() -> VZMacPlatformConfiguration {
        let macPlatform = VZMacPlatformConfiguration()
        
        let auxiliaryStorage = VZMacAuxiliaryStorage(contentsOf: VirtualMachineSettings.auxiliaryStorageURL)
        macPlatform.auxiliaryStorage = auxiliaryStorage
        
        guard FileManager.default.fileExists(atPath: VirtualMachineSettings.vmBundlePath) else {
            virtualMachineError = "Missing Virtual Machine Bundle at \(VirtualMachineSettings.vmBundlePath). Run InstallationTool first to create it."
            return macPlatform
        }
        
        // Retrieve the hardware model and save this value to disk
        // during installation.
        guard let hardwareModelData = try? Data(contentsOf: VirtualMachineSettings.hardwareModelURL) else {
            virtualMachineError = "Failed to retrieve hardware model data."
            return macPlatform
        }
        
        guard let hardwareModel = VZMacHardwareModel(dataRepresentation: hardwareModelData) else {
            virtualMachineError = "Failed to create hardware model."
            return macPlatform
        }
        
        if !hardwareModel.isSupported {
            virtualMachineError = "The hardware model isn't supported on the current host"
            return macPlatform
        }
        macPlatform.hardwareModel = hardwareModel
        
        // Retrieve the machine identifier and save this value to disk
        // during installation.
        guard let machineIdentifierData = try? Data(contentsOf: VirtualMachineSettings.machineIdentifierURL) else {
            virtualMachineError = "Failed to retrieve machine identifier data."
            return macPlatform
        }
        
        guard let machineIdentifier = VZMacMachineIdentifier(dataRepresentation: machineIdentifierData) else {
            virtualMachineError = "Failed to create machine identifier."
            return macPlatform
        }
        macPlatform.machineIdentifier = machineIdentifier
        
        return macPlatform
    }
    
    // MARK: Create the virtual machine configuration and instantiate the virtual machine.
    
    private func createVirtualMachine() {
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        
        virtualMachineConfiguration.platform = createMacPlaform()
        virtualMachineConfiguration.bootLoader = MacOSVirtualMachineConfigurationHelper.createBootLoader()
        virtualMachineConfiguration.cpuCount = MacOSVirtualMachineConfigurationHelper.computeCPUCount()
        virtualMachineConfiguration.memorySize = MacOSVirtualMachineConfigurationHelper.computeMemorySize()
        virtualMachineConfiguration.graphicsDevices = [MacOSVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration()]
        do {
            virtualMachineConfiguration.storageDevices = [try MacOSVirtualMachineConfigurationHelper.createBlockDeviceConfiguration()]
        } catch {
            virtualMachineError = "Failed to load the Disk image."
            return
        }
        virtualMachineConfiguration.networkDevices = [MacOSVirtualMachineConfigurationHelper.createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.pointingDevices = [MacOSVirtualMachineConfigurationHelper.createPointingDeviceConfiguration()]
        virtualMachineConfiguration.keyboards = [MacOSVirtualMachineConfigurationHelper.createKeyboardConfiguration()]
        
        do {
            try virtualMachineConfiguration.validate()
            
            if #available(macOS 14.0, *) {
                try virtualMachineConfiguration.validateSaveRestoreSupport()
            }
        } catch {
            virtualMachineError = "Failed to validate the virtual machine settings: \(error)"
            return
        }
        
        virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
    }
    
    // MARK: Start, restore, and save the virtual machine.
    private func startVirtualMachine() async {
        do {
            try await virtualMachine?.start()
        } catch {
            virtualMachineError = "Virtual machine failed to start with \(error)"
        }
    }
    
    private func resumeVirtualMachine() async {
        do {
            try await virtualMachine?.resume()
        } catch {
            virtualMachineError = "Virtual machine failed to resume with \(error)"
        }
    }
    
    @available(macOS 14.0, *)
    private func saveVirtualMachine() async {
        do {
            try await virtualMachine?.saveMachineStateTo(url: VirtualMachineSettings.saveFileURL)
        } catch {
            virtualMachineError = "Virtual machine failed to save with \(error)"
        }
    }
    
    @available(macOS 14.0, *)
    private func pauseAndSaveVirtualMachine() async {
        do {
            try await virtualMachine?.pause()
        } catch {
            virtualMachineError = "Virtual machine failed to pause with \(error)"
        }
        
        await self.saveVirtualMachine()
    }
    
    @available(macOS 14.0, *)
    private func restoreVirtualMachine() async {
        do {
            defer {
                let fileManager = FileManager.default
                try! fileManager.removeItem(at: VirtualMachineSettings.saveFileURL)
            }
            
            try await virtualMachine?.restoreMachineStateFrom(url: VirtualMachineSettings.saveFileURL)
            await self.resumeVirtualMachine()
        } catch {
            await self.startVirtualMachine()
        }
    }
    #endif
}
