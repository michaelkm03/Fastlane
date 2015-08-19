# --------------------
# Author: Lawrence H. Leach - Sr. Software Engineer
# Date: 07/13/2015
# Copyright 2015 Victorious Inc. All Rights Reserved.

"""
A set of global variables to be shared and set between the vams_prebuild and vams_postbuild programs.

"""
import requests
import subprocess
import hashlib
import sys

def init():
    # Supress compiled files
    sys.dont_write_bytecode = True

    global _LOGIN_ENDPOINT
    global _DEFAULT_CONFIG_DIRECTORY
    global _DEFAULT_DEST_DIRECTORY
    global _DEFAULT_VAMS_USERID
    global _DEFAULT_VAMS_USER
    global _DEFAULT_VAMS_PASSWORD
    global _DEFAULT_USERAGENT
    global _DEFAULT_HEADERS
    global _DEFAULT_HEADER_DATE
    global _DEFAULT_PLATFORM
    global _PRODUCTION_HOST
    global _STAGING_HOST
    global _QA_HOST
    global _DEV_HOST
    global _LOCAL_HOST
    global _DEFAULT_LOCAL_PORT
    global _AUTH_TOKEN
    global _PLATFORM_ANDROID
    global _PLATFORM_IOS

    _LOGIN_ENDPOINT = '/api/login'

    _DEFAULT_CONFIG_DIRECTORY = 'app/configuration'
    _DEFAULT_DEST_DIRECTORY = 'victorious/AppSpecific'

    _DEFAULT_VAMS_USERID = 0
    _DEFAULT_VAMS_USER = 'autobuild@victorious.com'
    _DEFAULT_VAMS_PASSWORD = 'R3@lVict0ry080213'

    _DEFAULT_USERAGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) ' \
                         'Chrome/43.0.2357.130 Safari/537.36 aid:11 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'
    _DEFAULT_HEADERS = ''
    _DEFAULT_HEADER_DATE = subprocess.check_output("date", shell=True).rstrip()

    _PLATFORM_ANDROID = 'android'
    _PLATFORM_IOS = 'ios'

    _DEFAULT_PLATFORM = _PLATFORM_ANDROID
    _PRODUCTION_HOST = 'https://api.getvictorious.com'
    _STAGING_HOST = 'https://staging.getvictorious.com'
    _QA_HOST = 'http://qa.getvictorious.com'
    _DEV_HOST = 'http://dev.getvictorious.com'
    _LOCAL_HOST = 'http://localhost'
    _DEFAULT_LOCAL_PORT = '8887'

    _AUTH_TOKEN = ''

def authenticateUser(host):
    """
    Authenticates a user against the Victorious backend API.

    :return:
        A JSON object of details returned by the Victorious backend API.
    """
    url = '%s%s' % (host, _LOGIN_ENDPOINT)

    postData = {
        'email': _DEFAULT_VAMS_USER,
        'password': _DEFAULT_VAMS_PASSWORD
    }
    headers = {
        'User-Agent': _DEFAULT_USERAGENT,
        'Date': _DEFAULT_HEADER_DATE
    }
    response = requests.post(url, data=postData, headers=headers)
    json = response.json()
    error_code = json['error']
    status_code = response.status_code

    if not (error_code == 0 and status_code == 200):
        return False

    # Return the authentication JSON object
    setAuthenticationToken(response.json())

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
    global _DEFAULT_VAMS_USERID

    payload = json_object['payload']
    if 'token' in payload:
        _AUTH_TOKEN = payload['token']

    if 'user_id' in json_object:
        _DEFAULT_VAMS_USERID = json_object['user_id']


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
    return hashlib.sha1(_DEFAULT_HEADER_DATE + endpoint + _DEFAULT_USERAGENT + _AUTH_TOKEN +
                        reqMethod).hexdigest()

