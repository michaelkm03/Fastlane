//
//  VJSONHelper.m
//  victorious
//
//  Created by Josh Hinman on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VJSONHelper.h"

@implementation VJSONHelper

- (NSNumber *)numberFromJSONValue:(id)value
{
    if ( [value isKindOfClass:[NSNumber class]] )
    {
        return value;
    }
    else if ( [value isKindOfClass:[NSString class]] )
    {
        NSScanner *scanner = [[NSScanner alloc] initWithString:value];
        double number;
        if ( [scanner scanDouble:&number] )
        {
            return @(number);
        }
    }
    return nil;
}

@end
