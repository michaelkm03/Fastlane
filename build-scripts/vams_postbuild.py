#!/usr/bin/python

# Author: Lawrence H. Leach - Sr. Software Engineer
# Note: Hash calculating code was "borrowed" from Frank Zhao.
# Date: 07/12/2015
# Copyright 2015 Victorious Inc. All Rights Reserved.

"""
Posts a Test Fairy build url for a specific app to the Victorious backend.

This script is used by the following Victorious repositories:
https://github.com/TouchFrame/VictoriousAndroid
https://github.com/TouchFrame/VictoriousiOS
"""
import requests
import sys
import subprocess
import vams_common as vams

# Supress compiled files
sys.dont_write_bytecode = True

_VICTORIOUS_ENDPOINT = '/api/app/update_testfairy_url'
_DEFAULT_HOST = ''
_DEBUG = False


def postTestFairyURL(app_name, testfairy_url):
    """
    Post Test Fairy url to Victorious backend

    :param app_name:
        The name of the app to upload the Test Fairy url for.

    :param testfairy_url:
        The Test Fairy url to send to the backend.

    :return:
        0 - For success
        1 - For error
    """

    # Calculate request hash
    uri = '%s/%s' % (_VICTORIOUS_ENDPOINT, app_name)
    url = '%s%s' % (_DEFAULT_HOST, uri)
    req_hash = vams.calcAuthHash(uri, 'POST')

    field_name = 'android_testfairy_url'
    if vams._DEFAULT_PLATFORM == 'ios':
        field_name = 'ios_testfairy_url'

    auth_header = 'BASIC %s:%s' % (vams._DEFAULT_VAMS_USERID, req_hash)
    headers = {
        'Authorization': auth_header,
        'User-Agent': vams._DEFAULT_USERAGENT,
        'Date': vams._DEFAULT_HEADER_DATE
    }
    postData = {
        'build_name': app_name,
        'name': field_name,
        'platform': vams._DEFAULT_PLATFORM,
        'value': testfairy_url
    }
    response = requests.post(url, data=postData, headers=headers)
    json = response.json()
    error_code = json['error']

    if not error_code == 0:
        error_message = 'An error occurred posting the Test Fairy URL for %s.' % app_name
        if _DEBUG:
            print error_message
        sys.exit('1|%s' % error_message)

    # Clean-up compiled python files
    cleanUp()

    if _DEBUG:
        print 'Test Fairy URL posted successfully for %s!' % app_name
        print ''


def cleanUp():
    subprocess.call("find . -name '*.pyc' -delete", shell=True)


def showProperUsage():
    print ''
    print 'Usage: ./vams_postbuild.py <app_name> <platform> <url> <environment> <port>'
    print ''
    print '<app_name> is the name of the application in VAMS that you want to post data to.'
    print '<platform> is the OS platform for which this data is applicable.'
    print '<url> is the Test Fairy project url to be sent to backend'
    print '<environment> OPTIONAL: Is the server environment to post the data to.'
    print '<port> OPTIONAL: Will only be used if <environment> is set to localhost'
    print ''
    print 'NOTE: If no <environment> parameter is provided, the system will use PRODUCTION.'
    print ''
    print 'examples:'
    print './vams_postbuild.py awesomenesstv ios http://my-url     <-- will use PRODUCTION'
    print '  -- OR --'
    print './vams_postbuild.py awesomenesstv ios http://my-url qa  <-- will use QA'
    print ''

def main(argv):

    global _DEBUG

    if len(argv) < 4:
        if _DEBUG:
            showProperUsage()
        exit_message = '1|Wrong parameters were passed to vams_postbuild.py'
        sys.exit(exit_message)

    vams.init()


    app_name = argv[1]
    platform = argv[2]
    if platform == vams._PLATFORM_IOS:
        vams._DEFAULT_PLATFORM = vams._PLATFORM_IOS

    if platform == vams._PLATFORM_ANDROID:
        _DEBUG = True


    url = argv[3]

    if len(argv) == 5:
        server = argv[4]
    else:
        server = ''

    if len(argv) == 6:
        vams._DEFAULT_LOCAL_PORT = argv[5]

    global _DEFAULT_HOST
    if server.lower() == 'dev':
        _DEFAULT_HOST = vams._DEV_HOST
    elif server.lower() == 'qa':
        _DEFAULT_HOST = vams._QA_HOST
    elif server.lower() == 'staging':
        _DEFAULT_HOST = vams._STAGING_HOST
    elif server.lower() == 'production':
        _DEFAULT_HOST = vams._PRODUCTION_HOST
    elif server.lower() == 'localhost':
        _DEFAULT_HOST = '%s:%s' % (vams._LOCAL_HOST, vams._LOCAL_HOST)
    else:
        _DEFAULT_HOST = vams._PRODUCTION_HOST

    if _DEBUG:
        print ''
        print 'Using host: %s' % _DEFAULT_HOST
        print ''

    if vams.authenticateUser(_DEFAULT_HOST):
        postTestFairyURL(app_name, url)
    else:
        exit_message = '1|There was a problem authenticating with the Victorious backend. Exiting now...'
        if _DEBUG:
            print exit_message
        sys.exit(exit_message)

    
    sys.exit('0|Test Fairy URL Posted to VAMS Successfully')


if __name__ == '__main__':
    main(sys.argv)
