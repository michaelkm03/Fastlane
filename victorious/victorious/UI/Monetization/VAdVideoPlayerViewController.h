//
//  VAdVideoPlayerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVideoCellViewModel.h"

@class VAdVideoPlayerViewController;

@protocol VAdVideoPlayerViewControllerDelegate <NSObject>

@required

- (void)adDidLoadForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adDidFinishForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;

@optional

- (void)adDidStartPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adDidStopPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adHadImpressionForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adHadErrorForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;

@end


@interface VAdVideoPlayerViewController : UIViewController

@property (nonatomic, readonly) BOOL adPlaying; ///< YES if ad video is playing

/**
 Ad video player delegate object
 */
@property (nonatomic, weak) id<VAdVideoPlayerViewControllerDelegate>delegate;

/**
 Enum value to check which ad manager to load
 */
@property (nonatomic, assign) VMonetizationPartner monetizationPartner;

/**
 Sets the monetization type and options for the Ad Video Player
 
 @param monetizationPartner enum value for which ad network to use
 @param options             Dictionary of keys/values for setting ad display options and parameters
 */
- (void)assignMonetizationPartner:(VMonetizationPartner)monetizationPartner withDetails:(NSArray *)details;

/**
 Method tha starts the ad manager
 */
- (void)start;

@end
