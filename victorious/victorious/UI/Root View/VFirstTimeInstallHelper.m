//
//  VFirstTimeInstallHelper.m
//  victorious
//
//  Created by Lawrence Leach on 3/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFirstTimeInstallHelper.h"
#import "VSequence+Fetcher.h"
#import "VObjectManager+Sequence.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VDependencyManager.h"

static NSString * const VDidPlayFirstTimeUserVideo = @"com.getvictorious.settings.didPlayFirstTimeUserVideo";

@implementation VFirstTimeInstallHelper

#pragma mark - Accessors

- (BOOL)hasBeenShown
{
#warning uncomment this
//    return [[[NSUserDefaults standardUserDefaults] valueForKey:VDidPlayFirstTimeUserVideo] boolValue];
    return NO;
}

#pragma mark - Save to NSUserDefaults

- (void)savePlaybackDefaults
{
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VDidPlayFirstTimeUserVideo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
