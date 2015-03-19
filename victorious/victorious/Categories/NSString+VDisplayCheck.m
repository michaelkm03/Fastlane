//
//  NSString+VDisplayCheck.m
//  victorious
//
//  Created by Sharif Ahmed on 3/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSString+VDisplayCheck.h"

@implementation NSString (VDisplayCheck)

- (BOOL)isValidForDisplay
{
    return ![self isEqualToString:@""];
}

@end
