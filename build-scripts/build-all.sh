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

if [ "$SCHEME" == "" -o "$PROVISIONING_PROFILE" == "" -o "$CONFIGURATION" == "" ]; then
    echo "Usage: `basename $0` <scheme> <configuration> <provisioning profile UUID> [app name (optional)]"
    exit 1
fi

PROVISIONING_PROFILE_PATH="$HOME/Library/MobileDevice/Provisioning Profiles/$PROVISIONING_PROFILE.mobileprovision"
if [ ! -f "$PROVISIONING_PROFILE_PATH" ]; then
    echo "Provisioning profile $PROVISIONING_PROFILE_PATH not found."
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


### Go build!

cleanWorkingDir(){
    git reset --hard -q
    git clean -f -q
}

CONFIGS=`find configurations -type d -depth 1 -exec basename {} \;`
pushd victorious > /dev/null

IFS=$'\n'
for CONFIG in $CONFIGS
do
    if [ "$APP_NAME" != "" -a "$CONFIG" != "$APP_NAME" ]; then
        continue
    fi

    pushd .. > /dev/null
    cleanWorkingDir
    ./build-scripts/apply-config.sh "$CONFIG"
    popd > /dev/null

    ipa build -w victorious.xcworkspace -s "$SCHEME" -c "$CONFIGURATION" --clean --archive -d "../products" -m "$PROVISIONING_PROFILE_PATH" --verbose
    BUILDRESULT=$?

    if [ $BUILDRESULT ]; then
        mv ../products/victorious.ipa          "../products/$CONFIG.ipa"
        mv ../products/victorious.app.dSYM.zip "../products/$CONFIG.app.dSYM.zip"
    else
        cleanWorkingDir
        popd > /dev/null
        exit $BUILDRESULT
    fi
done

cleanWorkingDir
popd > /dev/null
