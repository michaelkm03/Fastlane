//
//  VFacebookPublishShareController.m
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFacebookManager.h"
#import "VFacebookPublishShareController.h"
#import "VPublishShareView.h"

#import <FacebookSDK/FacebookSDK.h>

static NSString * const kVShareToFacebookDisabledKey = @"shareToFBKey";

@implementation VFacebookPublishShareController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.shareView.title = NSLocalizedString(@"facebook", nil);
        self.shareView.image = [UIImage imageNamed:@"share-btn-fb"];
        self.shareView.selectedColor = [UIColor colorWithRed:0.23f green:0.35f blue:0.6f alpha:1.0f];
        [self configureInitialState];
    }
    return self;
}

- (void)configureInitialState
{
    BOOL disabled = [[NSUserDefaults standardUserDefaults] boolForKey:kVShareToFacebookDisabledKey];
    if (!disabled)
    {
        if ([[VFacebookManager sharedFacebookManager] grantedPublishPermission])
        {
            self.shareView.selectedState = VShareViewSelectedStateSelected;
        }
        else
        {
            self.shareView.selectedState = VShareViewSelectedStateLimbo;
            [[VFacebookManager sharedFacebookManager] loginWithStoredTokenOnSuccess:^(void)
            {
                if ([[VFacebookManager sharedFacebookManager] grantedPublishPermission])
                {
                    self.shareView.selectedState = VShareViewSelectedStateSelected;
                }
                else
                {
                    self.shareView.selectedState = VShareViewSelectedStateNotSelected;
                }
            }
                                                                          onFailure:^(NSError *error)
            {
                self.shareView.selectedState = VShareViewSelectedStateNotSelected;
            }];
        }
    }
}

- (void)shareButtonTapped
{
    if (self.shareView.selectedState == VShareViewSelectedStateNotSelected)
    {
        if ([[VFacebookManager sharedFacebookManager] grantedPublishPermission])
        {
            self.shareView.selectedState = VShareViewSelectedStateSelected;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kVShareToFacebookDisabledKey];
        }
        else
        {
            self.shareView.selectedState = VShareViewSelectedStateLimbo;
            [[VFacebookManager sharedFacebookManager] requestPublishPermissionsOnSuccess:^(void)
            {
                self.shareView.selectedState = VShareViewSelectedStateSelected;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kVShareToFacebookDisabledKey];
            }
                                                                               onFailure:^(NSError *error)
            {
                if (![error.userInfo[FBErrorLoginFailedReason] isEqualToString:FBErrorLoginFailedReasonUserCancelledSystemValue] &&
                    ![error.userInfo[FBErrorLoginFailedReason] isEqualToString:FBErrorLoginFailedReasonUserCancelledValue] &&
                    ![error.userInfo[FBErrorLoginFailedReason] isEqualToString:FBErrorReauthorizeFailedReasonUserCancelled] &&
                    ![error.userInfo[FBErrorLoginFailedReason] isEqualToString:FBErrorReauthorizeFailedReasonUserCancelledSystem])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"FacebookFailed", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OKButton", @"") otherButtonTitles:nil];
                    [alert show];
                }
                self.shareView.selectedState = VShareViewSelectedStateNotSelected;
            }];
        }
    }
    else
    {
        self.shareView.selectedState = VShareViewSelectedStateNotSelected;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVShareToFacebookDisabledKey];
    }
}

@end
