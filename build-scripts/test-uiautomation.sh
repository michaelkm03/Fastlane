#!/bin/bash
###########
# Builds, archives, and exports all the apps in the 'configurations' folder.
# IPA and DSYM files will be placed in the 'products' folder.
#
# Requires Shenzhen:  see https://github.com/nomad/shenzhen
###########



    

# Check 'curl' tool
CURL=curl
${CURL} --help >/dev/null
if [ $? -ne 0 ]; then
    echo "Could not run curl tool, please check settings"
    exit 1
fi

JSON=$( ${CURL} -X PUT -d '{ "message": "Commit", "content": "Hello World", "sha": "8318c86b357b6ddbf674ad238b8745d2781cab4b" }' \
    -H "Authorization: token fe128103c64530916a3e2fcfb22844765ef3f490" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/TouchFrame/VictoriousiOS%2Ewiki/contents/UI-Automation-Tests.md )
echo $JSON
exit 0





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

# Clean
# xcodebuild -workspace victorious.xcworkspace -scheme $SCHEME -destination generic/platform=iOS clean

# Build
xcodebuild test -workspace victorious/victorious.xcworkspace -scheme debug-victorious -destination platform="iOS",name="${DEVICE_NAME}" CODE_SIGN_IDENTITY="iPhone Developer"
TEST_RESULT=$?

exit $TEST_RESULT