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
DEFAULT_PROVISIONING_PROFILE_NAME="Victorious Wildcard In-House Distribution"
DEFAULT_CODESIGN_ID="iPhone Distribution: Victorious, Inc"
DEFAULT_DEV_ACCOUNT="build.server@getvictorious.com"

shift 2

# Default App ID key: the plist key that contains the app ID that corresponds to the configuration we're building.
if [ "$CONFIGURATION" == "Release" ]; then
    DEFAULT_APP_ID_KEY="VictoriousAppID"
elif [ "$CONFIGURATION" == "Staging" ]; then
    DEFAULT_APP_ID_KEY="StagingAppID"
elif [ "$CONFIGURATION" == "QA" ]; then
    DEFAULT_APP_ID_KEY="QAAppID"
else
    DEFAULT_APP_ID_KEY=""
fi

if [ "$SCHEME" == "" -o "$CONFIGURATION" == "" ]; then
    echo "Usage: `basename $0` <scheme> <configuration> [--prefix <prefix>] [app name(s) (optional)]"
    exit 1
fi

if [ "$1" == "--prefix" ]; then
    shift
    SPECIAL_PREFIX="ProductPrefix=$1-"
    shift
else
    SPECIAL_PREFIX=""
fi


### Find and update provisioning profile
# If this step fails or hangs, you may need to store or update the dev center credentials
# in the keychain. Use the "ios login" command.

ios profiles:download "$DEFAULT_PROVISIONING_PROFILE_NAME" --type distribution -u "$DEFAULT_DEV_ACCOUNT"

if [ $? != 0 ]; then
    echo "Unable to download provisioning profile \"$DEFAULT_PROVISIONING_PROFILE_NAME\""
    exit 1
fi

PROVISIONING_PROFILE_PATH=$(find . -iname *.mobileprovision -depth 1 -print -quit)
DEFAULT_PROVISIONING_PROFILE_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$PROVISIONING_PROFILE_PATH")`
mv "$PROVISIONING_PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision"


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
           -archivePath "../victorious.xcarchive" PROVISIONING_PROFILE="$DEFAULT_PROVISIONING_PROFILE_UUID" \
           CODE_SIGN_IDENTITY="$DEFAULT_CODESIGN_ID" $SPECIAL_PREFIX archive
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

    # Copy standard provisioning profile
    cp "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision" "victorious.xcarchive/Products/Applications/victorious.app/embedded.mobileprovision"

    CODESIGN_ID=$DEFAULT_CODESIGN_ID
    DEV_ACCOUNT=$DEFAULT_DEV_ACCOUNT
    CODESIGNING_PLIST_FILE="configurations/$1/codesigning.plist"

    # Check for special dev account
    if [ -e "$CODESIGNING_PLIST_FILE" ]; then
        CUSTOM_DEV_ACCOUNT=$(/usr/libexec/PlistBuddy -c "Print DevAccounts:$CONFIGURATION" "$CODESIGNING_PLIST_FILE")
        if [ $? == 0 ]; then
            DEV_ACCOUNT=$CUSTOM_DEV_ACCOUNT
        fi
    fi

    # Check for special provisioning profile
    if [ -e "$CODESIGNING_PLIST_FILE" ]; then
        CUSTOM_PROVISIONING_PROFILE=$(/usr/libexec/PlistBuddy -c "Print ProvisioningProfiles:$CONFIGURATION" "$CODESIGNING_PLIST_FILE")
        if [ $? == 0 ]; then
            ios profiles:download "$CUSTOM_PROVISIONING_PROFILE" --type distribution -u "$DEV_ACCOUNT"
            if [ $? != 0 ]; then
                echo "Unable to download provisioning profile \"$CUSTOM_PROVISIONING_PROFILE\" for app \"$1\""
                exit 1
            fi
            CPP_PATH=$(find . -iname *.mobileprovision -depth 1 -print -quit)
            CPP_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$CPP_PATH")`
            mv "$CPP_PATH" "victorious.xcarchive/Products/Applications/victorious.app/embedded.mobileprovision"
        fi
    fi

    # Check for special signing identity
    if [ -e "$CODESIGNING_PLIST_FILE" ]; then
        CUSTOM_CODESIGN_ID=$(/usr/libexec/PlistBuddy -c "Print SigningIdentities:$CONFIGURATION" "$CODESIGNING_PLIST_FILE")
        if [ $? == 0 ]; then
            CODESIGN_ID=$CUSTOM_CODESIGN_ID
        fi
    fi

    rm victorious.xcarchive/Products/Applications/victorious.app/*.xcent # remove old entitlements
    security cms -D -i "victorious.xcarchive/Products/Applications/victorious.app/embedded.mobileprovision" > tmp.plist
    /usr/libexec/PlistBuddy -x -c 'Print:Entitlements' tmp.plist > entitlements.plist
    codesign -f -vvv -s "$CODESIGN_ID" --entitlements entitlements.plist "victorious.xcarchive/Products/Applications/victorious.app"
    CODESIGNRESULT=$?
    rm tmp.plist
    rm entitlements.plist

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
        if [ "$DEFAULT_APP_ID_KEY" != "" ]; then
            DEFAULT_APP_ID=$(/usr/libexec/PlistBuddy -c "Print $DEFAULT_APP_ID_KEY" "configurations/$CONFIG/Info.plist")
            if [ "$DEFAULT_APP_ID" != "0" ]; then # don't build apps with app ID of 0
                applyConfiguration $CONFIG
            fi
        fi
    done
else
    for CONFIG in $@
    do
        applyConfiguration $CONFIG
    done
fi
