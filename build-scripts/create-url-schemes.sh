#!/bin/bash
###########
# Adds URL schemes for Facebook and Victorious app deep linking to Info.plist
###########

APP_BUNDLE=$1

if [ "$APP_BUNDLE" == "" ]; then
    echo "Usage: `basename $0` <path/to/bundle.app>"
    echo ""
    exit 1
fi

INFOPLIST="$APP_BUNDLE/Info.plist"

# Clean the slate

/usr/libexec/PlistBuddy -c "Delete CFBundleURLTypes" "$INFOPLIST" 2> /dev/null
/usr/libexec/PlistBuddy -c "Delete FacebookUrlSchemeSuffix" "$INFOPLIST" 2> /dev/null
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes Array" "$INFOPLIST"


# Facebook

FB_APPID=$(/usr/libexec/PlistBuddy -c "Print :FacebookAppID" "$INFOPLIST" 2> /dev/null)
DISPLAY_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "$INFOPLIST" 2> /dev/null | sed 's/[^a-zA-Z0-9]//g')
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:0:CFBundleURLSchemes Array" "$INFOPLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:0:CFBundleURLSchemes: string fb${FB_APPID}${DISPLAY_NAME}" "$INFOPLIST"
/usr/libexec/PlistBuddy -c "Add FacebookUrlSchemeSuffix string $DISPLAY_NAME" "$INFOPLIST"


# App Deep Linking

getAppID(){
    TARGET_ENVIRONMENT=$(/usr/libexec/PlistBuddy -c "Print :VictoriousServerEnvironment" "$INFOPLIST")
    ENVIRONMENT_PLIST="$APP_BUNDLE/environments.plist"
    
    N=0
    while [ 1 ]
    do
        ENVIRONMENT_NAME=$(/usr/libexec/PlistBuddy -c "Print :$N:name" "$ENVIRONMENT_PLIST" 2> /dev/null)
        
        if [ "$ENVIRONMENT_NAME" == "" ]; then
            break
        elif [ "$ENVIRONMENT_NAME" == "$TARGET_ENVIRONMENT" ]; then
            echo $(/usr/libexec/PlistBuddy -c "Print :$N:appID" "$ENVIRONMENT_PLIST" 2> /dev/null)
            break
        fi
        
        let N=$N+1
        continue
    done
}
    
PRODUCT_PREFIX=$(/usr/libexec/PlistBuddy -c "Print :ProductPrefix" "$INFOPLIST")
APP_ID=$(getAppID)
CUSTOM_SCHEME="${PRODUCT_PREFIX}vapp${APP_ID}"

/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:1:CFBundleURLName string com.getvictorious.deeplinking.scheme" "$INFOPLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:1:CFBundleURLSchemes Array" "$INFOPLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:1:CFBundleURLSchemes: string $CUSTOM_SCHEME" "$INFOPLIST"
