#!/bin/sh

# Script to document and automate the installation of software for the GitHub Runner environment.

# Initial Setup
# Ensure that you have set all the correct credentials in the .env file.

# 1. Load the .env file
. .env


# 2. Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# 3. Install tools
brew install java
brew install node
brew install firebase-cli
brew install fastlane
brew install swiftlint
# Install xcode & speed up the Xcode download using aria2: https://github.com/XcodesOrg/xcodes
brew install aria2
brew install xcodesorg/made/xcodes

# Ensure that everything on the system is up-to-date
brew upgrade


# 4. Install Xcode

# Enable xcode-select without requiering a sudo password.
# https://www.smileykeith.com/2021/08/12/xcode-select-sudoers/
echo "%admin ALL=NOPASSWD: /usr/bin/xcode-select,/usr/bin/xcodebuild -runFirstLaunch" | sudo tee /etc/sudoers.d/xcode

# Download Xcode Releases
xcodes install --latest --experimental-unxip
xcodebuild -downloadAllPlatforms
xcodes install --latest-prerelease --experimental-unxip
xcodebuild -downloadAllPlatforms
xcodes signout


# 5. Install GitHub Action Runners - https://github.com/actions/runner/blob/main/docs/automate.md

# Setup the GitHub Action Runner tools to connect to GitHub
export RUNNER_CFG_PAT=$GITHUB_ACTION_RUNNER_PAT
curl -s https://raw.githubusercontent.com/actions/runner/main/scripts/create-latest-svc.sh | bash -s $GITHUB_ACTION_SCOPE -n $GITHUB_ACTION_NAME

# Move the cleanup scripts and the `.env` file in the GitHub Actions Folder
cp -rf ./GitHubActions ~/actions-runner
