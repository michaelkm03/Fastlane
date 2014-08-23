//
//  VCameraRollPublishShareController.m
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCameraRollPublishShareController.h"
#import "VPublishShareView.h"
#import "VThemeManager.h"

@import AssetsLibrary;

static NSString * const kVSaveToCameraRollDisabledKey = @"saveToCameraKey";

@implementation VCameraRollPublishShareController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.shareView.title = NSLocalizedString(@"saveToLibrary", nil);
        self.shareView.image = [UIImage imageNamed:@"share-btn-library"];
        self.shareView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        [self configureInitialState];
    }
    return self;
}

- (void)configureInitialState
{
    BOOL disabled = [[NSUserDefaults standardUserDefaults] boolForKey:kVSaveToCameraRollDisabledKey];
    if (!disabled && [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized)
    {
        self.shareView.selectedState = VShareViewSelectedStateSelected;
    }
}

- (void)shareButtonTapped
{
    if (self.shareView.selectedState == VShareViewSelectedStateNotSelected)
    {
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        if (authorizationStatus == ALAuthorizationStatusDenied || authorizationStatus == ALAuthorizationStatusRestricted)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CameraRollDeniedTitle", nil)
                                                            message:NSLocalizedString(@"CameraRollDenied", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
        else if (authorizationStatus == ALAuthorizationStatusAuthorized)
        {
            self.shareView.selectedState = VShareViewSelectedStateSelected;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kVSaveToCameraRollDisabledKey];
        }
        
        self.shareView.selectedState = VShareViewSelectedStateLimbo;

        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                     usingBlock:^(ALAssetsGroup *group, BOOL *stop)
        {
            self.shareView.selectedState = VShareViewSelectedStateSelected;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kVSaveToCameraRollDisabledKey];
            *stop = YES;
        }
                                   failureBlock:^(NSError *error)
        {
            self.shareView.selectedState = VShareViewSelectedStateNotSelected;
        }];
    }
    else
    {
        self.shareView.selectedState = VShareViewSelectedStateNotSelected;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVSaveToCameraRollDisabledKey];
    }
}

@end
