#!/bin/bash
###########
# Builds, archives, and exports all the apps in the 'configurations' folder.
# IPA and DSYM files will be placed in the 'products' folder.
#
# Requires Shenzhen:  see https://github.com/nomad/shenzhen
# Requires Cupertino: see https://github.com/nomad/cupertino
###########

SCHEME=$1
CONFIGURATION=$2
PROVISIONING_PROFILE_NAME="Victorious Ad Hoc 1/15/14"
CODESIGN_ID="iPhone Distribution: Victorious Inc. (82T26U698A)"

shift 2

if [ "$SCHEME" == "" -o "$PROVISIONING_PROFILE_NAME" == "" -o "$CONFIGURATION" == "" ]; then
    echo "Usage: `basename $0` <scheme> <configuration> [app name(s) (optional)]"
    exit 1
fi

if [ "$APP_NAME" != "" -a ! -d "configurations/$APP_NAME" ]; then
    echo "App $APP_NAME not found."
    exit 1
fi


### Find and update provisioning profile
# If this step fails or hangs, you may need to store or update the dev center credentials
# in the keychain. Use the "ios login" command.

ios profiles:download "$PROVISIONING_PROFILE_NAME" --type distribution

if [ $? != 0 ]; then
    echo "Unable to download provisioning profile \"$PROVISIONING_PROFILE_NAME\""
    exit 1
fi

PROVISIONING_PROFILE_PATH=$(find . -iname *.mobileprovision -depth 1 -print -quit)
PROVISIONING_PROFILE_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$PROVISIONING_PROFILE_PATH")`
mv "$PROVISIONING_PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$PROVISIONING_PROFILE_UUID.mobileprovision"


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


### Change to project folder

pushd victorious > /dev/null


### Clean

xcodebuild -workspace victorious.xcworkspace -scheme $SCHEME -destination generic/platform=iOS clean


### Build

xcodebuild -workspace victorious.xcworkspace -scheme "$SCHEME" -destination generic/platform=iOS \
           -archivePath "../victorious.xcarchive" PROVISIONING_PROFILE="$PROVISIONING_PROFILE_UUID" \
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


### Change back to top folder

popd > /dev/null


### Package the individual apps

applyConfiguration(){
    ./build-scripts/apply-config.sh "$1" -a victorious.xcarchive
    if [ $? != 0 ]; then
        echo "Error applying configuration for $1"
        exit 1
    fi

    codesign -f -vvv -s "$CODESIGN_ID" "victorious.xcarchive/Products/Applications/victorious.app"
    CODESIGNRESULT=$?

    if [ $CODESIGNRESULT != 0 ]; then
        echo "Codesign failed."
        exit $CODESIGNRESULT
    fi

    xcodebuild -exportArchive -exportFormat ipa -archivePath "victorious.xcarchive" \
               -exportPath "products/$CONFIG" -exportSigningIdentity "$CODESIGN_ID"
    EXPORTRESULT=$?

    if [ $EXPORTRESULT == 0 ]; then
        cp victorious.app.dSYM.zip "products/$CONFIG.app.dSYM.zip"
    else
        exit $EXPORTRESULT
    fi
}

if [ $# == 0 ]; then
    CONFIGS=`find configurations -type d -depth 1 -exec basename {} \;`
    IFS=$'\n'
    for CONFIG in $CONFIGS
    do
        applyConfiguration $CONFIG
    done
else
    for CONFIG in $@
    do
        applyConfiguration $CONFIG
    done
fi
