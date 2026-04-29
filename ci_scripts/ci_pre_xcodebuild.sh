#!/bin/zsh

set -e

# Stamp the Xcode Cloud build number into CFBundleVersion before each build.
# CI_BUILD_NUMBER is provided by Xcode Cloud and increments automatically.
if [[ -n "$CI_BUILD_NUMBER" ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $CI_BUILD_NUMBER" \
        "$CI_WORKSPACE/Sources/TrailWeight/Info.plist"
    echo "Set CFBundleVersion to $CI_BUILD_NUMBER"
fi
