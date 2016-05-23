//
//  VFacebookActivity.m
//  victorious
//
//  Created by Will Long on 7/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFacebookActivity.h"
#import "victorious-Swift.h"
#import "VImageAssetFinder.h"
#import "VSequence+Fetcher.h"
#import "victorious-Swift.h"

static NSString * const VFacebookActivityType = @"com.victorious.facebook";

@interface VFacebookActivity () <FBSDKSharingDelegate>

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) NSURL *shareURL;

@end

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
            return [VFacebookHelper facebookAppIDPresent];
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id item in activityItems)
    {
        if ([item isKindOfClass:[VSequence class]])
        {
            self.sequence = item;
        }
        if ([item isKindOfClass:[NSURL class]])
        {
            self.shareURL = item;
        }
    }
}

- (void)performActivity
{
    FBSDKShareLinkContent *link = [[FBSDKShareLinkContent alloc] init];
    link.contentURL = self.shareURL;
    
    VImageAsset *thumbnail = [[[VImageAssetFinder alloc] init] largestAssetFromAssets:self.sequence.previewImageAssets];
    if ( thumbnail.imageURL != nil )
    {
        link.imageURL = [NSURL URLWithString:thumbnail.imageURL];
    }
    
    FBSDKShareDialog *shareDialog = [VFacebookHelper shareDialogWithContent:link mode:self.shareMode];
    shareDialog.delegate = self;
    [shareDialog show];
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

#pragma mark - FBSDKSharingDelegate methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    [self activityDidFinish:YES];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [self activityDidFinish:NO];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [self activityDidFinish:NO];
}

@end
