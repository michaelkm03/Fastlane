#!/usr/bin/python

# Author: Michael Sena - Cat Owner and ATHF fan.
# Note: Hash calculating code was "borrowed" from Frank Zhao.
# Date: 06/21/2016
# Copyright 2016 Victorious Inc. All Rights Reserved.

"""
Authenticates with the Victorious backend, sends a content ID to the VIP stage.
"""
import os
import requests
import sys
import subprocess
import vams_common as vams

# Supress compiled files
sys.dont_write_bytecode = True

_STAGE_PATH_BEGINNING = '/v1/stage/'
_SEND_TO_VIP_PATH_PART = '/send_to_vip/'


def cleanUp():
    subprocess.call('find . -name \'*.pyc\' -delete', shell=True)


def showProperUsage():
        my_name = os.path.basename(__file__)
        print ''
        print 'Sends a piece of content to the VIP stage'
        print 'Usage: '+ my_name + ' <content_id>' + ' <app_id>' + '<environment>'
        print ''
        print '<app_id> OPTIONAL: The app id to send content to the VIP stage of.'
        print '<app_id> Use list_apps.py script to view valid app ids.'
        print ''
        print 'NOTE: '
        print 'If no <app_id> parameter is provided, the script will use 11 (Victorians).'
        print ''
        print 'examples:'
        print my_name + ' 11198596 <-- will send Star Wars to VIP Stage on Victorians Production'
        print my_name + ' 11198596 163 <-- will send Star Wars to VIP Stage on Vault Production'
        print my_name + ' 11198596 1 dev <-- will send Star Wars to VIP Stage on App ID 1 in Dev'
        sys.exit(1)


def sendToVIP(appID, contentID):
    # Calculate request hash
    path = '%s%s%s%s' % (_STAGE_PATH_BEGINNING, appID, _SEND_TO_VIP_PATH_PART, contentID)
    url = '%s%s' % (_VAPI_ENVIRONMENT, path)
    
    headers = vams.headersWith(path, 'POST')
    response = requests.post(url, data=None, headers=headers)

    if response.status_code == requests.codes.ok:
        print 'Success!'
        print response.json()
    else:
        print 'failure: '
        print response.status_code


def main(argv):

    vams.init()

    if len(argv) < 2:
        showProperUsage()
    else:
        contentID = argv[1]
        
    # Default App ID is Victorians (11)
    if len(argv) < 3:
        appID = 11
    else:
        appID = argv[2]

    # Default environment is Production vap.getvictorious.com
    if len(argv) < 4:
        environment = 'production'
    else:
        environment = argv[3]

    global _VAPI_ENVIRONMENT
    _VAPI_ENVIRONMENT = vams.GetVictoriousVAPI(environment)

    if vams.authenticateUser(vams.GetVictoriousHost(environment)):
        sendToVIP(appID, contentID)
    else:
        print 'There was a problem authenticating with the Victorious backend. Exiting now...'
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main(sys.argv)
