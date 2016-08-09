//
//  NSString+VParseHelp.m
//  VictoriOS
//
//  Created by Will Long on 11/18/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "NSString+VParseHelp.h"
@import VictoriousIOSSDK;

@implementation NSString (VParseHelp)

- (NSString *)v_pathComponent
{
    // We must percent encode the macros in our path otherwise NSURLComponents will return nil
    NSString *percentEncoded = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet vsdk_pathPartAllowedCharacterSet]];
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:percentEncoded];
    return components.path;
}

@end
