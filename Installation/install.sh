#!/bin/sh

# Script to document and automate the installation of software for the GitHub Runner environment.

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


# 2. Install homebrew
export NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"


# 3. Install tools
brew install java
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
echo 'export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"' >> ~/.zshrc
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

brew install node
brew install firebase-cli
brew install fastlane
# Install xcode & speed up the Xcode download using aria2: https://github.com/XcodesOrg/xcodes
brew install aria2
brew install xcodesorg/made/xcodes
# Required by the GitHub Runner Setup:
brew install jq

# Ensure that everything on the system is up-to-date
brew upgrade


# 4. Install Xcode

# Download Xcode Releases
xcodes install --update --experimental-unxip --no-superuser --empty-trash 14.3.1
sudo xcode-select -s /Applications/Xcode-14.3.1
xcodebuild -runFirstLaunch
xcodebuild -downloadAllPlatforms
xcodes install --update --experimental-unxip --no-superuser --empty-trash 15.0 Beta 4
sudo xcode-select -s /Applications/Xcode-15.0.0-Beta.4
xcodebuild -runFirstLaunch
xcodebuild -downloadAllPlatforms
xcodes signout

# 5. Install Swiftlint
# Swiftlint can only be installed after Xcode is installed
brew install swiftlint

# 6. Install GitHub Action Runners - https://github.com/actions/runner/blob/main/docs/automate.md

# Setup the GitHub Action Runner tools to connect to GitHub
export RUNNER_CFG_PAT=$GITHUB_ACTION_RUNNER_PAT
curl -s https://raw.githubusercontent.com/actions/runner/main/scripts/create-latest-svc.sh | bash -s $GITHUB_ACTION_SCOPE -n $GITHUB_ACTION_NAME

# Move the cleanup scripts and the `.env` file in the GitHub Actions Folder to enable an automatic reset of the simulators & cleaning of the working directory.
cp -rf ./GitHubActions/ ~/actions-runner/

# 6. Cleanup
echo "The installation is complete. Ensure that you remove the .env credentials file to avoid leaking information!"