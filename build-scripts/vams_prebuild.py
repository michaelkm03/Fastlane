#!/usr/bin/python

# Author: Lawrence H. Leach - Sr. Software Engineer
# Note: Hash calculating code was "borrowed" from Frank Zhao.
# Date: 07/01/2015
# Copyright 2015 Victorious Inc. All Rights Reserved.

"""
Authenticates with the Victorious backend, retrieves the latest app configuration data,
app assets and writes them to a temporary directory.

This script assumes it is being run from the root of the code directory.

This script is used by the following Victorious repositories:
https://github.com/TouchFrame/VictoriousAndroid
https://github.com/TouchFrame/VictoriousiOS
"""
import requests
import sys
import subprocess
import shutil
import os
import urllib
import tempfile
import vams_common as vams

# Supress compiled files
sys.dont_write_bytecode = True

_ASSETS_ENDPOINT = '/api/app/appassets_by_build_name'
_DEFAULT_HOST = ''

_WORKING_DIRECTORY = ''

def retrieveAppDetails(app_name):
    """
    Collects all of the design assets for a given app

    :param app_name:
        The app name of the app whose assets to be downloaded.

    :return:
        0 - For success
        1 - For error
    """

    # Calculate request hash
    uri = '%s/%s' % (_ASSETS_ENDPOINT, app_name)
    url = '%s%s' % (_DEFAULT_HOST, uri)
    req_hash = vams.calcAuthHash(uri, 'GET')

    auth_header = 'BASIC %s:%s' % (vams._DEFAULT_VAMS_USERID, req_hash)
    headers = {
        'Authorization':auth_header,
        'User-Agent':vams._DEFAULT_USERAGENT,
        'Date':vams._DEFAULT_HEADER_DATE
    }
    response = requests.get(url, headers=headers)
    json = response.json()
    error_code = json['error']

    if error_code == 0:
        payload = json['payload']
        app_title = payload['app_title']
        app_title = app_title.replace(' ','')
        assets = payload['assets']
        platform_assets = assets[vams._DEFAULT_PLATFORM]

        current_cnt = 0

        if not os.path.exists(_WORKING_DIRECTORY):
            os.makedirs(_WORKING_DIRECTORY)

        # Uncomment the following line to log out the directory being used for assets and config data
        # print "\nUsing Directory: %s" % _WORKING_DIRECTORY

        # print '\nDownloading the Most Recent Art Assets for %s...' % app_title
        for asset in platform_assets:

            if not platform_assets[asset] == None:
                img_url = platform_assets[asset]
                asset_name = asset.replace('_', '-')
                new_file = '%s/%s.png' % (_WORKING_DIRECTORY, asset_name)

                # Uncomment the following line to display the link to each asset being retrieved via VAMS
                # print '%s (%s)' % (asset_name, platform_assets[asset])

                urllib.urlretrieve(img_url,new_file)
                current_cnt = current_cnt+1

        # print '\n%s images downloaded' % current_cnt
        # print ''

        # Now set the app config data
        setAppConfig(json)
    else:
        #print 'No updated data for "%s" found in the Victorious backend' % app_name
        cleanUp()
        shutil.rmtree(_WORKING_DIRECTORY)
        sys.exit(1)


def setAppConfig(json_obj):
    """
    Parses a JSON object for app configuration data and writes it out to
    an app configuration file

    :param json_obj:
        The JSON object to parse that contains the app configuration data
    """
    payload = json_obj['payload']
    app_config = payload['configuration'][vams._DEFAULT_PLATFORM]
    app_title = payload['app_title']
    app_title = app_title.replace(' ','')

    file_name = 'config.xml'
    if vams._DEFAULT_PLATFORM == 'ios':
        file_name = 'Info.plist'
    config_file = '%s/%s' % (_WORKING_DIRECTORY, file_name)

    # print 'Applying Most Recent App Configuration Data to %s' % app_title
    # print ''
    # Uncomment out the following line to display the retrieved config data
    # print app_config

    # Write config file to disk
    f = open(config_file, 'w')
    f.write(app_config)
    f.close()

    # Clean-up compiled python files
    cleanUp()

    # print 'Configuration and assets applied successfully!'
    # print ''


def cleanUp():
    subprocess.call('find . -name \'*.pyc\' -delete', shell=True)


def showProperUsage():
        print ''
        print 'Usage: ./vams_prebuild.py <app_name> <platform> <environment> <port>'
        print ''
        print '<app_name> is the name of the application data to retrieve from VAMS.'
        print '<config_path> is the path on disk where the application data is to be written to.'
        print '<platform> is the OS platform for which the assets need to be downloaded for.'
        print '<environment> OPTIONAL: Is the server environment to retrieve the application data from.'
        print '<port> OPTIONAL: Will only be used if <environment> is set to local'
        print ''
        print 'NOTE: If no <environment> parameter is provided, the system will use PRODUCTION.'
        print ''
        print 'examples:'
        print './vams_prebuild.py awesomeness ios     <-- will use PRODUCTION'
        print '  -- OR --'
        print './vams_prebuild.py awesomeness ios qa  <-- will use QA'
        print ''
        return 1


def main(argv):
    if len(argv) < 3:
        showProperUsage()

    vams.init()

    app_name = argv[1]

    global _WORKING_DIRECTORY
    app_path = tempfile.mkdtemp()
    _WORKING_DIRECTORY = app_path

    platform = argv[2]
    if platform == 'ios':
        vams._DEFAULT_PLATFORM = 'ios'

    if len(argv) == 4:
        server = argv[3]
    else:
        server = ''

    if len(argv) == 5:
        vams._DEFAULT_LOCAL_PORT = argv[4]

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
    else:
        _DEFAULT_HOST = vams._PRODUCTION_HOST

    # Uncomment the following line to display the host being accessed
    # print 'Using host: %s' % _DEFAULT_HOST

    if vams.authenticateUser(_DEFAULT_HOST):
        retrieveAppDetails(app_name)
    else:
         #print 'There was a problem authenticating with the Victorious backend. Exiting now...'
         return 1
    
    sys.exit(_WORKING_DIRECTORY)


if __name__ == '__main__':
    main(sys.argv)
