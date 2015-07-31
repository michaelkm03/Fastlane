//
//  VAPIRequestDecorator.m
//  victorious
//
//  Created by Josh Hinman on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSString+SHA1Digest.h"
#import "VAPIRequestDecorator.h"

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#endif

@import CoreLocation;

@implementation VAPIRequestDecorator

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _location = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (void)updateHeadersInRequest:(NSMutableURLRequest *)request
{
    NSString *currentDate = [[self dateFormatter] stringFromDate:[NSDate date]];
    
    NSString *userAgent = [request valueForHTTPHeaderField:@"User-Agent"] ?: [self defaultUserAgent];
    userAgent = [NSString stringWithFormat:@"%@ aid:%@ uuid:%@ build:%@", userAgent, self.appID.stringValue, self.deviceID, self.buildNumber];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    // Build string to be hashed.
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
    NSString *sha1String = [[NSString stringWithFormat:@"%@%@%@%@%@",
                             currentDate,
                             urlComponents.percentEncodedPath,
                             userAgent,
                             self.token ?: @"",
                             request.HTTPMethod] SHA1HexDigest];
    
    sha1String = [NSString stringWithFormat:@"Basic %@:%@", self.userID, sha1String];
    
    [request addValue:sha1String forHTTPHeaderField:@"Authorization"];
    [request addValue:currentDate forHTTPHeaderField:@"Date"];
    [request addValue:@"iOS" forHTTPHeaderField:@"X-Client-Platform"];
    
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    [request addValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Client-OS-Version"];
#endif
    
    if ( self.versionNumber != nil )
    {
        [request addValue:self.versionNumber forHTTPHeaderField:@"X-Client-App-Version"];
    }
    if ( self.sessionID != nil )
    {
        [request addValue:self.sessionID forHTTPHeaderField:@"X-Client-Session-ID"];
    }
    
    if (self.experimentIDs != nil)
    {
        [request addValue:self.experimentIDs forHTTPHeaderField:@"X-Client-Experiment-IDs"];
    }
    
    if ( self.locale != nil )
    {
        [request addValue:self.locale forHTTPHeaderField:@"Accept-Language"];
    }
    
    NSString *locationString = [self locationHeaderValue];
    if ( locationString != nil )
    {
        [request addValue:locationString forHTTPHeaderField:@"X-Geo-Location"];
    }
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z"; // RFC2822 Format
        
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
    });
    return dateFormatter;
}

- (NSString *)defaultUserAgent
{
    return @"victorious/1.0";
}

- (NSString *)locationHeaderValue
{
    if ( !CLLocationCoordinate2DIsValid(self.location) )
    {
        return nil;
    }
    
    if ( self.postalCode.length > 0 )
    {
        return [NSString stringWithFormat:@"latitude:%f, longitude:%f, postal_code:%@", self.location.latitude, self.location.longitude, self.postalCode];
    }
    else
    {
        return [NSString stringWithFormat:@"latitude:%f, longitude:%f", self.location.latitude, self.location.longitude];
    }
}

@end
