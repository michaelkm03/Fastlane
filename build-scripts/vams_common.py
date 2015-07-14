# --------------------
# Author: Lawrence H. Leach - Sr. Software Engineer
# Date: 07/13/2015
# Copyright 2015 Victorious Inc. All Rights Reserved.

"""
A set of global variables to be shared and set between the vams_prebuild and vams_postbuild programs.

"""
def init():
    global _LOGIN_ENDPOINT
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

    _LOGIN_ENDPOINT = '/api/login'

    _DEFAULT_VAMS_USERID = 0
    _DEFAULT_VAMS_USER = 'vicky@example.com'
    _DEFAULT_VAMS_PASSWORD = 'abc123456'

    _DEFAULT_USERAGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:1 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'
    _DEFAULT_HEADERS = ''
    _DEFAULT_HEADER_DATE = ''

    _DEFAULT_PLATFORM = 'android'
    _PRODUCTION_HOST = 'http://api.getvictorious.com'
    _STAGING_HOST = 'http://staging.getvictorious.com'
    _QA_HOST = 'http://qa.getvictorious.com'
    _DEV_HOST = 'http://dev.getvictorious.com'
    _LOCAL_HOST = 'http://localhost:8887'
