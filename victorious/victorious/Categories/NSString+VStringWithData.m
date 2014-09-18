//
//  NSString+VStringWithData.m
//  victorious
//
//  Created by Josh Hinman on 7/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSString+VStringWithData.h"

@implementation NSString (VStringWithData)

+ (NSString *)v_stringWithData:(NSData *)data
{
    NSUInteger dataLength = [data length];
    NSUInteger stringLength = dataLength * 2;
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:stringLength];
    
    Byte bytes[dataLength];
    [data getBytes:&bytes length:dataLength];
    for (NSUInteger n = 0; n < dataLength; n++)
    {
        [string appendFormat:@"%02x", bytes[n]];
    }
    
    return string;
}

@end
