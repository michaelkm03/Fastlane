#!/bin/bash
###########
#
# build simulator verion of our app to facilitate test automation
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

# if [ -d "victorious.xcarchive" ]; then
#     rm -rf victorious.xcarchive
# fi


### Change to project folder

pushd victorious > /dev/null


### Clean, OS default to latest

xcodebuild -workspace victorious.xcworkspace -scheme $SCHEME -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1' clean


### Build

xcodebuild -workspace victorious.xcworkspace -scheme "$SCHEME" -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1'  


BUILDRESULT=$?
if [ $BUILDRESULT == 0 ]; then
    BuildHome=$HOME/Library/Developer/Xcode/DerivedData
    vdir=`ls -lrt $BuildHome | grep 'victorious-' | tail -1 | awk '{print $9}'`
    if [ -d "$Deploy/victorious.app" ]; then
        dt=`ls -lrt $Deploy | grep victorious.app | awk '{print $6$7"_"$8}'`
        mv  $Deploy/victorious.app $Deploy/victorious_$dt.app
    fi
    mv $BuildHome/$vdir/Build/Products/$CONFIGURATION-iphonesimulator/victorious.app $Deploy/victorious.app
    echo $Deploy/victorious.app
else
    popd > /dev/null
    exit $BUILDRESULT
fi


### Change back to top folder

popd > /dev/null
