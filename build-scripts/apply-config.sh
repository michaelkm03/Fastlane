#!/bin/bash
###########
# Modifies an .xcarchive according to
# an individual app configuration.
###########

FOLDER=$1
A_FLAG=$2
XCARCHIVE_PATH=$3
CONFIGURATION=$4

usage(){
    echo "Usage: `basename $0` <folder> [-a <archive path>] <configuration>"
    echo ""
    echo "If -a is specified, this script will modify an .xcarchive."
    echo "Otherwise, the current source directory is modified."
    echo ""
}

if [ "$FOLDER" == "" ]; then
    usage
    exit 1
fi

if [ ! -d "configurations/$FOLDER" ]; then
    echo "Folder \"$FOLDER\" not found."
    exit 1
fi

if [ "$A_FLAG" == "-a" -a "$CONFIGURATION" == "" ]; then
    echo "If \"-a\" option is specified, <archive path> and <configuration> must be provided."
    echo ""
    exit 1
fi

FOLDER="configurations/$FOLDER"

if [ "$A_FLAG" == "-a" ]; then
    if [ ! -d "$XCARCHIVE_PATH" ]; then
        echo "Archive \"$XCARCHIVE_PATH\" not found"
        exit 1
    fi
    DEST_PATH="$XCARCHIVE_PATH/Products/Applications/victorious.app"
else
    DEST_PATH="victorious/AppSpecific"
fi

if [ ! -d "$DEST_PATH" ]; then
    echo "Nothing found at expected path: \"$DEST_PATH\""
    exit 1
fi


### Copy Files

copyFile(){
    if [ -a "$FOLDER/$1" ]; then
        cp "$FOLDER/$1" "$DEST_PATH/$1"
    elif [ -a "$DEST_PATH/$1" ]; then
        rm "$DEST_PATH/$1"
    fi
}

copyFile "LaunchImage@2x.png"
copyFile "Icon-29@2x.png"
copyFile "Icon-40@2x.png"
copyFile "Icon-60@2x.png"
copyFile "homeHeaderImage.png"
copyFile "homeHeaderImage@2x.png"
copyFile "creator-avatar.png"
copyFile "creator-avatar@2x.png"


### Modify Info.plist

APP_ID=$(./build-scripts/get-app-id.sh `basename $FOLDER` $CONFIGURATION 2> /dev/null )

if [ "$A_FLAG" == "-a" ]; then
    PRODUCT_PREFIX=`/usr/libexec/PlistBuddy -c "Print ProductPrefix" "$DEST_PATH/Info.plist"`
    if [ $? != 0 ]; then
        echo "ProductPrefix key not found in info.plist."
        exit 1
    fi
    ./build-scripts/copy-plist.sh "$FOLDER/Info.plist" "$DEST_PATH/Info.plist" $APP_ID -p "$PRODUCT_PREFIX"
else
    ./build-scripts/copy-plist.sh "$FOLDER/Info.plist" "$DEST_PATH/Info.plist" $APP_ID
fi


### Set App IDs

QA_APP_ID=$(./build-scripts/get-app-id.sh `basename $FOLDER` "QA" 2> /dev/null)
STAGING_APP_ID=$(./build-scripts/get-app-id.sh `basename $FOLDER` "Staging" 2> /dev/null)
PRODUCTION_APP_ID=$(./build-scripts/get-app-id.sh `basename $FOLDER` "Production" 2> /dev/null)

setAppIDs(){
    ENVIRONMENTS_PLIST="$1"
    N=0
    while [ 1 ]
    do
        NAME=$(/usr/libexec/PlistBuddy -c "Print :$N:name" "$ENVIRONMENTS_PLIST" 2> /dev/null)
        if [ "$NAME" == "" ]; then
            break
        elif [ "$NAME" == "QA" ]; then
            /usr/libexec/PlistBuddy -c "Set :$N:appID $QA_APP_ID" "$ENVIRONMENTS_PLIST"
        elif [ "$NAME" == "Staging" ]; then
            /usr/libexec/PlistBuddy -c "Set :$N:appID $STAGING_APP_ID" "$ENVIRONMENTS_PLIST"
        elif [ "$NAME" == "Production" ]; then
            /usr/libexec/PlistBuddy -c "Set :$N:appID $PRODUCTION_APP_ID" "$ENVIRONMENTS_PLIST"
        fi

        let N=$N+1
    done
}

PLIST_FILES=$(find victorious/AppSpecific -name environments\*.plist)
IFS=$'\n'

for PLIST_FILE in $PLIST_FILES
do
    setAppIDs "$PLIST_FILE"
done
