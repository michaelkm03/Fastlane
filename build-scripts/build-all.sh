#!/bin/bash
###########
# Builds, archives, and exports Victorious apps.
# IPA and DSYM files will be placed in the 'products' folder.
###########

SCHEME=$1
CONFIGURATION=$2
DEFAULT_PROVISIONING_PROFILE_PATH="build-scripts/victorious.mobileprovision"
CODESIGN_ID="iPhone Distribution: Victorious, Inc"
BUILDINFO_PLIST="buildinfo.plist"
MD5=$(git rev-parse HEAD 2> /dev/null)

shift 2

usage(){
    echo "Usage: `basename $0` <scheme> <build configuration> [--prefix <prefix>] [--macros <macros>] [--swiftflags <swift flags>] [--vams_environment <environment>] <app name(s)>"
    exit 1
}

if [ "$SCHEME" == "" -o "$CONFIGURATION" == "" ]; then
    usage
fi

if [ "$1" == "--prefix" ]; then
    shift
    SPECIAL_PREFIX=$1
    PREFIX_COMMAND="ProductPrefix=$SPECIAL_PREFIX-"
    shift
else
    SPECIAL_PREFIX=""
    PREFIX_COMMAND=""
fi

if [ "$1" == "--macros" ]; then
    shift
    MACROS=$1
    shift
else
    MACROS=""
fi
MACROS_COMMAND="GCC_PREPROCESSOR_DEFINITIONS=\$GCC_PREPROCESSOR_DEFINITIONS $MACROS"

if [ "$1" == "--swiftflags" ]; then
    shift
    SWIFTFLAGS=$1
    shift
else
    SWIFTFLAGS=""
fi
SWIFTFLAGS_COMMAND="OTHER_SWIFT_FLAGS=\$OTHER_SWIFT_FLAGS $SWIFTFLAGS"

if [ "$1" == "--vams_environment" ]; then
    shift
    VAMS_ENVIRONMENT_OPTIONS="-e $1"
    shift
else
    VAMS_ENVIRONMENT_OPTIONS=""
fi

if [ $# == 0 ]; then
    usage
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

build(){

    if [ -d "victorious.xcarchive" ]; then
        rm -rf victorious.xcarchive
    fi

    if [ -f "victorious.app.dSYM.zip" ]; then
        rm -f victorious.app.dSYM.zip
    fi

    if [ -f "$BUILDINFO_PLIST" ]; then
        rm -f "$BUILDINFO_PLIST"
    fi

    # Change to project folder
    pushd victorious > /dev/null

    # Clean
    xcodebuild -workspace victorious.xcworkspace -scheme $SCHEME -destination generic/platform=iOS clean

    # Build
    xcodebuild -workspace victorious.xcworkspace -scheme "$SCHEME" -destination generic/platform=iOS \
               -archivePath "../victorious.xcarchive" DownloadTemplate=no $PREFIX_COMMAND "$MACROS_COMMAND" "$SWIFTFLAGS_COMMAND" archive
    BUILDRESULT=$?
    if [ $BUILDRESULT == 0 ]; then
        pushd ../victorious.xcarchive/dSYMs > /dev/null
        zip -r ../../victorious.app.dSYM.zip victorious.app.dSYM
        popd > /dev/null
    else
        popd > /dev/null
        exit $BUILDRESULT
    fi

    # Change back to top folder
    popd > /dev/null

    # Write build info
    /usr/libexec/PlistBuddy -x -c "Add :commit string $MD5" "$BUILDINFO_PLIST"
    /usr/libexec/PlistBuddy -x -c "Add :scheme string $SCHEME" "$BUILDINFO_PLIST"
    /usr/libexec/PlistBuddy -x -c "Add :configuration string $CONFIGURATION" "$BUILDINFO_PLIST"
    /usr/libexec/PlistBuddy -x -c "Add :prefix string $SPECIAL_PREFIX" "$BUILDINFO_PLIST"
    /usr/libexec/PlistBuddy -x -c "Add :macros string $MACROS" "$BUILDINFO_PLIST"
    /usr/libexec/PlistBuddy -x -c "Add :swiftflags string $SWIFTFLAGS" "$BUILDINFO_PLIST"
}

SKIP_BUILD="no"
if [ "$MD5" != "" -a -d "victorious.xcarchive" -a -f "$BUILDINFO_PLIST" ]; then
    PREVIOUS_MD5=$(/usr/libexec/PlistBuddy -c "Print :commit" "$BUILDINFO_PLIST")
    PREVIOUS_SCHEME=$(/usr/libexec/PlistBuddy -c "Print :scheme" "$BUILDINFO_PLIST")
    PREVIOUS_CONFIGURATION=$(/usr/libexec/PlistBuddy -c "Print :configuration" "$BUILDINFO_PLIST")
    PREVIOUS_PREFIX=$(/usr/libexec/PlistBuddy -c "Print :prefix" "$BUILDINFO_PLIST")
    PREVIOUS_MACROS=$(/usr/libexec/PlistBuddy -c "Print :macros" "$BUILDINFO_PLIST")
    PREVIOUS_SWIFTFLAGS=$(/usr/libexec/PlistBuddy -c "Print :swiftflags" "$BUILDINFO_PLIST")

    if [ "$PREVIOUS_MD5" == "$MD5" -a "$PREVIOUS_SCHEME" == "$SCHEME" -a "$PREVIOUS_CONFIGURATION" == "$CONFIGURATION" -a "$PREVIOUS_PREFIX" == "$SPECIAL_PREFIX" -a "$PREVIOUS_MACROS" == "$MACROS" -a "$PREVIOUS_SWIFTFLAGS" == "$SWIFTFLAGS" ]; then
        SKIP_BUILD="yes"
    fi
fi

if [ "$SKIP_BUILD" != "yes" ]; then
    build
fi


### Package the individual apps

applyConfiguration(){
    echo "Configuring for $1"

    ./build-scripts/apply-config.sh "$1" -a victorious.xcarchive -c $CONFIGURATION $VAMS_ENVIRONMENT_OPTIONS
    if [ $? != 0 ]; then
        echo "Error applying configuration for $1"
        return 1
    fi

    # Download the latest template
    INFOPLIST="victorious.xcarchive/Products/Applications/victorious.app/Info.plist"
    BUILDNUM=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFOPLIST")
    DEFAULT_ENVIRONMENT=$(/usr/libexec/PlistBuddy -c "Print :VictoriousServerEnvironment" "$INFOPLIST")
    ./build-scripts/downloadtemplate "victorious.xcarchive/Products/Applications/victorious.app" "$DEFAULT_ENVIRONMENT"
    if [ $? != 0 ]; then
        return 1
    fi

    # Create URL schemes
    ./build-scripts/create-url-schemes.sh victorious.xcarchive/Products/Applications/victorious.app

    # Copy standard provisioning profile
    cp "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision" "victorious.xcarchive/Products/Applications/victorious.app/embedded.mobileprovision"

    # Check for special provisioning profile
    CUSTOM_PROVISIONING_PROFILE_PATH="./custom.mobileprovision"
    if [ -e "$CUSTOM_PROVISIONING_PROFILE_PATH" ]; then
        cp "$CUSTOM_PROVISIONING_PROFILE_PATH" "victorious.xcarchive/Products/Applications/victorious.app/embedded.mobileprovision"
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
        return $CODESIGNRESULT
    fi

    xcodebuild -exportArchive -exportFormat ipa -archivePath "victorious.xcarchive" \
               -exportPath "products/$FOLDER" -exportSigningIdentity "$CODESIGN_ID"
    EXPORTRESULT=$?

    if [ $EXPORTRESULT == 0 ]; then
        cp victorious.app.dSYM.zip "products/$FOLDER.app.dSYM.zip"
    else
        return $EXPORTRESULT
    fi
}

ANY_APP_BUILT=0

for FOLDER in $*
do
    applyConfiguration $FOLDER
    if [ $? == 0 ]; then
        ANY_APP_BUILT=1
    fi
done

if [ $ANY_APP_BUILT == 0 ]; then
    echo "No apps were built."
    exit 1
fi
