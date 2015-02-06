//
//  VCameraRollPublishShareController.m
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCameraRollPublishShareController.h"
#import "VThemeManager.h"

@import AssetsLibrary;

static NSString * const kVSaveToCameraRollLastStateKey = @"saveToCameraKey";

@implementation VCameraRollPublishShareController

- (void)configureInitialState
{
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    BOOL accessGiven = !((authorizationStatus == ALAuthorizationStatusDenied) || (authorizationStatus == ALAuthorizationStatusRestricted));
    
    if (!accessGiven)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO
                                                forKey:kVSaveToCameraRollLastStateKey];
    }
    BOOL lastState = [[NSUserDefaults standardUserDefaults] boolForKey:kVSaveToCameraRollLastStateKey];
    self.switchToConfigure.on = lastState;
}

- (void)setSwitchToConfigure:(UISwitch *)switchToConfigure
{
    [super setSwitchToConfigure:switchToConfigure];
    [self configureInitialState];
}

- (void)shareButtonTapped
{
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    if (authorizationStatus == ALAuthorizationStatusDenied || authorizationStatus == ALAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CameraRollDeniedTitle", nil)
                                                        message:NSLocalizedString(@"CameraRollDenied", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil, nil];
        [alert show];
        [self.switchToConfigure setOn:NO
                             animated:YES];
    }
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         *stop = YES;
     }
                               failureBlock:^(NSError *error)
     {
         [self.switchToConfigure setOn:NO
                              animated:YES];
     }];
    [[NSUserDefaults standardUserDefaults] setBool:self.switchToConfigure.on
                                            forKey:kVSaveToCameraRollLastStateKey];
}

@end
