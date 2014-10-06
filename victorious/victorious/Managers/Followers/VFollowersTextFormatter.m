//
//  VFollowersTextFormatter.m
//  victorious
//
//  Created by Patrick Lynch on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowersTextFormatter.h"

@implementation VFollowersTextFormatter

+ (NSString *)shortLabelWithNumberOfFollowersObject:(NSNumber *)numFollowers
{
    if ( numFollowers == nil )
    {
        return [self shortLabelWithNumberOfFollowers:0];
    }
    else
    {
        return [self shortLabelWithNumberOfFollowers:numFollowers.unsignedIntegerValue];
    }
}

+ (NSString *)shortLabelWithNumberOfFollowers:(NSUInteger)numFollowers
{
    if ( numFollowers > 0 )
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        if ( numFollowers == 1 )
        {
            NSString *format = NSLocalizedString( @"SuggestedFollowersSing", nil);
            NSNumber *number = [NSNumber numberWithUnsignedInteger:numFollowers];
            return [NSString stringWithFormat:format, [formatter stringFromNumber:number]];
        }
        else if ( numFollowers >= 1000 )
        {
            formatter.maximumFractionDigits = 1;
            formatter.minimumFractionDigits = 1;
            NSString *format = NSLocalizedString( @"SuggestedFollowersK", nil);
            NSNumber *number = [NSNumber numberWithFloat:(CGFloat)numFollowers / 1000.0f];
            return [NSString stringWithFormat:format, [formatter stringFromNumber:number]];
        }
        else
        {
            NSString *format = NSLocalizedString( @"SuggestedFollowersPlur", nil);
            NSNumber *number = [NSNumber numberWithUnsignedInteger:numFollowers];
            return [NSString stringWithFormat:format, [formatter stringFromNumber:number]];
        }
    }
    else
    {
        return NSLocalizedString( @"SuggestedFollowersNone", nil);
    }
}

@end
