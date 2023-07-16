#!/bin/sh

# Script to document and automate the installation of software for the GitHub Runner environment.

# Initial Setup
# Ensure that you have set all the correct credentials in the .env file.

# 1. Setup
# Load credentials from the .env file
. .env

# Enable xcode-select without requiering a sudo password.
# https://www.smileykeith.com/2021/08/12/xcode-select-sudoers/
echo "%admin ALL=NOPASSWD: /usr/bin/xcode-select,/usr/bin/xcodebuild -runFirstLaunch" | sudo tee /etc/sudoers.d/xcode

# 2. Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# After this point, no sudo access should be requested, the script should be able to finish on its own.

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

# Download Xcode Releases
xcodes install --update --latest --experimental-unxip --empty-trash
xcodebuild -downloadAllPlatforms
xcodes install --update --latest-prerelease --experimental-unxip --empty-trash
xcodebuild -downloadAllPlatforms
xcodes signout


# 5. Install GitHub Action Runners - https://github.com/actions/runner/blob/main/docs/automate.md

# Setup the GitHub Action Runner tools to connect to GitHub
export RUNNER_CFG_PAT=$GITHUB_ACTION_RUNNER_PAT
curl -s https://raw.githubusercontent.com/actions/runner/main/scripts/create-latest-svc.sh | bash -s $GITHUB_ACTION_SCOPE -n $GITHUB_ACTION_NAME

# Move the cleanup scripts and the `.env` file in the GitHub Actions Folder
cp -rf ./GitHubActions ~/actions-runner


# 6. Cleanup
echo "The installation is complete. Ensure that you remove the .env credentials file to avoid leaking information!"