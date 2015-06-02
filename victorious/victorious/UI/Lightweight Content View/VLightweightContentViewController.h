//
//  VLightweightContentViewController.h
//  victorious
//
//  Created by Lawrence Leach on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VLightweightContentViewController;

@protocol VLightweightContentViewControllerDelegate <NSObject>

@optional

/**
 Notifies the delegate that the video has started
 */
- (void)videoHasStartedInLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController;

/**
 Notifies the delegate that the video has completed.
 */
- (void)videoHasCompletedInLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController;

/**
 Notifies the delegate that the sequence failed to load from the server
 */
- (void)failedToLoadSequenceInLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController;

/**
 Notifies the delegate that the user wants to dismiss the view controller
 */
- (void)userWantsToDismissLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController;

@end

@interface VLightweightContentViewController : UIViewController

/**
 Reports when the video has completed or failed to load
 */
@property (nonatomic, weak) id <VLightweightContentViewControllerDelegate> delegate;

@end
