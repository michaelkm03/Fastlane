#!/bin/bash
###########
# Checks iOS app binary for APNS entitlements
###########

IPA_FILE=$1
CURRENT_DIRECTORY=$(pwd)
WORKING_DIRECTORY="$CURRENT_DIRECTORY/temp"
CODESIGN_PLIST="$CURRENT_DIRECTORY/codesign.plist"
SECURITY_PLIST="$CURRENT_DIRECTORY/security.plist"

showProperUsage(){
    echo "Extracts an IPA archive and checks for APNS enablement."
    echo ""
    echo "Usage: `basename $0` <ipa file>"
    echo ""
}

if [ "$IPA_FILE" == "" ]; then
    showProperUsage
    exit 1
fi

if [ ${IPA_FILE: -4} == ".ipa" ]; then

    mkdir $WORKING_DIRECTORY
    cp "$IPA_FILE" "$WORKING_DIRECTORY"

    NEW_IPA_FILE=$(basename "$IPA_FILE")
    mv "$WORKING_DIRECTORY/$NEW_IPA_FILE" "$WORKING_DIRECTORY/VictoriousApp.zip"

    echo "Unarchiving ipa file ($IPA_FILE)"
    UNZIP=$(unzip -x "$WORKING_DIRECTORY/VictoriousApp.zip" -d "$WORKING_DIRECTORY" 2> /dev/null)

    echo "Checking Binary Code Signing"
    codesign -d --entitlements :- $WORKING_DIRECTORY/Payload/victorious.app > $CODESIGN_PLIST
    CODESIGNING_ENTITLEMENT=$(/usr/libexec/PlistBuddy -c "Print:aps-environment" "$CODESIGN_PLIST" 2> /dev/null)
    echo "Code Signing Entitlement = $CODESIGNING_ENTITLEMENT"
    echo ""

    echo "Checking Provisioning Profile"
    security cms -D < $WORKING_DIRECTORY/Payload/victorious.app/embedded.mobileprovision >$SECURITY_PLIST
    PROVISIONING_ENTITLEMENT=$(/usr/libexec/PlistBuddy -c "Print:Entitlements:aps-environment" "$SECURITY_PLIST" 2>/dev/null)
    echo "Provisioning Profile Entitlement = $PROVISIONING_ENTITLEMENT"
    echo ""

    echo "Clean up... removing temp directory and plist files"
    rm -fdr $WORKING_DIRECTORY
    rm $CODESIGN_PLIST
    rm $SECURITY_PLIST
    echo "DONE!"

else
    showProperUsage
fi