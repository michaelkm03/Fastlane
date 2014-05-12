#!/bin/bash
###########
# Builds, archives, and exports all the apps in the 'configurations' folder.
# IPA and DSYM files will be placed in the 'products' folder.
#
# Requires Shenzhen: see https://github.com/nomad/shenzhen
###########

SCHEME=$1
CONFIGURATION=$2
PROVISIONING_PROFILE=$3
APP_NAME=$4
CODESIGN_ID="iPhone Distribution: Victorious Inc. (82T26U698A)"

if [ "$SCHEME" == "" -o "$PROVISIONING_PROFILE" == "" -o "$CONFIGURATION" == "" ]; then
    echo "Usage: `basename $0` <scheme> <configuration> <provisioning profile UUID> [app name (optional)]"
    exit 1
fi

PROVISIONING_PROFILE_PATH="$HOME/Library/MobileDevice/Provisioning Profiles/$PROVISIONING_PROFILE.mobileprovision"
if [ ! -f "$PROVISIONING_PROFILE_PATH" ]; then
    echo "Provisioning profile $PROVISIONING_PROFILE_PATH not found."
    exit 1
fi

PROVISIONING_PROFILE_NAME=`/usr/libexec/PlistBuddy -c 'Print :Name' /dev/stdin <<< $(security cms -D -i "$PROVISIONING_PROFILE_PATH")`
if [ "$PROVISIONING_PROFILE_NAME" == "" ]; then
    echo "Provisioning profile $PROVISIONING_PROFILE_PATH could not be read."
    exit 1
fi

if [ "$APP_NAME" != "" -a ! -d "configurations/$APP_NAME" ]; then
    echo "App $APP_NAME not found."
    exit 1
fi


### Clean products folder

if [ -d "products" ]; then
    rm -rf products/*
else
    mkdir products
fi

if [ -d "victorious.xcarchive" ]; then
    rm -rf victorious.xcarchive
fi

if [ -a "victorious.app.dSYM.zip" ]; then
    rm -f victorious.app.dSYM.zip
fi


### Get Configurations

CONFIGS=`find configurations -type d -depth 1 -exec basename {} \;`


### Change to project folder

pushd victorious > /dev/null


### Clean

xcodebuild -workspace victorious.xcworkspace -scheme $SCHEME -destination generic/platform=iOS clean


### Build

xcodebuild -workspace victorious.xcworkspace -scheme "$SCHEME" -destination generic/platform=iOS \
           -archivePath "../victorious.xcarchive" PROVISIONING_PROFILE="$PROVISIONING_PROFILE" \
           CODE_SIGN_IDENTITY="$CODESIGN_ID" archive
BUILDRESULT=$?
if [ $BUILDRESULT == 0 ]; then
    pushd ../victorious.xcarchive/dSYMs > /dev/null
    zip -r ../../victorious.app.dSYM.zip victorious.app.dSYM
    popd > /dev/null
else
    popd > /dev/null
    exit $BUILDRESULT
fi


### Package the individual apps

IFS=$'\n'
for CONFIG in $CONFIGS
do
    if [ "$APP_NAME" != "" -a "$CONFIG" != "$APP_NAME" ]; then
        continue
    fi

    pushd .. > /dev/null
    ./build-scripts/apply-config.sh "$CONFIG" victorious.xcarchive
    if [ $? != 0 ]; then
        echo "Error applying configuration for $CONFIG"
        popd > /dev/null
        popd > /dev/null
        exit 1
    fi
    popd > /dev/null

    codesign -f -vvv -s "$CODESIGN_ID" "../victorious.xcarchive/Products/Applications/victorious.app"
    CODESIGNRESULT=$?

    if [ $CODESIGNRESULT != 0 ]; then
        echo "Codesign failed."
        popd > /dev/null
        exit $CODESIGNRESULT
    fi

    xcodebuild -exportArchive -exportFormat ipa -archivePath "../victorious.xcarchive" \
               -exportPath "../products/$CONFIG" -exportSigningIdentity "$CODESIGN_ID"
    EXPORTRESULT=$?

    if [ $EXPORTRESULT == 0 ]; then
        cp ../victorious.app.dSYM.zip "../products/$CONFIG.app.dSYM.zip"
    else
        popd > /dev/null
        exit $EXPORTRESULT
    fi
done

popd > /dev/null
