//
//  VAdViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "AdLifecycleDelegate.h"

@protocol VAdViewControllerType <NSObject>

/**
 UIView used for ad video playback
 */
@property (nonatomic, strong, readonly, nonnull) UIView *adView;

/**
 Ad video player delegate object
 */
@property (nonatomic, weak, nullable) id<AdLifecycleDelegate> delegate;

/**
 Starts the ad manager
 */
- (void)startAdManager;

@end
