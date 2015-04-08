//
//  VRTCUserPostedAtFormatter.m
//  victorious
//
//  Created by Michael Sena on 8/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRTCUserPostedAtFormatter.h"

#import "VDependencyManager.h"

#import "VElapsedTimeFormatter.h"

@implementation VRTCUserPostedAtFormatter

+ (NSAttributedString *)formatRTCUserName:(NSString *)username
                    withDependencyManager:(VDependencyManager *)dependencyManager
{
    if (username == nil)
    {
        return nil;
    }
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:username
                                                                                   attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    [nameString addAttribute:NSForegroundColorAttributeName
                       value:[dependencyManager colorForKey:VDependencyManagerLinkColorKey]
                       range:NSMakeRange(0, username.length)];
    [nameString addAttribute:NSFontAttributeName
                       value:[dependencyManager fontForKey:VDependencyManagerLabel2FontKey]
                       range:NSMakeRange(0, username.length)];
    
    return nameString;

}

+ (NSAttributedString *)formattedRTCUserPostedAtStringWithUserName:(NSString *)username
                                                     andPostedTime:(NSNumber *)postedTime
                                             withDependencyManager:(VDependencyManager *)dependencyManager
{
    if (username == nil)
    {
        return nil;
    }
    
    VElapsedTimeFormatter *timeFormatter = [[VElapsedTimeFormatter alloc] init];
    NSString *timeText = [timeFormatter stringForSeconds:postedTime.floatValue];

    NSString *fullString = [NSString stringWithFormat:NSLocalizedString(@"RTCUserPostedAtSyntax", nil), username ?: @"", timeText];
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:fullString
                                                                                   attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    [nameString addAttribute:NSForegroundColorAttributeName
                       value:[dependencyManager colorForKey:VDependencyManagerLinkColorKey]
                       range:NSMakeRange(0, username.length)];
    [nameString addAttribute:NSFontAttributeName
                       value:[dependencyManager fontForKey:VDependencyManagerLabel2FontKey]
                       range:NSMakeRange(0, fullString.length)];
    
    return [[NSAttributedString alloc] initWithAttributedString:nameString];
}

@end
