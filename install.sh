#!/bin/s
#
# This source file is part of the Stanford BDGH VirtualMachine project
#
# SPDX-FileCopyrightText: 2023 Stanford University
#
# SPDX-License-Identifier: MIT
#

# Script to document and automate the installation of software for the GitHub Runner environment.
#

# Initial Setup
# Ensure that you have set all the correct credentials in the .env file.
# The script ask for a password at the beginning to execure sudo commands.
# The Xcode installation might require a two factor authentication credential when Xcode is downloaded.

# 1. Setup
# Load credentials from the .env file
set -a
. .env
set +a

# Enable xcode-select without requiering a sudo password.
# https://www.smileykeith.com/2021/08/12/xcode-select-sudoers/
echo "%admin ALL=NOPASSWD: /usr/bin/xcode-select,/usr/bin/xcodebuild -runFirstLaunch" | sudo tee /etc/sudoers.d/xcode

# 2. Install xcpretty
# We install xcpretty right at the beginning to avoid any repeated requests for a password.
sudo gem install xcpretty

# 3. Install homebrew
export NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"


# 4. Install tools
brew install java
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
echo 'export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"' >> ~/.zshrc

brew install node
brew install firebase-cli
brew install fastlane
# Set the local correctly to work with fastlane
echo 'export LC_ALL=en_US.UTF-8' >> ~/.zshrc
echo 'export LANG=en_US.UTF-8' >> ~/.zshrc

brew install git-lfs
git lfs install
git lfs install --system

# Install xcode & speed up the Xcode download using aria2: https://github.com/XcodesOrg/xcodes
brew install aria2
brew install xcodesorg/made/xcodes
# Required by the GitHub Runner Setup:
brew install jq

# Ensure that everything on the system is up-to-date
brew upgrade


# 5. Test and start the firebase emulator
firebase emulators:exec --project test "echo 'Firebase emulator installed and started successfully!'"


# 6. Install Xcode
# We install Xcode right at the beginning to avoid any interactive requests in the middle of the script like asking for a 2FA authentication code.
# Download Xcode Releases
xcodes install --update --experimental-unxip --empty-trash 15.0
sudo xcode-select -s /Applications/Xcode-15.0.app
xcodebuild -downloadAllPlatforms
xcodes signout

curl -o AppleWWDRCAG3.cer https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain AppleWWDRCAG3.cer
rm -f AppleWWDRCAG3.cer

# 7. Install SwiftLint
brew install swiftlint


# 8. Install GitHub Action Runners - https://github.com/actions/runner/blob/main/docs/automate.md

# Setup the GitHub Action Runner tools to connect to GitHub
rm -rf ~/actions-runner
mkdir ~/actions-runner

# Move the cleanup scripts and the `.env` file in the GitHub Actions Folder to enable an automatic reset of the simulators & cleaning of the working directory.
echo "ACTIONS_RUNNER_HOOK_JOB_STARTED=/Users/$USER/cleanup_started.sh" >> ~/actions-runner/.env
cp -f ./GitHubActions/cleanup_started.sh ~/cleanup_started.sh
chmod 755 ~/cleanup_started.sh

echo "ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/Users/$USER/cleanup_completed.sh" >> ~/actions-runner/.env
cp -f ./GitHubActions/cleanup_completed.sh ~/cleanup_completed.sh
chmod 755 ~/cleanup_completed.sh

cp -f ./create-latest-svc.sh ~/actions-runner/
chmod 755 ~/actions-runner/create-latest-svc.sh

# Install the GitHub Runner
cd ~/actions-runner
export RUNNER_CFG_PAT=$GITHUB_ACTION_RUNNER_PAT
./create-latest-svc.sh -s $GITHUB_ACTION_SCOPE -n $GITHUB_ACTION_NAME
rm -f ~/actions-runner/create-latest-svc.sh


# 9. Cleanup
echo "The installation is complete. Ensure that you remove the .env credentials file to avoid leaking information!"