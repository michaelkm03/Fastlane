#!/usr/bin/python

# Author: Lawrence H. Leach - Sr. Software Engineer
# Note: Hash calculating code was "borrowed" from Frank Zhao.
# Date: 07/12/2015
# Copyright 2015 Victorious Inc. All Rights Reserved.

"""
Posts a Test Fairy build url for a specific app to the Victorious backend.

"""
import requests
import sys
import os
import hashlib
import subprocess
import urllib
import vams_common as vams

_VICTORIOUS_ENDPOINT = '/api/app/update_testfairy_url'
_DEFAULT_HOST = ''
_AUTH_TOKEN = ''


def authenticateUser():
    """
    Authenticates a user against the Victorious backend API.

    :return:
        A JSON object of details returned by the Victorious backend API.
    """
    url = '%s%s' % (_DEFAULT_HOST, vams._LOGIN_ENDPOINT)

    vams._DEFAULT_HEADER_DATE = subprocess.check_output("date", shell=True).rstrip()
    postData = {'email':vams._DEFAULT_VAMS_USER,'password':vams._DEFAULT_VAMS_PASSWORD}
    headers = {'User-Agent':vams._DEFAULT_USERAGENT,'Date':vams._DEFAULT_HEADER_DATE}
    r = requests.post(url, data=postData, headers=headers)

    if not r.status_code == 200:
        return False

    response = r.json()

    # Return the authentication JSON object
    setAuthenticationToken(response)

    return True


def setAuthenticationToken(json_object):
    """
    Checks to see if there is a user token in the JSON response object
    of a login call. If there is, the script stores it in the global
    variable

    :param json_object:
        The response object from a authentication call. (May be blank.)

    :return:
        Nothing - If token object exists in JSON payload, then it is saved
        to a global variable.
    """
    global _AUTH_TOKEN

    payload = json_object['payload']
    if 'token' in payload:
        _AUTH_TOKEN = payload['token']

    if 'user_id' in json_object:
        vams._DEFAULT_VAMS_USERID = json_object['user_id']


def calcAuthHash(endpoint, reqMethod):
    """
    Calculates the Victorious backend authentication hash

    :param endpoint:
        The API endpoint being called

    :param reqMethod:
        The request method type 'GET' or 'POST'

    :return:
        A SHA1 hash used to authenticate subsequent requests
    """
    return hashlib.sha1(vams._DEFAULT_HEADER_DATE + endpoint + vams._DEFAULT_USERAGENT + _AUTH_TOKEN +
                        reqMethod).hexdigest()


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
    req_hash = calcAuthHash(uri, 'POST')

    field_name = 'android_testfairy_url'
    if vams._DEFAULT_PLATFORM == 'ios':
        field_name = 'ios_testfairy_url'

    auth_header = 'BASIC %s:%s' % (vams._DEFAULT_VAMS_USERID, req_hash)
    headers = {
        'Authorization':auth_header,
        'User-Agent':vams._DEFAULT_USERAGENT,
        'Date':vams._DEFAULT_HEADER_DATE
    }
    postData = {
        'build_name':app_name,
        'name':field_name,
        'platform':vams.DEFAULT_PLATFORM,
        'value':testfairy_url
    }
    response = requests.post(url, data=postData, headers=headers)
    json = response.json()
    error_code = json['error']

    if not error_code == 0:
        print 'An error occurred posting the Test Fairy URL for %s.' % app_name
        return 1

    print 'Test Fairy URL posted successfully for %s!' % app_name
    print ''


def main(argv):
    if len(argv) < 4:
        print ''
        print 'Usage: ./vams_postbuild.py <app_name> <platform> <url> <environment>'
        print ''
        print '<app_name> is the name of the application in VAMS that you want to post data to.'
        print '<platform> is the OS platform for which this data is applicable.'
        print '<url> is the Test Fairy project url to be sent to backend'
        print '<environment> is the server environment to post the data to.'
        print 'If no <environment> parameter is provided, the system will use PRODUCTION.'
        print ''
        print 'examples:'
        print './vams_postbuild.py awesomenesstv ios http://my-url     <-- will use PRODUCTION'
        print '  -- OR --'
        print './vams_postbuild.py awesomenesstv ios http://my-url qa  <-- will use QA'
        print ''
        return 1

    vams.init()

    app_name = argv[1]
    platform = argv[2]
    if platform == 'ios':
        vams._DEFAULT_PLATFORM = 'ios'

    url = argv[3]

    if len(argv) == 5:
        server = argv[4]
    else:
        server = ''

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
        _DEFAULT_HOST = vams._LOCAL_HOST
    else:
        _DEFAULT_HOST = vams._PRODUCTION_HOST
        
    print ''
    print 'Using host: %s' % _DEFAULT_HOST
    print ''

    if authenticateUser():
        postTestFairyURL(app_name, url)
    else:
         print 'There was a problem authenticating with the Victorious backend. Exiting now...'
         return 1
    
    return 0


if __name__ == '__main__':
    main(sys.argv)
