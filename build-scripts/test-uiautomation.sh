#!/bin/bash
###########
# Builds, archives, and exports all the apps in the 'configurations' folder.
# IPA and DSYM files will be placed in the 'products' folder.
#
# Requires Shenzhen:  see https://github.com/nomad/shenzhen
###########

SCHEME=$1
CONFIGURATION=$2
DEVICE_NAME=$3
DEFAULT_PROVISIONING_PROFILE_PATH="build-scripts/tests.mobileprovision"
DEFAULT_CODESIGN_ID="iPhone Distribution: Victorious, Inc"
BUILDINFO_PLIST="buildinfo.plist"

if [ "$SCHEME" == "" -o "$CONFIGURATION" == "" ]; then
    echo "Usage: `basename $0` <scheme> <configuration (App name)>"
    exit 1
fi

TEST_REPORT_REPO="../VictoriousiOS.wiki"
TEST_REPORT_REPO_URL="git@github.com:TouchFrame/VictoriousiOS.wiki.git"
TEST_REPORT_FILE="UI-Automation-Tests.md"
git clone $TEST_REPORT_REPO_URL $TEST_REPORT_REPO

# Copy provisioning profile into Xcode
DEFAULT_PROVISIONING_PROFILE_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$DEFAULT_PROVISIONING_PROFILE_PATH")`
cp "$DEFAULT_PROVISIONING_PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision"

### Clean products folder
if [ -d "products" ]; then
    rm -rf products/*
else
    mkdir products
fi

Apply app configuration
echo "Configuring for $CONFIGURATION"
./build-scripts/apply-config.sh $CONFIGURATION
if [ $? != 0 ]; then
    echo "Error applying configuration for $CONFIGURATION"
    exit 1
fi

# Download the latest template
INFOPLIST="victorious/AppSpecific/Info.plist"
BUILDNUM=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFOPLIST")
# DEFAULT_ENVIRONMENT=$(/usr/libexec/PlistBuddy -c "Print :VictoriousServerEnvironment" "$INFOPLIST")
# ./build-scripts/downloadtemplate "victorious.xcarchive/Products/Applications/victorious.app" "$DEFAULT_ENVIRONMENT"
# if [ $? != 0 ]; then
#     exit 1
# fi

# Clean
xcodebuild -workspace victorious/victorious.xcworkspace \
   -scheme $SCHEME \
   -destination generic/platform=iOS clean

# Build
xcodebuild test \
    -workspace victorious/victorious.xcworkspace \
    -scheme $SCHEME \
    -destination platform="iOS",name="${DEVICE_NAME}"

TEST_RESULT=$?

echo "Tests completed: ${TEST_RESULT}"

mkdir -p $TEST_REPORT_REPO
cd $TEST_REPORT_REPO
DIFF=`git diff`

if [ $TEST_RESULT -eq 0 ]; then
    echo "Tests succeeded."

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

exit $TEST_RESULT