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

/**
 Reports on ad playback events
 */
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


/**
 *  The designated constructor for VAdVideoPlayerViewController taking a partner and a details specification.
 *
 *  @param monetizationPartner Enum value for which of the ad networks to use.
 *  @param details             Array of options and parameters for the ad.
 *
 *  @return Returns an instance of the VAdVideoPlayerViewController class.
 */
- (id)initWithMonetizationPartner:(VMonetizationPartner)monetizationPartner details:(NSArray *)details NS_DESIGNATED_INITIALIZER;

/**
 Boolean that reports if an ad is currently playing
 */
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
 Method that starts the ad manager
 */
- (void)start;

@end
