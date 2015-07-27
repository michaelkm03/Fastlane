#!/bin/bash
###########
# Uploads a single app in the 'products' folder to TestFairy.
#
# Requires Shenzhen: see https://github.com/nomad/shenzhen
###########

APPNAME=`basename "$1"`

# Tester Groups that will be notified when the app is ready. Setup groups in your TestFairy account testers page.
# This parameter is optional, leave empty if not required
TESTER_GROUPS=$2

# Should email testers about new version. Set to "off" to disable email notifications.
[[ "$3" == "--notify" ]] && NOTIFY="on" || NOTIFY="off"

usage() {
	echo "Usage: upload-to-testfairy.sh <App Name> <Tester Groups> [--notify]"
	echo
	echo -e "  <App Name>\t\tThe name of the .ipa in the products folder of the app to upload."
	echo -e "  <Tester Groups> \tComma-separated list (no spaces) of tester groups from TestFairy account to whom this build will be shared."
	echo -e "  --notify\t\tWhether or not to notify invited testers."
	echo
}

if [[ "$APPNAME" == "" ]]; then
	usage
	exit 1
fi

IPA_FILENAME="products/$APPNAME.ipa"

if [ ! -f "${IPA_FILENAME}" ]; then
	echo "Invalid input: Can't find an .ipa file in 'products' folder for app named '${APPNAME}'."
	usage
	exit 2
fi

UPLOADER_VERSION=1.09

# TestFairy API_KEY here for build.server@getvictorious.com
TESTFAIRY_API_KEY="61e501eea8b80b5596c7e17c9fea4739ec6e8a86"

# If AUTO_UPDATE is "on" all users will be prompt to update to this build next time they run the app
AUTO_UPDATE="off"

# The maximum recording duration for every test. 
MAX_DURATION="10m"

# Is video recording enabled for this build. valid values:  "on", "off", "wifi" 
VIDEO="off"

# Comment text will be included in the email sent to testers
COMMENT=""

# locations of various tools
CURL=curl

SERVER_ENDPOINT=http://app.testfairy.com
	
verify_tools() {
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

# before even going on, make sure all tools work
verify_tools
verify_settings

/bin/echo "Uploading ${IPA_FILENAME} to TestFairy..."
JSON=$( ${CURL} -s ${SERVER_ENDPOINT}/api/upload -F api_key=${TESTFAIRY_API_KEY} -F file="@${IPA_FILENAME}" -F video="${VIDEO}" -F max-duration="${MAX_DURATION}" -F comment="${COMMENT}" -F testers-groups="${TESTER_GROUPS}" -F auto-update="${AUTO_UPDATE}" -F notify="${NOTIFY}" -A "TestFairy iOS Command Line Uploader ${UPLOADER_VERSION}" )

URL=$( echo ${JSON} | sed 's/\\\//\//g' | sed -n 's/.*"build_url"\s*:\s*"\([^"]*\)".*/\1/p' )
if [ -z "$URL" ]; then
	echo "ERROR: Build uploaded, but no reply from server. Please contact support@testfairy.com"
	exit 1
fi
echo "SUCCESS: Build was successfully uploaded to TestFairy and is available at: ${URL}"

DSYM_ENDPOINT="http://app.testfairy.com/upload/dsym/";
DSYM_FILE="products/$APPNAME.app.dSYM.zip"
FILE_SIZE=$(stat -f "%z" "${DSYM_FILE}")

echo "Uploading .dSYM ($DSYM_FILE) at ${FILE_SIZE} bytes to .dSYM server..."

$CURL -s -F api_key="${TESTFAIRY_API_KEY}" -F dsym=@"${DSYM_FILE}" -o /dev/null "${DSYM_ENDPOINT}"

echo ".dSYM was successfully uploaded to TestFairy."

# Post Test Fairy url to VAMS
# echo
# echo "Posting Test Fairy url for '${APPNAME}' to Victorious backend"
# python vams_postbuild.py ${APPNAME} ios ${URL}

exit 0