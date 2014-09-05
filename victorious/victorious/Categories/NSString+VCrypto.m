//
//  NSString+VCrypto.m
//  victorious
//
//  Created by Josh Hinman on 9/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSString+VCrypto.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (VCrypto)

- (NSString *)v_sha256
{
    const char *plaintext = [self UTF8String];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(plaintext, strlen(plaintext), hash);
    
    NSMutableString *returnValue = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [returnValue appendFormat:@"%02x", hash[i]];
    }
    return returnValue;
}

@end
