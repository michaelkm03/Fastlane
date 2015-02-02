#!/bin/bash
###########
#
# build simulator or device (iPod Touch) verion of our app to facilitate 
# test automation
# modified from build-all.sh
#
###########

SCHEME=$1
CONFIGURATION=$2
Deploy=$3
DEFAULT_PROVISIONING_PROFILE_NAME="iOSTeam Provisioning Profile: com.getvictorious.*"
DEFAULT_CODESIGN_ID="iOS Developer"
#DEFAULT_CODESIGN_ID="iPhone Developer: jing zhao (54XLD839VY)"

shift 3

if [ "$SCHEME" == "" -o "$CONFIGURATION" == "" -o "" == "$Deploy" ]; then
    echo "Usage: `basename $0` <scheme> <configuration> <deploymentDir>"
    exit 1
fi


### Clean products folder
if [ -d "products" ]; then
    rm -rf products/*
else
    mkdir products
fi


### Change to project folder
pushd victorious > /dev/null





### Find and update provisioning profile
# If this step fails or hangs, you may need to store or update the dev center credentials
# in the keychain. Use the "ios login" command.

ios profiles:download "$DEFAULT_PROVISIONING_PROFILE_NAME" --type development -u "$DEFAULT_DEV_ACCOUNT"

if [ $? != 0 ]; then
    echo "Unable to download provisioning profile \"$DEFAULT_PROVISIONING_PROFILE_NAME\""
    exit 1
fi

PROVISIONING_PROFILE_PATH=$(find . -iname *.mobileprovision -depth 1 -print -quit)
DEFAULT_PROVISIONING_PROFILE_UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i "$PROVISIONING_PROFILE_PATH")`
mv "$PROVISIONING_PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$DEFAULT_PROVISIONING_PROFILE_UUID.mobileprovision"



### Clean
xcodebuild -workspace victorious.xcworkspace -scheme $SCHEME -destination  "$dest" clean 

### Build 
xcodebuild -workspace victorious.xcworkspace -scheme $SCHEME -destination "$dest"


BUILDRESULT=$?
if [ $BUILDRESULT == 0 ]; then
    BuildHome=$HOME/Library/Developer/Xcode/DerivedData
    vdir=`ls -lrt $BuildHome | grep 'victorious-' | tail -1 | awk '{print $9}'`
    if [ "device" == $Deploy ]; then
        sleep 1; echo "Deploying to device..."
        ios-deploy -r --bundle $BuildHome/$vdir/Build/Products/$CONFIGURATION-iphoneos/victorious.app
    else
        if [ -d "$Deploy/victorious.app" ]; then
            dt=`ls -lrt $Deploy | grep victorious.app | awk '{print $6$7"_"$8}'`
            mv  $Deploy/victorious.app $Deploy/victorious_$dt.app
        fi
        mv $BuildHome/$vdir/Build/Products/$CONFIGURATION-iphonesimulator/victorious.app $Deploy/victorious.app
        echo $Deploy/victorious.app
    fi
else
    popd > /dev/null
    exit $BUILDRESULT
fi


### Change back to top folder

popd > /dev/null
