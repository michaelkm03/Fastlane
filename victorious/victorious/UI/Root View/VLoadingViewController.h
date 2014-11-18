//
//  VLoadingViewController.h
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VLoadingViewController;

@protocol VLoadingViewControllerDelegate <NSObject>

@optional

/**
 Notifies the delegate that the init call has completed
 */
- (void)loadingViewController:(VLoadingViewController *)loadingViewController didFinishLoadingWithInitResponse:(NSDictionary *)initResponse;

@end

@interface VLoadingViewController : UIViewController

@property (nonatomic, weak) id<VLoadingViewControllerDelegate> delegate;

+ (VLoadingViewController *)loadingViewController; ///< Instantiates VLoadingViewController from the storyboard

@end
