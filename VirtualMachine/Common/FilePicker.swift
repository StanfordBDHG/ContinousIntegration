//
// This source file is part of the Stanford BDGH VirtualMachine project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct FilePicker: View {
    @Binding var filePath: String

    var body: some View {
        Button(
            action: {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                if panel.runModal() == .OK {
                    guard let path = panel.url?.path() else {
                        return
                    }
                    self.filePath = path
                }
            }, label: {
                Image(systemName: "folder")
            }
        )
    }
}
