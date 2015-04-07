#!/bin/bash
###########
# Copies plist settings from one plist to another
###########

SOURCE=$1
DESTINATION=$2
CONFIGURATION=$3
PRODUCT_PREFIX=$4
P_FLAG=$5

if [ "$SOURCE" == "" -o "$DESTINATION" == "" ]; then
    echo "Usage: $0 <source> <destination> <configuration> [-p <PRODUCT_PREFIX>]"
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
    if [ "$VAL" != "" ]; then
        /usr/libexec/PlistBuddy -c "Set $1 $VAL" "$DESTINATION"
    fi
}

copyPListValue 'CFBundleDisplayName'
copyPListValue 'CFBundleIdentifier'
copyPListValue 'FacebookAppID'
copyPListValue 'TWITTER_CONSUMER_KEY'
copyPListValue 'TWITTER_CONSUMER_SECRET'
copyPListValue 'TestflightReleaseAppToken'
copyPListValue 'TestflightQAAppToken'
copyPListValue 'TestflightStagingAppToken'
copyPListValue 'VictoriousAppID'
copyPListValue 'StagingAppID'
copyPListValue 'QAAppID'
copyPListValue 'GAID'
copyPListValue 'FlurryAPIKey'
copyPListValue 'CreatorSalutation'

########### Copy URL schemes

/usr/libexec/PlistBuddy -c "Delete CFBundleURLTypes" "$DESTINATION"

N=0
while [ 1 ]
do
    SCHEME=$(/usr/libexec/PlistBuddy -c "Print CFBundleURLTypes:$N:CFBundleURLSchemes:0" "$SOURCE" 2> /dev/null)

    if [ "$SCHEME" == "" ]; then
        break
    fi

    if [ $N == 0 ]; then
        /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes Array" "$DESTINATION"
    fi
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$N:CFBundleURLSchemes Array" "$DESTINATION"
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$N:CFBundleURLSchemes: string $SCHEME" "$DESTINATION"

    let N=$N+1
done

########### Generate Custom URL Scheme for app

# Default App ID key: the plist key that contains the app ID that corresponds to the configuration we're building.
if [ "$CONFIGURATION" == "Release" -o "$CONFIGURATION" == "Stable" ]; then
    DEFAULT_APP_ID_KEY="VictoriousAppID"
elif [ "$CONFIGURATION" == "Staging" ]; then
    DEFAULT_APP_ID_KEY="StagingAppID"
elif [ "$CONFIGURATION" == "QA" ]; then
    DEFAULT_APP_ID_KEY="QAAppID"
else
    DEFAULT_APP_ID_KEY="VictoriousAppID"
fi

APP_ID=$(/usr/libexec/PlistBuddy -c "Print ${DEFAULT_APP_ID_KEY}" "$SOURCE" 2> /dev/null)
CUSTOM_SCHEME="${PRODUCT_PREFIX}vapp${APP_ID}"

/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$N:CFBundleURLName string com.getvictorious.deeplinking.scheme" "$DESTINATION"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$N:CFBundleURLSchemes Array" "$DESTINATION"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$N:CFBundleURLSchemes: string $CUSTOM_SCHEME" "$DESTINATION"
