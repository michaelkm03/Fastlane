//
//  NSNumber+VBitmask.m
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import "NSNumber+VBitmask.h"

@implementation NSNumber (VBitmask)

- (NSString *)v_bitmaskString
{
    return [[self class] v_bitmaskString:self.integerValue];
}

+ (NSString *)v_bitmaskString:(NSInteger)integerValue
{
    NSMutableString *stringBits = [[NSMutableString alloc] init];
    NSUInteger spacing = pow( 2, 3 );
    NSUInteger width = ( sizeof( integerValue ) ) * spacing;
    NSUInteger binaryDigit = 0;
    NSUInteger integer = integerValue;
    
    while ( binaryDigit < width )
    {
        binaryDigit++;
        [stringBits insertString:( (integer & 1) ? @"1" : @"0" )atIndex:0];
        if ( binaryDigit % spacing == 0 && binaryDigit != width )
        {
            [stringBits insertString:@" " atIndex:0];
        }
        integer = integer >> 1;
    }
    return stringBits;
}

@end
