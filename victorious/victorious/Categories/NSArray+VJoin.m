//
//  NSArray+VJoin.m
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSArray+VJoin.h"

@implementation NSArray (VJoin)

- (NSString *)v_joinWithSeparator:(NSString *)separator
{
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    for ( NSUInteger i = 0; i < self.count; i++ )
    {
        id obj = self[i];
        [mutableString appendFormat:@"%@", obj];
        if ( i < self.count - 1 )
        {
            [mutableString appendString:separator];
        }
    }
    return [[NSString alloc] initWithString:mutableString];
}

@end
