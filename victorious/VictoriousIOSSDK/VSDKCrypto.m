//
//  VSDKCrypto.m
//  victorious
//
//  Created by Josh Hinman on 9/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSDKCrypto.h"

#import <CommonCrypto/CommonCrypto.h>

NSString *vsdk_sha1(NSString *plaintextString)
{
    const char *plaintext = [plaintextString UTF8String];
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(plaintext, (CC_LONG)strlen(plaintext), hash);
    
    NSUInteger hashedStringLength = CC_SHA1_DIGEST_LENGTH * 2;
    NSMutableString *hashedString = [NSMutableString stringWithCapacity:hashedStringLength];
    for (NSInteger i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [hashedString appendFormat:@"%02x", hash[i]];
    }
    return hashedString;
}
