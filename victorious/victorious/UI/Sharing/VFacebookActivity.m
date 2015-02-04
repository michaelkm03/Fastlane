//
//  VFacebookActivity.m
//  victorious
//
//  Created by Will Long on 7/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFacebookActivity.h"

#import "VSequence+Fetcher.h"

#import "VFacebookManager.h"

#import "VConstants.h"

static NSString * const VFacebookActivityType = @"com.victorious.facebook";

@implementation VFacebookActivity

- (NSString *)activityType
{
    return VFacebookActivityType;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Facebook", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"uiactivity-facebook-color"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id item in activityItems)
    {
        if ([item isKindOfClass:[VSequence class]])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    VSequence *sequence;
    NSURL *shareUrl;
    for (id item in activityItems)
    {
        if ([item isKindOfClass:[VSequence class]])
        {
            sequence = item;
        }
        if ([item isKindOfClass:[NSURL class]])
        {
            shareUrl = item;
        }
    }
    
    [[VFacebookManager sharedFacebookManager] shareLink:shareUrl
                                            description:sequence.sequenceDescription
                                                   name:sequence.name
                                             previewUrl:nil];
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

@end
