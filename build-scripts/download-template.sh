#!/bin/bash
###########
# Downloads the latest available template for all environments
#
###########

ENVIRONMENTS_PATH=$1
BUILD_NUM=$2
DESTINATION_PATH=$3

if [ ! -e "$ENVIRONMENTS_PATH" -o "$BUILD_NUM" == "" -o "$DESTINATION_PATH" == "" ]; then
    echo "Usage: `basename $0` <path to environments.plist> <build number> <destination path>"
    exit 1
fi

N=0
while [ 1 ]
do
    NAME=$(/usr/libexec/PlistBuddy -c "Print :$N:name" "$ENVIRONMENTS_PATH" 2> /dev/null)
    if [ "$NAME" == "" ]; then
        break
    fi

    APP_ID=$(/usr/libexec/PlistBuddy -c "Print :$N:appID" "$ENVIRONMENTS_PATH" 2> /dev/null)
    BASE_URL=$(/usr/libexec/PlistBuddy -c "Print :$N:baseURL" "$ENVIRONMENTS_PATH" 2> /dev/null)
    curl "$BASE_URL/api/template" -A "buildserver/1.0 aid:$APP_ID uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:$BUILD_NUM" --create-dirs -o "$DESTINATION_PATH/$NAME.template.json"

    let N=$N+1
done
