#!/bin/bash
###########
# Checks iOS app binary for APNS entitlements
###########

IPA_FILE=$1
CURRENT_DIRECTORY=$(pwd)
WORKING_DIRECTORY="$CURRENT_DIRECTORY/temp"
CODESIGN_PLIST="$CURRENT_DIRECTORY/temp/codesign.plist"
SECURITY_PLIST="$CURRENT_DIRECTORY/temp/security.plist"

showProperUsage(){
    echo "Extracts an IPA archive and checks for APNS entitlements."
    echo ""
    echo "Usage: `basename $0` <ipa file>"
    echo ""
}

if [ "$IPA_FILE" == "" ]; then
    showProperUsage
    exit 1
fi

if [ ${IPA_FILE: -4} == ".ipa" ]; then

    if [ ! -d "$WORKING_DIRECTORY" ]; then
        mkdir $WORKING_DIRECTORY
    fi
    cp "$IPA_FILE" "$WORKING_DIRECTORY"

    NEW_IPA_FILE=$(basename "$IPA_FILE")
    mv "$WORKING_DIRECTORY/$NEW_IPA_FILE" "$WORKING_DIRECTORY/VictoriousApp.zip"

    UNZIP=$(unzip -x "$WORKING_DIRECTORY/VictoriousApp.zip" -d "$WORKING_DIRECTORY" 2> /dev/null)

    codesign -d --entitlements :- $WORKING_DIRECTORY/Payload/victorious.app > $CODESIGN_PLIST
    CODESIGNING_ENTITLEMENT=$(/usr/libexec/PlistBuddy -c "Print:aps-environment" "$CODESIGN_PLIST" 2> /dev/null)
    echo "Code Signing Entitlement = $CODESIGNING_ENTITLEMENT"
    echo ""

    security cms -D < $WORKING_DIRECTORY/Payload/victorious.app/embedded.mobileprovision >$SECURITY_PLIST
    PROVISIONING_ENTITLEMENT=$(/usr/libexec/PlistBuddy -c "Print:Entitlements:aps-environment" "$SECURITY_PLIST" 2>/dev/null)
    echo "Provisioning Profile Entitlement = $PROVISIONING_ENTITLEMENT"
    echo ""

    rm -fdr $WORKING_DIRECTORY

else
    showProperUsage
fi