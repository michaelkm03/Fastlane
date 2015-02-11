//
//  VFollowersTextFormatter.m
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowersTextFormatter.h"
#import "VLargeNumberFormatter.h"

@implementation VFollowersTextFormatter

+ (VLargeNumberFormatter *)numberFormatter
{
    static VLargeNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      formatter = [[VLargeNumberFormatter alloc] init];
                  });
    return formatter;
}

+ (NSString *)followerTextWithNumberOfFollowers:(NSInteger)numberOfFollwers
{
    NSString *numberString = [[VFollowersTextFormatter numberFormatter] stringForInteger:numberOfFollwers];
    
    if ( numberOfFollwers == 0 )
    {
        return NSLocalizedString( @"SuggestedFollowersNone", nil);
    }
    else if ( numberOfFollwers == 1 )
    {
        NSString *format = NSLocalizedString( @"SuggestedFollowersSing", nil);
        return [NSString stringWithFormat:format, numberString];
    }
    else if ( numberOfFollwers >= 1000 )
    {
        NSString *format = NSLocalizedString( @"SuggestedFollowersK", nil);
        return [NSString stringWithFormat:format, numberString];
    }
    else
    {
        NSString *format = NSLocalizedString( @"SuggestedFollowersPlur", nil);
        return [NSString stringWithFormat:format, numberString];
    }
}

@end
