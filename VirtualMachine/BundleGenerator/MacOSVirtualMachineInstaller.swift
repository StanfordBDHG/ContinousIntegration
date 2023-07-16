//
// This source file is part of the Stanford BDGH VirtualMachine project
// Based on https://developer.apple.com/documentation/virtualization/running_macos_in_a_virtual_machine_on_apple_silicon
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Virtualization


#if arch(arm64)
class MacOSVirtualMachineInstaller: NSObject, ObservableObject {
    private var installationObserver: NSKeyValueObservation?
    private var downloadObserver: NSKeyValueObservation?
    private var virtualMachine: VZVirtualMachine!
    private var virtualMachineResponder: MacOSVirtualMachineDelegate?
    
    @Published var state: String?
    @Published var machineInstallerError: String? {
        didSet {
            if machineInstallerError != nil {
                state = "Installation Failed"
            }
        }
    }
    
    
    // Create a bundle on the user's Home directory to store any artifacts
    // that the installation produces.
    public func setUpVirtualMachineArtifacts() {
        createVMBundle()
    }
    
    
    //Observe the download progress.
    public func download(completionHandler: @escaping () -> Void) {
        state = "Attempting to download latest available restore image."
        VZMacOSRestoreImage.fetchLatestSupported { [self](result: Result<VZMacOSRestoreImage, Error>) in
            switch result {
            case let .failure(virtualMachineError):
                machineInstallerError = virtualMachineError.localizedDescription
                return
            case let .success(restoreImage):
                downloadRestoreImage(restoreImage: restoreImage, completionHandler: completionHandler)
            }
        }
    }
    
    // Download the restore image from the network.
    private func downloadRestoreImage(restoreImage: VZMacOSRestoreImage, completionHandler: @escaping () -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: restoreImage.url) { localURL, response, virtualMachineError in
            if let virtualMachineError = virtualMachineError {
                self.machineInstallerError = "Download failed. \(virtualMachineError.localizedDescription)."
                return
            }
            
            guard (try? FileManager.default.moveItem(at: localURL!, to: VirtualMachineSettings.restoreImageURL)) != nil else {
                self.machineInstallerError = "Failed to move downloaded restore image to \(VirtualMachineSettings.restoreImageURL)."
                return
            }
            
            completionHandler()
        }
        
        downloadObserver = downloadTask.progress.observe(\.fractionCompleted, options: [.initial, .new]) { (progress, change) in
            Task { @MainActor in
                self.state = "Restore image download progress: \((change.newValue ?? 0.0) * 100)."
            }
        }
        
        downloadTask.resume()
    }
    
    // Install macOS onto the virtual machine from IPSW.
    public func installMacOS(ipswURL: URL) {
        state = "Attempting to install from IPSW at \(ipswURL)."
        VZMacOSRestoreImage.load(from: ipswURL, completionHandler: { [self](result: Result<VZMacOSRestoreImage, Error>) in
            switch result {
            case let .failure(virtualMachineError):
                machineInstallerError = virtualMachineError.localizedDescription
                return
            case let .success(restoreImage):
                installMacOS(restoreImage: restoreImage)
            }
        })
    }
    
    
    // Internal helper functions.
    private func installMacOS(restoreImage: VZMacOSRestoreImage) {
        guard let macOSConfiguration = restoreImage.mostFeaturefulSupportedConfiguration else {
            machineInstallerError = "No supported configuration available."
            return
        }
        
        guard macOSConfiguration.hardwareModel.isSupported else {
            machineInstallerError = "macOSConfiguration configuration isn't supported on the current host."
            return
        }
        
        DispatchQueue.main.async { [self] in
            setupVirtualMachine(macOSConfiguration: macOSConfiguration)
            startInstallation(restoreImageURL: restoreImage.url)
        }
    }
    
    // Create the Mac platform configuration.
    private func createMacPlatformConfiguration(macOSConfiguration: VZMacOSConfigurationRequirements) -> VZMacPlatformConfiguration {
        let macPlatformConfiguration = VZMacPlatformConfiguration()
        
        guard let auxiliaryStorage = try? VZMacAuxiliaryStorage(
            creatingStorageAt: VirtualMachineSettings.auxiliaryStorageURL,
            hardwareModel: macOSConfiguration.hardwareModel,
            options: []
        ) else {
            machineInstallerError = "Failed to create auxiliary storage."
            return macPlatformConfiguration
        }
        macPlatformConfiguration.auxiliaryStorage = auxiliaryStorage
        macPlatformConfiguration.hardwareModel = macOSConfiguration.hardwareModel
        macPlatformConfiguration.machineIdentifier = VZMacMachineIdentifier()
        
        // Store the hardware model and machine identifier to disk so that you
        // can retrieve them for subsequent boots.
        try! macPlatformConfiguration.hardwareModel.dataRepresentation.write(to: VirtualMachineSettings.hardwareModelURL)
        try! macPlatformConfiguration.machineIdentifier.dataRepresentation.write(to: VirtualMachineSettings.machineIdentifierURL)
        
        return macPlatformConfiguration
    }
    
    // Create the virtual machine configuration and instantiate the virtual machine.
    private func setupVirtualMachine(macOSConfiguration: VZMacOSConfigurationRequirements) {
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        
        virtualMachineConfiguration.platform = createMacPlatformConfiguration(macOSConfiguration: macOSConfiguration)
        virtualMachineConfiguration.cpuCount = MacOSVirtualMachineConfigurationHelper.computeCPUCount()
        guard virtualMachineConfiguration.cpuCount > macOSConfiguration.minimumSupportedCPUCount else {
            machineInstallerError = "CPUCount isn't supported by the macOS configuration."
            return
        }
        
        virtualMachineConfiguration.memorySize = MacOSVirtualMachineConfigurationHelper.computeMemorySize()
        guard virtualMachineConfiguration.memorySize > macOSConfiguration.minimumSupportedMemorySize else {
            machineInstallerError = "memorySize isn't supported by the macOS configuration."
            return
        }
        
        // Create a 200 GB disk image.
        createDiskImage()
        
        virtualMachineConfiguration.bootLoader = MacOSVirtualMachineConfigurationHelper.createBootLoader()
        virtualMachineConfiguration.graphicsDevices = [MacOSVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration()]
        virtualMachineConfiguration.storageDevices = [try! MacOSVirtualMachineConfigurationHelper.createBlockDeviceConfiguration()]
        virtualMachineConfiguration.networkDevices = [MacOSVirtualMachineConfigurationHelper.createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.pointingDevices = [MacOSVirtualMachineConfigurationHelper.createPointingDeviceConfiguration()]
        virtualMachineConfiguration.keyboards = [MacOSVirtualMachineConfigurationHelper.createKeyboardConfiguration()]
        
        try! virtualMachineConfiguration.validate()
        
        if #available(macOS 14.0, *) {
            try! virtualMachineConfiguration.validateSaveRestoreSupport()
        }
        
        virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
        virtualMachineResponder = MacOSVirtualMachineDelegate()
        virtualMachine.delegate = virtualMachineResponder
    }
    
    // Begin macOS installation.
    private func startInstallation(restoreImageURL: URL) {
        let installer = VZMacOSInstaller(virtualMachine: virtualMachine, restoringFromImageAt: restoreImageURL)
        
        state = "Starting installation."
        installer.install { (result: Result<Void, Error>) in
            if case let .failure(virtualMachineError) = result {
                self.machineInstallerError = virtualMachineError.localizedDescription
                return
            } else {
                self.state = "Installation succeeded."
            }
        }
        
        // Observe installation progress.
        installationObserver = installer.progress.observe(\.fractionCompleted, options: [.initial, .new]) { (progress, change) in
            Task { @MainActor in
                self.state = "Installation progress: \((change.newValue ?? 0.0) * 100)."
            }
        }
    }
    
    private func createVMBundle() {
        let bundleFd = mkdir(VirtualMachineSettings.vmBundlePath, S_IRWXU | S_IRWXG | S_IRWXO)
        guard bundleFd != -1 else {
            if errno == EEXIST {
                machineInstallerError = "Failed to create VM.bundle: the base directory already exists."
            } else {
                machineInstallerError = "Failed to create VM.bundle."
            }
            return
        }
        
        let result = close(bundleFd)
        guard result == 0 else {
            machineInstallerError = "Failed to close VM.bundle."
            return
        }
    }
    
    // Create an empty disk image for the virtual machine.
    private func createDiskImage() {
        let diskFd = open(VirtualMachineSettings.diskImageURL.path, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR)
        guard diskFd != -1 else {
            machineInstallerError = "Cannot create disk image."
            return
        }
        
        // 200 GB disk space.
        var result = ftruncate(diskFd, 200 * 1024 * 1024 * 1024)
        guard result == 0 else {
            machineInstallerError = "ftruncate() failed."
            return
        }
        
        result = close(diskFd)
        guard result == 0 else {
            machineInstallerError = "Failed to close the disk image."
            return
        }
    }
}
#endif
