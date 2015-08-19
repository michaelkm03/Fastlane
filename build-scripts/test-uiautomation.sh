#!/bin/bash
###########
# Builds, archives, and exports all the apps in the 'configurations' folder.
# IPA and DSYM files will be placed in the 'products' folder.
#
# Requires Shenzhen:  see https://github.com/nomad/shenzhen
###########

SCHEME=$1
ENVIRONMENT=$2
CONFIGURATION=$3
DEVICE_NAME=$4
DEFAULT_PROVISIONING_PROFILE_PATH="build-scripts/victorious.mobileprovision"
DEFAULT_CODESIGN_ID="iPhone Distribution: Victorious, Inc"
BUILDINFO_PLIST="buildinfo.plist"

if [ "$SCHEME" == "" -o "$ENVIRONMENT" == "" -o "$CONFIGURATION" == "" ]; then
    echo "Usage: `basename $0` <scheme> <environment> <configuration (App name)>"
    exit 1
fi

### Clean products folder
if [ -d "products" ]; then
    rm -rf products/*
else
    mkdir products
fi

### Build

# Copy provisioning profile into Xcode
DEFAULT_PROVISIONING_PROFILE_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$DEFAULT_PROVISIONING_PROFILE_PATH")`
cp "$DEFAULT_PROVISIONING_PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision"

# Apply app configuration
# echo "Configuring for $CONFIGURATION"
# ./build-scripts/apply-config.sh $CONFIGURATION
# if [ $? != 0 ]; then
#     echo "Error applying configuration for $CONFIGURATION"
#     exit 1
# fi

# Download the latest template
INFOPLIST="victorious/AppSpecific/Info.plist"
BUILDNUM=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFOPLIST")
# DEFAULT_ENVIRONMENT=$(/usr/libexec/PlistBuddy -c "Print :VictoriousServerEnvironment" "$INFOPLIST")
# ./build-scripts/downloadtemplate "victorious.xcarchive/Products/Applications/victorious.app" "$DEFAULT_ENVIRONMENT"
# if [ $? != 0 ]; then
#     exit 1
# fi

CODESIGN_ID=$DEFAULT_CODESIGN_ID
DEV_ACCOUNT=$DEFAULT_DEV_ACCOUNT
CODESIGNING_PLIST_FILE="configurations/$CONFIGURATION/codesigning.plist"

# Check for special provisioning profile
if [ -e "$CODESIGNING_PLIST_FILE" ]; then
    CUSTOM_PROVISIONING_PROFILE_PATH=$(/usr/libexec/PlistBuddy -c "Print ProvisioningProfiles:$ENVIRONMENT" "$CODESIGNING_PLIST_FILE")
    if [ $? == 0 ]; then
        CUSTOM_PROVISIONING_PROFILE_PATH="configurations/$1/$CUSTOM_PROVISIONING_PROFILE_PATH"
        CPP_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$CUSTOM_PROVISIONING_PROFILE_PATH")`
        cp "$CUSTOM_PROVISIONING_PROFILE_PATH" "victorious.xcarchive/Products/Applications/victorious.app/embedded.mobileprovision"
        if [ $? != 0 ]; then
            >&2 echo "Error: \"$CODESIGNING_PLIST_FILE\" specifies a provisioning profile that could not be found."
            exit 1
        fi
    fi
fi

# Check for special signing identity
if [ -e "$CODESIGNING_PLIST_FILE" ]; then
    CUSTOM_CODESIGN_ID=$(/usr/libexec/PlistBuddy -c "Print SigningIdentities:$ENVIRONMENT" "$CODESIGNING_PLIST_FILE")
    if [ $? == 0 ]; then
        CODESIGN_ID=$CUSTOM_CODESIGN_ID
    fi
fi

# Clean
# xcodebuild -workspace victorious.xcworkspace -scheme $SCHEME -destination generic/platform=iOS clean

# Build
xcodebuild test -workspace victorious/victorious.xcworkspace -scheme debug-victorious -destination platform="iOS",name="${DEVICE_NAME}"
TEST_RESULT=$?

exit $TEST_RESULT