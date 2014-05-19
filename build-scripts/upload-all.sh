#!/bin/bash
###########
# Uploads all apps in the 'products' folder to TestFlight.
###########

TF_DISTRO_LIST="$1"

CONFIGS=`find configurations -type d -depth 1 -exec basename {} \;`
IFS=$'\n'
for CONFIG in $CONFIGS
do
    build-scripts/upload-to-testflight.sh "$CONFIG" "$TF_DISTRO_LIST"
    if [ $? != 0 ]; then
        FAILED="yes"
    fi
done

if [ "$FAILED" != "" ]; then
    exit 1
else
    exit 0
fi
