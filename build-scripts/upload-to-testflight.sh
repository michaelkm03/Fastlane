#!/bin/bash
###########
# Uploads a single app in the 'products' folder to TestFlight.
#
# Requires Shenzhen: see https://github.com/nomad/shenzhen
###########

APPNAME=$1
TF_API_TOKEN="2adc400ea09e42f0ec53c0d605e5bbff_MTgwMzI2MTIwMTQtMDQtMjEgMjI6MDM6MDIuNjk2OTMx"
TF_TEAM_TOKEN="4f53e38dc2dc6a4286a929d8cf56a16b_MjkwNzIxMjAxMy0xMS0wNyAxOToxNDo0NC4zNDEwOTc"

if [ "$APPNAME" == "" ]; then
    echo "Usage: $(basename $0) [app name]"
    exit 1
fi

IPAFILE="products/$APPNAME.ipa"
if [ ! -f "$IPAFILE" ]; then
    echo "No IPA found for $APPNAME in products/"
    exit 1
fi

DSYM="products/$APPNAME.app.dSYM.zip"
if [ -f "$DSYM" ]; then
    DSYM="-d $DSYM"
else
    DSYM=""
fi

echo "Uploading $APPNAME..."
ipa distribute:testflight -f "$IPAFILE" $DSYM -a "$TF_API_TOKEN" -T "$TF_TEAM_TOKEN" -m "Build $(git rev-list HEAD --count)" -l getvictoriousteam
