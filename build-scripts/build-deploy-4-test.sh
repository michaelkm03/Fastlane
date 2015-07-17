#!/bin/bash
###########
#
# build simulator or device (iPod Touch) version of our app to facilitate 
# test automation
# modified from build-all.sh
#
###########

SCHEME=$1
CONFIGURATION=$2
Deploy=$3

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




if [ "device" == $Deploy ]; then
    ### work order of attached devices: iPhone > iPod > iPad 
    UDID=`system_profiler SPUSBDataType | sed -n -e '/iPhone/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'`
    if [ -z "$UDID" ]; then 
        UDID=`system_profiler SPUSBDataType | sed -n -e '/iPod/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'`
    fi
    if [ -z "$UDID" ]; then 
        UDID=`system_profiler SPUSBDataType | sed -n -e '/iPad/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'`
    fi
    dest="platform=iOS,id=$UDID"
else
    osvsn=`xcodebuild -showsdks | grep Simulator | tail -1 |  awk -F " " '{print $4}'` 
    dest='platform=iOS Simulator,name=iPhone 6,OS='$osvsn
fi



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
