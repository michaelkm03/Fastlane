#!/bin/bash -e
###########
# Finds the appropriate app ID for a given build configuration.
###########

FOLDER=$1
CONFIGURATION=$2

if [ "$FOLDER" == "" ]; then
    exit 0
fi

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

DEFAULT_APP_ID=$(/usr/libexec/PlistBuddy -c "Print $DEFAULT_APP_ID_KEY" "$FOLDER/Info.plist" 2> /dev/null)

echo $DEFAULT_APP_ID
