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
        local VAL=$(/usr/libexec/PlistBuddy -c "Print $1" "$SOURCE" 2> /dev/null)
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
copyPListValue 'FlurryAPIKey'

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
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes: dict" "$DESTINATION"
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$N:CFBundleURLSchemes Array" "$DESTINATION"
    /usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$N:CFBundleURLSchemes: string $SCHEME" "$DESTINATION"

    let N=$N+1
done
