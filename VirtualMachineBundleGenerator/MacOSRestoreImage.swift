//
// This source file is part of the Stanford BDGH VirtualMachine project
// Based on https://developer.apple.com/documentation/virtualization/running_macos_in_a_virtual_machine_on_apple_silicon
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Virtualization


#if arch(arm64)
class MacOSRestoreImage: NSObject {
    private var downloadObserver: NSKeyValueObservation?
    
    
    //Observe the download progress.
    public func download(completionHandler: @escaping () -> Void) {
        NSLog("Attempting to download latest available restore image.")
        VZMacOSRestoreImage.fetchLatestSupported { [self](result: Result<VZMacOSRestoreImage, Error>) in
            switch result {
            case let .failure(virtualMachineError):
                fatalError(virtualMachineError.localizedDescription)
                
            case let .success(restoreImage):
                downloadRestoreImage(restoreImage: restoreImage, completionHandler: completionHandler)
            }
        }
    }
    
    // Download the restore image from the network.
    private func downloadRestoreImage(restoreImage: VZMacOSRestoreImage, completionHandler: @escaping () -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: restoreImage.url) { localURL, response, virtualMachineError in
            if let virtualMachineError = virtualMachineError {
                fatalError("Download failed. \(virtualMachineError.localizedDescription).")
            }
            
            guard (try? FileManager.default.moveItem(at: localURL!, to: VirtualMachineSettings.restoreImageURL)) != nil else {
                fatalError("Failed to move downloaded restore image to \(VirtualMachineSettings.restoreImageURL).")
            }
            
            completionHandler()
        }
        
        downloadObserver = downloadTask.progress.observe(\.fractionCompleted, options: [.initial, .new]) { (progress, change) in
            NSLog("Restore image download progress: \(change.newValue! * 100).")
        }
        downloadTask.resume()
    }
}
#endif
