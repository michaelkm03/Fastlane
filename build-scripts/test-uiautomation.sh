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
DEFAULT_CODESIGN_ID="iPhone Distribution: Victorious, Inc"
BUILDINFO_PLIST="buildinfo.plist"

# Check input
if [ "$SCHEME" == "" -o "$CONFIGURATION" == "" ]; then
    echo "Usage: `basename $0` <xcode scheme> <configuration name> <device name>"
    exit 1
fi

TEST_REPORT_REPO="../VictoriousiOS.wiki"
TEST_REPORT_REPO_URL="https://github.com/TouchFrame/VictoriousiOS.wiki.git"
TEST_REPORT_FILE="UI-Automation-Tests.md"

if [ "$DEVICE_NAME" == "" ]; then
    # Clone or pull the latest from the Wiki repo
    if [ ! -d $TEST_REPORT_REPO ]; then
        git clone $TEST_REPORT_REPO_URL $TEST_REPORT_REPO
    else
        pushd $TEST_REPORT_REPO
        git checkout $TEST_REPORT_FILE
        git pull origin master
        popd
    fi
fi

# Copy provisioning profile into Xcode
DEFAULT_PROVISIONING_PROFILE_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$DEFAULT_PROVISIONING_PROFILE_PATH")`
cp "$DEFAULT_PROVISIONING_PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision"

### Clean products folder
if [ -d "products" ]; then
    rm -rf products/*
else
    mkdir products
fi

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

if [ "$DEVICE_NAME" == "" ]; then
    echo "No device specified, will run tests on iPhone 6 Simulator."

    # Build for simulator
    xcodebuild test \
        -workspace victorious/victorious.xcworkspace \
        -scheme $SCHEME \
        -destination platform="iOS Simulator",name="iPhone 6"
else
    # Clean
    # xcodebuild -workspace victorious/victorious.xcworkspace \
    #    -scheme $SCHEME \
    #    -destination generic/platform=iOS clean

    # Build for device
    xcodebuild test \
        DownloadTemplate=yes \
        -workspace victorious/victorious.xcworkspace \
        -scheme $SCHEME \
        -destination platform="iOS",name="${DEVICE_NAME}"
fi

TEST_RESULT=$?
echo "Tests completed: ${TEST_RESULT}."

if [ "$DEVICE_NAME" == "" ]; then

    mkdir -p $TEST_REPORT_REPO
    cd $TEST_REPORT_REPO
    DIFF=`git diff`

    if [ $TEST_RESULT -eq 0 ]; then
        echo "Tests succeeded."
        echo "Diff = \"$DIFF\""

        if [ -n "$DIFF" ]; then
            # TODO: Send email?
            echo "Pushing test report to Wiki."
            git add --all
            git commit -m "Updated test report."
            git push origin master
        fi
    else
        # If the tests failed, undo the changes made while writing the test report
        echo "Tests failed."
        if [ -n "$DIFF" ]; then
            git checkout $TEST_REPORT_FILE
            echo "Undoing Wiki changes."
        fi
    fi
fi

exit $TEST_RESULT