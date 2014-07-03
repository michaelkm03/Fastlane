//
//  VSequence+UIActivityItemSource.m
//  victorious
//
//  Created by Will Long on 7/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence+UIActivityItemSource.h"

@implementation VSequence (UIActivityItemSource)

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"A string";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType
{
    NSString* string;
    if ([activityType isEqualToString:UIActivityTypePostToFacebook])
    {
        return @[NSLocalizedString(@"Like this!", nil), ];
    }
    else if ([activityType isEqualToString:UIActivityTypePostToTwitter])
    {
        return NSLocalizedString(@"Retweet this!", nil);
    }
    else
    {
        return nil;
    }

    return @[[NSURL URLWithString:self.previewImage], string];
}

@end
