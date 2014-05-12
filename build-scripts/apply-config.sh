#!/bin/bash
###########
# Modifies an .xcarchive according to
# an individual app configuration.
###########

FOLDER=$1
XCARCHIVE_PATH=$2

if [ "$FOLDER" == "" ]; then
    echo "Usage: $0 <folder> <archive path>"
    exit 1
fi

if [ ! -d "configurations/$FOLDER" ]; then
    echo "Folder \"$FOLDER\" not found."
    exit 1
fi

FOLDER="configurations/$FOLDER"

if [ ! -d "$XCARCHIVE_PATH" ]; then
    echo "Archive \"$XCARCHIVE_PATH\" not found"
    exit 1
fi

APP_BUNDLE_PATH="$XCARCHIVE_PATH/Products/Applications/victorious.app"

if [ ! -d "$APP_BUNDLE_PATH" ]; then
    echo "App bundle not found at expected path: $APP_BUNDLE_PATH"
    exit 1
fi


### Copy Files

copyFile(){
    if [ -a "$FOLDER/$1" ]; then
        cp "$FOLDER/$1" "$APP_BUNDLE_PATH/$1"
    elif [ -a "$APP_BUNDLE_PATH/$1" ]; then
        rm "$APP_BUNDLE_PATH/$1"
    fi
}

copyFile "Default-568h@2x.png"
copyFile "Default@2x.png"
copyFile "defaultTheme.plist"
copyFile "Icon-29@2x.png"
copyFile "Icon-40@2x.png"
copyFile "Icon-60@2x.png"


### Modify Info.plist

PRODUCT_PREFIX=`/usr/libexec/PlistBuddy -c "Print ProductPrefix" "$APP_BUNDLE_PATH/Info.plist"`
if [ $? != 0 -o "$PRODUCT_PREFIX" == "" ]; then
    echo "ProductPrefix key not found in info.plist."
    exit 1
fi

copyPListValue(){
    local VAL=$(/usr/libexec/PlistBuddy -c "Print $1" "$FOLDER/Info.plist" | sed -e "s/\${ProductPrefix}/$PRODUCT_PREFIX/g")
    if [ "$VAL" != "" ]; then
        /usr/libexec/PlistBuddy -c "Set $1 $VAL" "$APP_BUNDLE_PATH/Info.plist"
    fi
}

# Make sure plist is readable
/usr/libexec/PlistBuddy -c "Print" "$FOLDER/Info.plist" > /dev/null
if [ $? != 0 ]; then
    echo "Error reading \"$FOLDER/Info.plist\""
    exit 1
fi

copyPListValue 'CFBundleDisplayName'
copyPListValue 'CFBundleIdentifier'
copyPListValue 'CFBundleURLTypes:0:CFBundleURLSchemes:0'
copyPListValue 'CFBundleURLTypes:1:CFBundleURLSchemes:0'
copyPListValue 'FacebookAppID'
copyPListValue 'FacebookDisplayName'
copyPListValue 'TWITTER_CONSUMER_KEY'
copyPListValue 'TWITTER_CONSUMER_SECRET'
copyPListValue 'TestflightDevAppToken'
copyPListValue 'TestflightReleaseAppToken'
copyPListValue 'TestflightQAAppToken'
copyPListValue 'TestflightStagingAppToken'
copyPListValue 'VictoriousAppID'