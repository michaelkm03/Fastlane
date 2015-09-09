#!/usr/bin/python

# Author: Lawrence H. Leach - Sr. Software Engineer
# Note: Hash calculating code was "borrowed" from Frank Zhao.
# Date: 09/08/2015
# Copyright 2015 Victorious Inc. All Rights Reserved.

"""
Authenticates with the Victorious backend, retrieves a list of the current active apps in VAMS.

This script assumes it is being run from the root of the code directory.

This script is used by the following Victorious repositories:
https://github.com/TouchFrame/VictoriousiOS
"""
import requests
import sys
import subprocess
import vams_common as vams
import color_codes as ccodes

# Supress compiled files
sys.dont_write_bytecode = True

_APPLIST_ENDPOINT = '/api/app/apps'


def fetchAppList():
    """
    Retrieves the list of ACTIVE (Locked or Unlocked) apps from VAMS

    """

    # Calculate request hash
    url = '%s%s' % (_DEFAULT_HOST, _APPLIST_ENDPOINT)
    req_hash = vams.calcAuthHash(_APPLIST_ENDPOINT, 'GET')

    auth_header = 'BASIC %s:%s' % (vams._DEFAULT_VAMS_USERID, req_hash)

    headers = {
        'Authorization':auth_header,
        'User-Agent':vams._DEFAULT_USERAGENT,
        'Date':vams._DEFAULT_HEADER_DATE
    }
    response = requests.get(url, headers=headers)
    json_obj = response.json()
    error_code = json_obj['error']

    if error_code == 0:
        app_count = 0
        print '\nVAMS Active Apps List\n----------------------'
        for app in json_obj['payload']:
            app_id = app['app_id']
            app_state = app['app_state']
            app_name = app['app_name']
            build_name = app['build_name']

            if app_state == vams._STATE_LOCKED:
                state = ccodes.color_codes.FAIL + app_state.upper() + ccodes.color_codes.ENDC
            elif app_state == vams._STATE_UNLOCKED:
                state = ccodes.color_codes.OKGREEN + app_state.upper() + ccodes.color_codes.ENDC
            else:
                state = ccodes.color_codes.OKBLUE + app_state.upper() + ccodes.color_codes.ENDC
            print 'Name: %s (%s)\nBuild Name: %s\nStatus: %s\n' % (app_name, ccodes.color_codes.HEADER + str(app_id) +
                                                             ccodes.color_codes.ENDC, build_name, state)
            app_count = app_count + 1

        print '----------------\nTotal of %s Apps\n' % app_count

    else:
        print 'No app data found. Uhh... obviously, something went wrong.'
        cleanUp()
        sys.exit(1)


def cleanUp():
    subprocess.call('find . -name \'*.pyc\' -delete', shell=True)


def main(argv):

    vams.init()

    server = argv[1]

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
        _DEFAULT_HOST = "%s:%s" % (vams._LOCAL_HOST, vams._DEFAULT_LOCAL_PORT)
    elif server.lower() == 'local':
        _DEFAULT_HOST = "%s:%s" % (vams._LOCAL_HOST, vams._DEFAULT_LOCAL_PORT)
    else:
        _DEFAULT_HOST = vams._PRODUCTION_HOST

    if vams.authenticateUser(_DEFAULT_HOST):
        fetchAppList()
    else:
        print 'There was a problem authenticating with the Victorious backend. Exiting now...'
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main(sys.argv)
