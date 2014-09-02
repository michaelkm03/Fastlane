//
//  VTwitterPublishShareController.m
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPublishShareView.h"
#import "VTwitterManager.h"
#import "VTwitterPublishShareController.h"

static NSString * const kVShareToTwitterDisabledKey = @"shareToTwtrKey";

@implementation VTwitterPublishShareController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.shareView.title = NSLocalizedString(@"twitter", nil);
        self.shareView.image = [UIImage imageNamed:@"share-btn-twitter"];
        self.shareView.selectedColor = [UIColor colorWithRed:0.1f green:0.7f blue:0.91f alpha:1.0f];
        [self configureInitialState];
    }
    return self;
}

- (void)configureInitialState
{
    BOOL disabled = [[NSUserDefaults standardUserDefaults] boolForKey:kVShareToTwitterDisabledKey];
    if (!disabled && [[VTwitterManager sharedManager] isLoggedIn])
    {
        self.shareView.selectedState = VShareViewSelectedStateSelected;
    }
}

- (void)shareButtonTapped
{
    if (self.shareView.selectedState == VShareViewSelectedStateNotSelected)
    {
        if ([[VTwitterManager sharedManager] isLoggedIn])
        {
            self.shareView.selectedState = VShareViewSelectedStateSelected;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kVShareToTwitterDisabledKey];
        }
        else
        {
            self.shareView.selectedState = VShareViewSelectedStateLimbo;
            [[VTwitterManager sharedManager] refreshTwitterTokenWithIdentifier:nil
                                                               completionBlock:^(void)
            {
                if ([[VTwitterManager sharedManager] isLoggedIn])
                {
                    self.shareView.selectedState = VShareViewSelectedStateSelected;
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kVShareToTwitterDisabledKey];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TwitterDeniedTitle", nil)
                                                                    message:NSLocalizedString(@"TwitterDenied", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil, nil];
                    [alert show];
                    self.shareView.selectedState = VShareViewSelectedStateNotSelected;
                }
            }];
        }
    }
    else
    {
        self.shareView.selectedState = VShareViewSelectedStateNotSelected;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVShareToTwitterDisabledKey];
    }
}

@end
