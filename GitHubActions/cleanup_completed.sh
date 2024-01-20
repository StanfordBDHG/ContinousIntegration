#!/bin/sh

rm -rf ~/runner/_work/*

xcrun simctl shutdown all
xcrun simctl erase all
