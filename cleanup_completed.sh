#!/bin/sh

rm -rf ~/actions-runner/_work/*

xcrun simctl shutdown all
xcrun simctl erase all
