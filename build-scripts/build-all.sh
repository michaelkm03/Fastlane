#!/bin/bash
###########
# Builds, archives, and exports all the apps in the 'configurations' folder.
# IPA and DSYM files will be placed in the 'products' folder.
#
# Requires Shenzhen:  see https://github.com/nomad/shenzhen
###########

SCHEME=$1
CONFIGURATION=$2
DEFAULT_PROVISIONING_PROFILE_PATH="build-scripts/victorious.mobileprovision"
DEFAULT_CODESIGN_ID="iPhone Distribution: Victorious, Inc"

shift 2

if [ "$SCHEME" == "" -o "$CONFIGURATION" == "" ]; then
    echo "Usage: `basename $0` <scheme> <configuration> [--prefix <prefix>] [--macros <macros>] [app name(s) (optional)]"
    exit 1
fi

if [ "$1" == "--prefix" ]; then
    shift
    SPECIAL_PREFIX="ProductPrefix=$1-"
    shift
else
    SPECIAL_PREFIX=""
fi

if [ "$1" == "--macros" ]; then
    shift
    MACROS="GCC_PREPROCESSOR_DEFINITIONS=\$GCC_PREPROCESSOR_DEFINITIONS $1"
    shift
else
    MACROS=""
fi

### Copy provisioning profile into Xcode

DEFAULT_PROVISIONING_PROFILE_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$DEFAULT_PROVISIONING_PROFILE_PATH")`
cp "$DEFAULT_PROVISIONING_PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision"


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

if [ "$MACROS" == "" ]; then
    xcodebuild -workspace victorious.xcworkspace -scheme "$SCHEME" -destination generic/platform=iOS \
               -archivePath "../victorious.xcarchive" PROVISIONING_PROFILE="$DEFAULT_PROVISIONING_PROFILE_UUID" \
               CODE_SIGN_IDENTITY="$DEFAULT_CODESIGN_ID" $SPECIAL_PREFIX archive
else
    xcodebuild -workspace victorious.xcworkspace -scheme "$SCHEME" -destination generic/platform=iOS \
               -archivePath "../victorious.xcarchive" PROVISIONING_PROFILE="$DEFAULT_PROVISIONING_PROFILE_UUID" \
               CODE_SIGN_IDENTITY="$DEFAULT_CODESIGN_ID" $SPECIAL_PREFIX "$MACROS" archive
fi
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
    ./build-scripts/apply-config.sh "$1" -a victorious.xcarchive $CONFIGURATION
    if [ $? != 0 ]; then
        echo "Error applying configuration for $1"
        exit 1
    fi

    # Download the latest template
    INFOPLIST="victorious.xcarchive/Products/Applications/victorious.app/Info.plist"
    BUILDNUM=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFOPLIST")
    ./build-scripts/download-template.sh "victorious.xcarchive/Products/Applications/victorious.app/environments.plist" "$BUILDNUM" "victorious.xcarchive/Products/Applications/victorious.app"

    # Copy standard provisioning profile
    cp "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision" "victorious.xcarchive/Products/Applications/victorious.app/embedded.mobileprovision"

    CODESIGN_ID=$DEFAULT_CODESIGN_ID
    DEV_ACCOUNT=$DEFAULT_DEV_ACCOUNT
    CODESIGNING_PLIST_FILE="configurations/$1/codesigning.plist"

    # Check for special provisioning profile
    if [ -e "$CODESIGNING_PLIST_FILE" ]; then
        CUSTOM_PROVISIONING_PROFILE_PATH=$(/usr/libexec/PlistBuddy -c "Print ProvisioningProfiles:$CONFIGURATION" "$CODESIGNING_PLIST_FILE")
        CUSTOM_PROVISIONING_PROFILE_PATH="configurations/$1/$CUSTOM_PROVISIONING_PROFILE_PATH"
        if [ $? == 0 ]; then
            CPP_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$CUSTOM_PROVISIONING_PROFILE_PATH")`
            cp "$CUSTOM_PROVISIONING_PROFILE_PATH" "victorious.xcarchive/Products/Applications/victorious.app/embedded.mobileprovision"
            if [ $? != 0 ]; then
                >&2 echo "codesigning.plist specifies a provisioning profile that could not be found."
                exit 1
            fi
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
               -exportPath "products/$FOLDER" -exportSigningIdentity "$CODESIGN_ID"
    EXPORTRESULT=$?

    if [ $EXPORTRESULT == 0 ]; then
        cp victorious.app.dSYM.zip "products/$FOLDER.app.dSYM.zip"
    else
        exit $EXPORTRESULT
    fi
}

ANY_APP_BUILT=0

if [ $# == 0 ]; then
    CONFIG_FOLDERS=`find configurations -type d -depth 1 -exec basename {} \;`
    IFS=$'\n'
else
    CONFIG_FOLDERS=$*
fi

for FOLDER in $CONFIG_FOLDERS
do
    DEFAULT_APP_ID=$(./build-scripts/get-app-id.sh $FOLDER $CONFIGURATION)
    if [ "$DEFAULT_APP_ID" != "0" -a "$DEFAULT_APP_ID" != "" ]; then # don't build apps with empty app ID or 0
        applyConfiguration $FOLDER
        ANY_APP_BUILT=1
    fi
done

if [ $ANY_APP_BUILT == 0 ]; then
    echo "No apps were built."
    exit 1
fi
