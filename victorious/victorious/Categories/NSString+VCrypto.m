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
    
    NSUInteger hashedStringLength = CC_SHA256_DIGEST_LENGTH * 2;
    NSMutableString *hashedString = [NSMutableString stringWithCapacity:hashedStringLength];
    for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [hashedString appendFormat:@"%02x", hash[i]];
    }
    return hashedString;
}

@end
