#!/bin/sh

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install java
brew install node
brew install firebase-cli
brew install fastlane
brew install swiftlint

# Ensure that everything on the system is up-to-date
brew upgrade

# Non-automated:
# - Install Xcode and all relevant SDKs/simulators by hand.
# - Startup the simulator to check that it is working
# - Install the GitHub Action Runner tools
# - Setup the GitHub Action Runner tools to connect to GitHub
# - Move the cleanup scripts and the `.env` file in the GitHub Actions Folder