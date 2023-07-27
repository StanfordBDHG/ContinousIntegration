<!--

This source file is part of the Stanford BDGH VirtualMachine project

SPDX-FileCopyrightText: 2023 Stanford University

SPDX-License-Identifier: MIT

-->

# Continous Integration

The repository also consists of scripts and additional setups for maintaining the build agents for the Stanford BDHG and related agents.


## Setup Instructions

The CI setup for GitHub Actions runners uses the Virtual Machine app to host a virtual machine that we use as a GitHub Action runner.
The repository contains the necessary steps, tools, and scripts to set up the environment.
1. Set up a macOS machine in conformance with the Stanford device setup requirements: https://uit.stanford.edu/service/StanfordJamf/Install.
2. Install the [UTM App](https://mac.getutm.app). Set up the application to "Open on Login" using the macOS dock context menu of the app. Ensure that you set the UTM settings to never put the host machine to sleep if a VM is running.
3. Either generate [new macOS virtual machine using the app](https://docs.getutm.app/guest-support/macos/) or use a preexisting UTM VM. If you use a preexisting bundle that has done all the following steps, you can skip the setup steps.
4. Start the VM using the app, and go through the setup process with the minimal possible setup, e.g., **no** location services, **no** Apple ID, and more ...
5. Setup that the VM user automatically logs in when the VM starts: [Apple Support - How to log in automatically to a Mac user account](https://support.apple.com/en-au/HT201476).
6. Disable automatic screen saves, turn off the display, and requiring a passcode when the screen is locked: [Apple Support - Set sleep and wake settings for your Mac](https://support.apple.com/guide/mac-help/set-sleep-and-wake-settings-mchle41a6ccd/mac) and enable the "preserve automatic sleeping when the display is off" setting in the System Settings > Displays > Advanced settings.
6. Download this repository from GitHub to the VM and run the installation steps by adapting the `.env` file in the `Installation` folder and running `$ sh install.sh` in the `Installation` folder. Optionally change the installed Xcode versions in the script.
7. Ensure that the GitHub runner appears on your GitHub organization or repo.
8. To automate launching the VMs every time the host machine starts up, open the `LaunchVMs` app in this repo using the Apple Script Editor, modify the script, or add additional VMs. You can find a list of possible commands for the [UTM App in the UTM documentation](https://docs.getutm.app/scripting/scripting/). Copy the `LaunchVMs` app to the Applications folder of your host VM. Add the UTM App as well as the `LaunchVMs` app as login items: [Apple Support - Open items automatically when you log in on Mac](https://support.apple.com/en-au/guide/mac-help/mh15189/mac).


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is based on the [Running macOS in a virtual machine on Apple silicon](https://developer.apple.com/documentation/virtualization/running_macos_in_a_virtual_machine_on_apple_silicon) example application.
You can find a list of contributors in the `CONTRIBUTORS.md` file.
This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/Spezi/tree/main/LICENSES) for more information.


![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-light.png#gh-light-mode-only)
![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-dark.png#gh-dark-mode-only)
