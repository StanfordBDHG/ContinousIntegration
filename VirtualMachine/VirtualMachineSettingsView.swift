//
// This source file is part of the Stanford BDGH VirtualMachine project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Virtualization


struct VirtualMachineSettingsView: View {
    @AppStorage(VirtualMachineSettings.StorageKeys.vmBundlePath) private var vmBundlePath: String = VirtualMachineSettings.Defaults.vmBundlePath
    // Memory size in GB
    @AppStorage("memorySize") private var memorySize: Double = 8
    
    
    private var minimumAllowedMemorySize: Double {
        max(4.0, roundToGBWithOneDecimalPoint(VZVirtualMachineConfiguration.minimumAllowedMemorySize))
    }
    
    private var maximumAllowedMemorySize: Double {
        roundToGBWithOneDecimalPoint(VZVirtualMachineConfiguration.maximumAllowedMemorySize)
    }
    
    private var memorySizeProxy: Binding<Double>{
        Binding(
            get: {
                Double(memorySize)
            },
            set: { newValue in
                memorySize = round(newValue * 10) / 10.0
            }
        )
    }

    var body: some View {
        Form {
            TextField(text: $vmBundlePath) {
                Text("Bundle Path")
            }
            Slider(value: memorySizeProxy, in: minimumAllowedMemorySize...maximumAllowedMemorySize) {
                Text("Memory Size (\(memorySize, specifier: "%.1f") GB)")
            }
        }
            .padding(20)
            .frame(width: 500, height: 200)
    }
    
    
    private func roundToGBWithOneDecimalPoint(_ size: UInt64) -> Double {
        // In GB times 10 so we can round to one decimal.
        let sizeInGBTimes10 = Double((size * 10) / (1024 * 1024 * 1024))
        // Round and then devide by 10 so we get back to GB
        return round(sizeInGBTimes10) / 10.0
    }
}
