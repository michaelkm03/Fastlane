#!/bin/bash
###########
# Uploads a single app in the 'products' folder to TestFlight.
#
# Requires Shenzhen: see https://github.com/nomad/shenzhen
###########

APPNAME=`basename "$1"`
TF_DISTRO_LIST="$2"
TF_API_TOKEN="a646b2ee390c481007121eefb6dd9b28_MTgyMjcyNzIwMTQtMDQtMzAgMTk6MDU6NTkuNzQwMzIy"
TF_TEAM_TOKEN="4f53e38dc2dc6a4286a929d8cf56a16b_MjkwNzIxMjAxMy0xMS0wNyAxOToxNDo0NC4zNDEwOTc"

if [ "$APPNAME" == "" ]; then
    echo "Usage: $(basename $0) <app name> [<distribution list>]"
    exit 1
fi

IPAFILE="products/$APPNAME.ipa"
if [ ! -f "$IPAFILE" ]; then
    echo "No IPA found for $APPNAME in products/"
    exit 1
fi

DSYMD=""
DSYM="products/$APPNAME.app.dSYM.zip"
if [ -f "$DSYM" ]; then
    DSYMD="-d"
else
    DSYM=""
fi

LPARAM=""
if [ "$TF_DISTRO_LIST" != "" ]; then
    LPARAM="-l"
fi

echo "Uploading $APPNAME..."
ipa distribute:testflight -f "$IPAFILE" $DSYMD "$DSYM" -a "$TF_API_TOKEN" -T "$TF_TEAM_TOKEN" -m "Build $(git rev-list HEAD --count)" $LPARAM "$TF_DISTRO_LIST"
exit $?
