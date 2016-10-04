#!/bin/bash
###########
# Runs unit and automation tests of the app built for a device in the specific scheme and configuration.
# Sets up a simple python server to receive POSTs from the UIAutomationTests target that collections test summary data.
# Uses collected test summary data to update the UI Test Automation page of the VictoriousIOS wiki.
# See https://github.com/TouchFrame/VictoriousiOS/wiki/UI-Automation-Tests
###########

SCHEME=$1
CONFIGURATION=$2
DEVICE_NAME=$3
DEFAULT_PROVISIONING_PROFILE_PATH="build-scripts/tests.mobileprovision"
BUILDINFO_PLIST="buildinfo.plist"

# Check input
if [ "$SCHEME" == "" ]; then
    echo "Usage: `basename $0` <xcode scheme> [<configuration name>] [<device name>]"
    exit 1
fi

# Copy provisioning profile into Xcode
DEFAULT_PROVISIONING_PROFILE_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$DEFAULT_PROVISIONING_PROFILE_PATH")`
cp "$DEFAULT_PROVISIONING_PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision"

# Apply app configuration
if [ "$CONFIGURATION" != "" ]; then
    echo "Configuring for $CONFIGURATION"
    ./build-scripts/apply-config.sh $CONFIGURATION
    if [ $? != 0 ]; then
        echo "Error applying configuration for $CONFIGURATION"
        exit 1
    fi
else
    # Clear any previously-applied app configuration
    git checkout victorious/AppSpecific
fi

if [ "$DEVICE_NAME" == "" ]; then
    echo "No device specified, will run tests on iPhone 6 Simulator."
    DESTINATION="platform=iOS Simulator,name=iPhone 6"
else
    DESTINATION="platform=iOS,name=${DEVICE_NAME}"
fi

# Clean
xcodebuild clean \
   -workspace victorious/victorious.xcworkspace \
   -scheme $SCHEME \
   -destination "$DESTINATION"

# Test
xcodebuild test \
    DownloadTemplate=no \
    -workspace victorious/victorious.xcworkspace \
    -scheme $SCHEME \
    -destination "$DESTINATION"

exit $?
