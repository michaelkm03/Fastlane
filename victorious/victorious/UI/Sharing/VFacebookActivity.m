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

static NSString* const VFacebookActivityType = @"com.victorious.facebook";

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
    return [UIImage imageNamed:@"uiactivity-facebook"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id item in activityItems)
    {
        if ([item isKindOfClass:[VSequence class]])
            return YES;
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id item in activityItems)
    {
        if ([item isKindOfClass:[VSequence class]])
        {
            VSequence* sequence = item;
            NSURL* previewUrl = [NSURL URLWithString:sequence.previewImage];
            
            [[VFacebookManager sharedFacebookManager] shareLink:previewUrl
                                                    description:@""
                                                           name:sequence.sequenceDescription
                                                     previewUrl:previewUrl];
        }
    }
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

@end
