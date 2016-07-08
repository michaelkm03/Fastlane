#!/usr/bin/env bash
###########
# Modifies an .xcarchive according to
# an individual app configuration.
###########

APP_NAME=$1
A_FLAG=false
XCARCHIVE_PATH=""
CONFIGURATION=""
ENVIRONMENT="production"

show_usage () {
    echo "Usage: `basename $0` <app name> [-a <archive path> <build configuration>]"
    echo ""
    echo "If -a and -c are specified, this script will modify an .xcarchive."
    echo "Otherwise, the current source directory is modified."
    echo ""
    echo "if -e is specified it will use the provided environment, otherwise  the production VAMS API is used"
    echo ""
}

# Parse command line arguments
OPTIND=2
while getopts "a:e:c:" opt; do
    case $opt in
        a)
            A_FLAG=true
            XCARCHIVE_PATH=$OPTARG
            ;;
        c)
            CONFIGURATION=$OPTARG
            ;;
        e)
            ENVIRONMENT=$OPTARG
            ;;
        *)
            show_usage
            exit 1
    esac
done

if [ "$APP_NAME" == "" ]; then
  show_usage
  exit 1
fi

if [ $A_FLAG == true -a "$CONFIGURATION" == "" ]; then
  echo "If \"-a\" option is specified, <archive path> and <configuration> must be provided."
  echo ""
  show_usage
  exit 1
fi

# Grab the latest assets and configuration data from VAMS.
RESPONSE=$(python build-scripts/VAMS/vams_prebuild.py $APP_NAME ios $ENVIRONMENT 2>&1)
RESPONSE_CODE=$(echo "$RESPONSE" | cut -f1 -d '|')
RESPONSE_MESSAGE=$(echo "$RESPONSE" | cut -f2 -d '|')
# If no working folder is returned then exit
if [ "$RESPONSE_CODE" -ne 0 ]; then
    echo $RESPONSE_MESSAGE
    exit 1
else
    FOLDER="$RESPONSE_MESSAGE"
fi

if [ $A_FLAG == true ]; then
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


### Modify Info.plist

if [ $A_FLAG == true ]; then
    PRODUCT_PREFIX=`/usr/libexec/PlistBuddy -c "Print ProductPrefix" "$DEST_PATH/Info.plist"`
    if [ $? != 0 ]; then
        echo "ProductPrefix key not found in info.plist."
        exit 1
    fi
    ./build-scripts/copy-plist.sh "$FOLDER/Info.plist" "$DEST_PATH/Info.plist" -p "$PRODUCT_PREFIX"
else
    ./build-scripts/copy-plist.sh "$FOLDER/Info.plist" "$DEST_PATH/Info.plist"
fi


### Set App IDs

STAGING_APP_ID=$(./build-scripts/get-app-id.sh "$FOLDER" "Staging" 2> /dev/null)
if [ $? != 0 ]; then
    echo "Could not read app ID from Info.plist"
    exit 1
fi

PRODUCTION_APP_ID=$(./build-scripts/get-app-id.sh "$FOLDER" "Production" 2> /dev/null)
if [ $? != 0 ]; then
    echo "Could not read app ID from Info.plist"
    exit 1
fi

setAppIDs(){
    ENVIRONMENTS_PLIST="$1"
    N=0
    while [ 1 ]
    do
        NAME=$(/usr/libexec/PlistBuddy -c "Print :$N:name" "$ENVIRONMENTS_PLIST" 2> /dev/null)
        if [ "$NAME" == "" ]; then
            break
        elif [ "$NAME" == "Staging" ]; then
            /usr/libexec/PlistBuddy -c "Set :$N:appID $STAGING_APP_ID" "$ENVIRONMENTS_PLIST"
        elif [ "$NAME" == "Production" ]; then
            /usr/libexec/PlistBuddy -c "Set :$N:appID $PRODUCTION_APP_ID" "$ENVIRONMENTS_PLIST"
        fi

        let N=$N+1
    done
}

PLIST_FILES=$(find "$DEST_PATH" -name environments\*.plist)
IFS=$'\n'

for PLIST_FILE in $PLIST_FILES
do
    setAppIDs "$PLIST_FILE"
done


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

PROVISIONING_PROFILE_DESTINATION_PATH="./custom.mobileprovision"
if [ -e "$PROVISIONING_PROFILE_DESTINATION_PATH" ]; then
    rm "$PROVISIONING_PROFILE_DESTINATION_PATH"
fi

if [ "$CONFIGURATION" != "" ]; then
    CONFIGURATION_LOWERCASE=$(echo $CONFIGURATION | tr '[:upper:]' '[:lower:]')
    PROVISIONING_PROFILE_PATH="$FOLDER/${CONFIGURATION_LOWERCASE}.mobileprovision"
    if [ -e "$PROVISIONING_PROFILE_PATH" ]; then
        cp "$PROVISIONING_PROFILE_PATH" "$PROVISIONING_PROFILE_DESTINATION_PATH"
    fi
fi

### Remove Temp Directory

rm -rf $FOLDER
