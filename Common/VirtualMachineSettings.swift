//
// This source file is part of the Stanford BDGH VirtualMachine project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum VirtualMachineSettings {
    enum StorageKeys {
        static let vmBundlePath = "VMBundlePath"
    }
    
    enum Defaults {
        static let vmBundlePath = "/VirtualMachine.bundle/"
    }
    
    
    @AppStorage(StorageKeys.vmBundlePath) static var vmBundlePath: String = Defaults.vmBundlePath
    
    
    static var vmBundleURL: URL {
        URL(fileURLWithPath: vmBundlePath)
    }
    static var auxiliaryStorageURL: URL {
        vmBundleURL.appendingPathComponent("AuxiliaryStorage")
    }
    static var diskImageURL: URL {
        vmBundleURL.appendingPathComponent("Disk.img")
    }
    static var hardwareModelURL: URL {
        vmBundleURL.appendingPathComponent("HardwareModel")
    }
    static var machineIdentifierURL: URL {
        vmBundleURL.appendingPathComponent("MachineIdentifier")
    }
    static var restoreImageURL: URL {
        vmBundleURL.appendingPathComponent("RestoreImage.ipsw")
    }
    static var saveFileURL: URL {
        vmBundleURL.appendingPathComponent("SaveFile.vzvmsave")
    }
}
