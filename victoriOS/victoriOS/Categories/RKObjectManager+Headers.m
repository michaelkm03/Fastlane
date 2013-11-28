//
//  RKObjectManager+Headers.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "RKObjectManager+Headers.h"
#import "NSString+SHA1Digest.h"

@implementation RKObjectManager (Headers)

-(void)refreshHeaders
{
    AFHTTPClient* client = [self HTTPClient];
    
    //[client setDefaultHeader:@"User-Agent" value:userAgent];
    
    NSString *currentDate = [self rFC2822DateTimeString];
    NSString* userAgent = [client.defaultHeaders objectForKey:@"User-Agent"];
    
    NSString* baseURL = self.baseURL;
    NSString* urlPath = @"";
    //[URLString substringFromIndex:[baseURL length]];//we use api/blah not full URL for sha
    
    // Build string to be hashed.
    NSString *sha1String = [[NSString stringWithFormat:@"%@%@%@%@%@",
                             currentDate,
                             urlPath,
                             userAgent,
                             @"", //[VSessionInfo sharedInfo].loginToken,
                             @"GET"] SHA1HexDigest];
    
    int userID = 0;//[VSessionInfo sharedInfo].user.userID;
    sha1String = [NSString stringWithFormat:@"Basic %i:%@", userID, sha1String];
    
    [client setDefaultHeader:@"Authorization" value:sha1String];
    [client setDefaultHeader:@"Date" value:currentDate];
    
}

- (NSString *)rFC2822DateTimeString {
    
    static NSDateFormatter *sRFC2822DateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sRFC2822DateFormatter = [[NSDateFormatter alloc] init];
        sRFC2822DateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
    });
    
    return [sRFC2822DateFormatter stringFromDate:[NSDate date]];
}

@end
