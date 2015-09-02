#!/bin/bash
###########
# Copies plist settings from one plist to another
###########

SOURCE=$1
DESTINATION=$2
APP_ID=$3
P_FLAG=$4
PRODUCT_PREFIX=$5

if [ "$SOURCE" == "" -o "$DESTINATION" == "" -o "$APP_ID" == "" ]; then
    echo "Usage: $0 <source> <destination> <app id> [-p <PRODUCT_PREFIX>]"
    echo ""
    echo "PRODUCT_PREFIX, if supplied, will be used to replace instances of \${ProductPrefix}."
    exit 1
fi

if [ ! -f "$SOURCE" ]; then
    pwd
    echo "\"$SOURCE\" not found."
    exit 1
fi

if [ ! -f "$DESTINATION" ]; then
    echo "\"$DESTINATION\" not found."
    exit 1
fi

# Make sure plist is readable
/usr/libexec/PlistBuddy -c "Print" "$SOURCE" > /dev/null
if [ $? != 0 ]; then
    echo "Error reading \"$SOURCE\""
    exit 1
fi

copyPListValue(){
    if [ "$P_FLAG" == "-p" ]; then
        local VAL=$(/usr/libexec/PlistBuddy -c "Print $1" "$SOURCE" | sed -e "s/\${ProductPrefix}/$PRODUCT_PREFIX/g")
    else
        local VAL=$(/usr/libexec/PlistBuddy -c "Print $1" "$SOURCE" 2> /dev/null)
    fi
    /usr/libexec/PlistBuddy -c "Set $1 $VAL" "$DESTINATION"
}

copyPListValue 'CFBundleDisplayName'
copyPListValue 'CFBundleIdentifier'
copyPListValue 'FacebookAppID'
copyPListValue 'TWITTER_CONSUMER_KEY'
copyPListValue 'TWITTER_CONSUMER_SECRET'
copyPListValue 'FlurryAPIKey'
copyPListValue 'CreatorSalutation'


########### Generate Facebook URL Scheme
## NOTE: This URL scheme will be modified at build time, but it needs to be set here initially.

/usr/libexec/PlistBuddy -c "Delete CFBundleURLTypes" "$DESTINATION"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes Array" "$DESTINATION"

FB_APPID=$(/usr/libexec/PlistBuddy -c "Print :FacebookAppID" "$SOURCE" 2> /dev/null)
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:0:CFBundleURLName string com.getvictorious.facebook" "$DESTINATION"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:0:CFBundleURLSchemes Array" "$DESTINATION"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:0:CFBundleURLSchemes: string fb${FB_APPID}${FB_SCHEME_SUFFIX}" "$DESTINATION"


########### Generate Custom URL Scheme for app

if [ "$P_FLAG" != "-p" ]; then
    PRODUCT_PREFIX=""
fi

CUSTOM_SCHEME="${PRODUCT_PREFIX}vapp${APP_ID}"

/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:1:CFBundleURLName string com.getvictorious.deeplinking.scheme" "$DESTINATION"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:1:CFBundleURLSchemes Array" "$DESTINATION"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:1:CFBundleURLSchemes: string $CUSTOM_SCHEME" "$DESTINATION"
