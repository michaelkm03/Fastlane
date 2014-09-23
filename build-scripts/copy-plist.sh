#!/bin/bash
###########
# Copies plist settings from one plist to another
###########

SOURCE=$1
DESTINATION=$2
P_FLAG=$3
PRODUCT_PREFIX=$4

if [ "$SOURCE" == "" -o "$DESTINATION" == "" ]; then
    echo "Usage: $0 <source> <destination> [-p <PRODUCT_PREFIX>]"
    echo ""
    echo "PRODUCT_PREFIX, if supplied, will be used to replaces instances of ${ProductPrefix}"
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
        local VAL=$(/usr/libexec/PlistBuddy -c "Print $1" "$SOURCE")
    fi
    if [ "$VAL" != "" ]; then
        /usr/libexec/PlistBuddy -c "Set $1 $VAL" "$DESTINATION"
    fi
}

copyPListValue 'CFBundleDisplayName'
copyPListValue 'CFBundleIdentifier'
copyPListValue 'FacebookAppID'
copyPListValue 'FacebookDisplayName'
copyPListValue 'TWITTER_CONSUMER_KEY'
copyPListValue 'TWITTER_CONSUMER_SECRET'
copyPListValue 'TestflightReleaseAppToken'
copyPListValue 'TestflightQAAppToken'
copyPListValue 'TestflightStagingAppToken'
copyPListValue 'VictoriousAppID'
copyPListValue 'StagingAppID'
copyPListValue 'QAAppID'
copyPListValue 'GAID'

########### Copy URL schemes

/usr/libexec/PlistBuddy -c "Delete CFBundleURLTypes" "$DESTINATION"

SCHEME1=$(/usr/libexec/PlistBuddy -c "Print CFBundleURLTypes:0:CFBundleURLSchemes:0" "$SOURCE")
if [ "$SCHEME1" != "" ]; then
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes Array" "$DESTINATION"
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes: dict" "$DESTINATION"
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:0:CFBundleURLSchemes Array" "$DESTINATION"
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:0:CFBundleURLSchemes: string $SCHEME1" "$DESTINATION"

    SCHEME2=$(/usr/libexec/PlistBuddy -c "Print CFBundleURLTypes:1:CFBundleURLSchemes:0" "$SOURCE")
    if [ "$SCHEME2" != "" ]; then
        /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes: dict" "$DESTINATION"
        /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:1:CFBundleURLSchemes Array" "$DESTINATION"
        /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:1:CFBundleURLSchemes: string $SCHEME2" "$DESTINATION"
    fi
fi
