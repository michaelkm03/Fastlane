#!/usr/bin/python

# Quick and dirty script to test frequency of experiments running in production.

import requests
import sys
import uuid
import vams_common as vams


def main(argv):

    vams.init()

    server = 'production'

    global _DEFAULT_HOST
    _DEFAULT_HOST = vams.GetVictoriousHost(server)

    yes = 0
    no = 0
    for x in range(0, 1000):
        deviceid = uuid.uuid4()
        _DEFAULT_HEADER_DATE = vams.createDateString()
        _DEFAULT_USERAGENT = 'victorious/14938 aid:185 uuid:' + str(deviceid) + ' build:14938'
        url = 'https://api.getvictorious.com/api/template'
        req_hash = vams.calcAuthHash('/api/template', 'GET')
        auth_header = 'BASIC 0:%s' % (req_hash)
        
        headers = {
            'Authorization': auth_header,
            'User-Agent': _DEFAULT_USERAGENT,
            'Date': _DEFAULT_HEADER_DATE,
            'X-Client-App-Version': '3.4.1',
            'X-Client-Platform': 'iOS'
        }
        response = requests.get(url, headers=headers)
        responseJson = response.json()
        
        if responseJson['payload']['scaffold']['forceNativeFacebookLoginIOS']:
            print 'YES: %s' % (str(deviceid))
            yes = yes + 1
        else:
            print 'NO: %s' % (str(deviceid))
            no = no + 1
            
    print 'Final verdict: %d YES, %d NO' % (yes, no)
        
    sys.exit(0)


if __name__ == '__main__':
    main(sys.argv)
