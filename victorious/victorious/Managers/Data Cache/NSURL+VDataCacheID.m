//
//  NSURL+VDataCacheID.m
//  victorious
//
//  Created by Josh Hinman on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSString+VCrypto.h"
#import "NSURL+VDataCacheID.h"

@implementation NSURL (VDataCacheID)

- (NSString *)identifierForDataCache
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self];
    NSURLRequest *canonicalRequest = [NSURLProtocol canonicalRequestForRequest:request];
    return [[[canonicalRequest URL] absoluteString] v_sha256];
}

@end
