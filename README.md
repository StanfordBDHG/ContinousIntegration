<!--

This source file is part of the Stanford BDGH VirtualMachine project

SPDX-FileCopyrightText: 2023 Stanford University

SPDX-License-Identifier: MIT

-->

# Virtual Machine Host Tool

Small project based on the [Running macOS in a virtual machine on Apple silicon](https://developer.apple.com/documentation/virtualization/running_macos_in_a_virtual_machine_on_apple_silicon) example application used to host the virtual machines for the build setup of the Stanford Biodesign Digital Health Group.

The repository also consists of scripts and additional setups used for maintaining the build agents.

## Stanford BDHG CI Setup

The CI setup for GitHub Actions runners uses the Virtual Machine app to host a virtual machine that we use as a GitHub Action runner.
The repository contains the nescessary steps, tools, and scripts to setup the environment.
1. Setup a macOS machine on conformance to the Stanford device setup requirements: https://uit.stanford.edu/service/StanfordJamf/Install.
2. Install the Virtual Machine App. Setup the application to "Open on Login" using the macOS dock context menu of the app.
3. Either generate new virtual machine bundle using the app or use a prexisting bundle. If you use a prexisting bundle that has done all the following steps you can skip the setup steps.
4. Start the VM using the app, go through the setup process with the minimal possible setup, e.g. **no** location services, **no** Apple ID, and more ...
5. Setup that the user of the VM automatically logged in when the VM starts: https://support.apple.com/en-au/HT201476.
6. Disable automatic screen saves, turning off the display, and requiering a passcode when the screen is locked (https://support.apple.com/guide/mac-help/set-sleep-and-wake-settings-mchle41a6ccd/mac) and enable the perserve automatic sleeping when the display if off setting in the System Settings > Displays > Advanced settings.
6. Download this repository from GitHub to the VM and run the installation steps by adapting the `.env` file in the `Installation` folder and runnig `$ sh install.sh` in the `Installation` folder. Optionally change the installed Xcode versions in the script.
7. Ensure that the GitHub runner apprears on your GitHub organization or repo.

## Build and Run the Application

You can build and run the application using [Xcode](https://developer.apple.com/xcode/) by opening up the **VirtualMachine.xcodeproj**.

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is based on the [Running macOS in a virtual machine on Apple silicon](https://developer.apple.com/documentation/virtualization/running_macos_in_a_virtual_machine_on_apple_silicon) example application.
You can find a list of contributors in the `CONTRIBUTORS.md` file.
This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/Spezi/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
