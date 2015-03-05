//
//  VEndCardBannerViewController.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VCountdownViewController.h"

@class VEndCardModel, VDependencyManager;

@protocol VEndCardBannerViewControllerDelegate <NSObject>

- (void)nextVideoSelectedWithAutoPlay:(BOOL)autoPlay;

@end

/**
 A subview of `VEndCardViewController` that displays info about the next video
 in the stream or playlist.
 */
@interface VEndCardBannerViewController : UIViewController

@property (nonatomic, weak) id<VEndCardBannerViewControllerDelegate> delegate;

/**
 Used to configure subviews with values assigned to properties of `VEndCardModel`.
 */
- (void)configureWithModel:(VEndCardModel *)model;

/**
 Used to configure subviews with values provided by a `VDependencyManager` instance.
 */
- (void)configureWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Play the countdown animation starting at the specified duration,
 after which the `nextVideoSelected` method of `VEndCardBannerViewControllerDelegate`
 will be called.
*/
- (void)startCountdownWithDuration:(NSUInteger)duration;

/**
 Stop the countdown to the next video and fade out the countdown view.
 */
- (void)stopCountdown;

/**
 Clear out any values populated to views, essentially returning
 this view controller to its default, unconfigured state.
 */
- (void)resetNextVideoDetails;

/**
 Transition in with animation.
 */
- (void)showNextVideoDetails;

@end
