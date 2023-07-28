#!/bin/sh

xcrun simctl shutdown all
xcrun simctl erase all

echo "selfhosted=true" >> $GITHUB_ENV