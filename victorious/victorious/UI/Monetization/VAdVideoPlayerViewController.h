//
//  VAdVideoPlayerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVideoPlayer.h"
#import "VAdViewControllerType.h"
#import "AdLifecycleDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class VAdVideoPlayerViewController;

@interface VAdVideoPlayerViewController : UIViewController


/**
 *  The designated constructor for VAdVideoPlayerViewController
 *
 *  @param adViewController a concrete implementation of a view controller provider class.
 *
 *  @return Returns an instance of the VAdVideoPlayerViewController class.
 */
- (instancetype)initWithAdViewController:(id<VAdViewControllerType>)adViewController NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 Ad video player delegate object
 */
@property (nonatomic, weak, nullable) id<AdLifecycleDelegate>delegate;

/**
 ViewController instance that deals with an add provider
 */
@property (nonatomic, readwrite, nonnull) id<VAdViewControllerType>adViewController;

/**
 Method that starts the ad manager
 */
- (void)start;

@end

NS_ASSUME_NONNULL_END
