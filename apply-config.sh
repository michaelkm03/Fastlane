#!/bin/bash

FOLDER=$1

if [ "$FOLDER" == "" ]; then
	echo "Must specify folder name."
	exit 1
fi

if [ ! -d "configurations/$FOLDER" ]; then
	echo "Folder $FOLDER not found."
	exit 1
fi

### Copy Files

rm -rf victorious/AppSpecific/AppImages.xcassets
cp -R configurations/$FOLDER/AppImages.xcassets victorious/AppSpecific/AppImages.xcassets
cp    configurations/$FOLDER/defaultTheme.plist victorious/AppSpecific/defaultTheme.plist


### Modify Info.plist

copyPListValue(){
	local VAL=`/usr/libexec/PlistBuddy -c "Print $1" configurations/$FOLDER/Info.plist`
	if [ "$VAL" != "" ]; then
		/usr/libexec/PlistBuddy -c "Set $1 $VAL" victorious/AppSpecific/Info.plist
	fi
}

copyPListValue 'CFBundleDisplayName'
copyPListValue 'CFBundleIdentifier'
copyPListValue 'CFBundleURLTypes:0:CFBundleURLSchemes:0'
copyPListValue 'CFBundleURLTypes:1:CFBundleURLSchemes:1'
copyPListValue 'FacebookAppID'
copyPListValue 'FacebookDisplayName'
copyPListValue 'TestflightDevAppToken'
copyPListValue 'TestflightReleaseAppToken'
copyPListValue 'TestflightStableAppToken'
copyPListValue 'VictoriousAppID'