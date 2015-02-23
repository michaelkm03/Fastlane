#!/bin/bash
###########
# Uploads a single app in the 'products' folder to TestFairy.
#
# Requires Shenzhen: see https://github.com/nomad/shenzhen
###########

echo "Building IPA for distribution through TestFairy..."

APPNAME=`basename "$1"`
TF_DISTRO_LIST="$2"
NOTIFY="$3"

DSYMD=""
DSYM="products/$APPNAME.app.dSYM.zip"
if [ -f "$DSYM" ]; then
    DSYMD="-d"
else
    DSYM=""
fi

ipa build -w "victorious/victorious.xcworkspace"

exit 0

UPLOADER_VERSION=1.09

# Put your TestFairy API_KEY here. Find it in your TestFairy account settings.
TESTFAIRY_API_KEY="d3b1ed7f2132f9dfc4ae381e8d36af7337261481"

# Should email testers about new version. Set to "off" to disable email notifications.
NOTIFY="on"

# If AUTO_UPDATE is "on" all users will be prompt to update to this build next time they run the app
AUTO_UPDATE="off"

# The maximum recording duration for every test. 
MAX_DURATION="10m"

# Is video recording enabled for this build. valid values:  "on", "off", "wifi" 
VIDEO="wifi"

# Comment text will be included in the email sent to testers
COMMENT=""

# locations of various tools
CURL=curl

SERVER_ENDPOINT=http://app.testfairy.com

usage() {
	echo "Usage: testfairy-upload-ios.sh IPA_FILENAME"
	echo
}
	
verify_tools() {

	# Windows users: this script requires curl. If not installed please get from http://cygwin.com/

	# Check 'curl' tool
	${CURL} --help >/dev/null
	if [ $? -ne 0 ]; then
		echo "Could not run curl tool, please check settings"
		exit 1
	fi
}

verify_settings() {
	if [ -z "${TESTFAIRY_API_KEY}" ]; then
		usage
		echo "Please update API_KEY with your private API key, as noted in the Settings page"
		exit 1
	fi
}

if [ $# -ne 1 ]; then
	usage
	exit 1
fi

if [ ! -f "${IPA_FILENAME}" ]; then
	usage
	echo "Can't find file: ${IPA_FILENAME}"
	exit 2
fi

# before even going on, make sure all tools work
verify_tools
verify_settings

# Tester Groups that will be notified when the app is ready. Setup groups in your TestFairy account testers page.
# This parameter is optional, leave empty if not required
TESTER_GROUPS=$2
# if [ ! -f "${TESTER_GROUPS}" ]; then
# 	usage
# 	echo "Please specify tester groups."
# 	exit 2
# fi


# temporary file paths
DATE=`date`

/bin/echo -n "Uploading ${IPA_FILENAME} to TestFairy.. "
JSON=$( ${CURL} -s ${SERVER_ENDPOINT}/api/upload -F api_key=${TESTFAIRY_API_KEY} -F file="@${IPA_FILENAME}" -F video="${VIDEO}" -F max-duration="${MAX_DURATION}" -F comment="${COMMENT}" -F testers-groups="${TESTER_GROUPS}" -F auto-update="${AUTO_UPDATE}" -F notify="${NOTIFY}" -A "TestFairy iOS Command Line Uploader ${UPLOADER_VERSION}" )

URL=$( echo ${JSON} | sed 's/\\\//\//g' | sed -n 's/.*"build_url"\s*:\s*"\([^"]*\)".*/\1/p' )
if [ -z "$URL" ]; then
	echo "FAILED!"
	echo
	echo "Build uploaded, but no reply from server. Please contact support@testfairy.com"
	exit 1
fi

echo "OK!"
echo
echo "Build was successfully uploaded to TestFairy and is available at:"
echo ${URL}