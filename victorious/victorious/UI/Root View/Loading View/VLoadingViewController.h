//
//  VLoadingViewController.h
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager, VLoadingViewController;

@protocol VLoadingViewControllerDelegate <NSObject>

@optional

/**
 Notifies the delegate that the init call has completed
 */
- (void)loadingViewController:(VLoadingViewController *)loadingViewController didFinishLoadingWithDependencyManager:(VDependencyManager *)dependencyManager;

@end

@interface VLoadingViewController : UIViewController

@property (nonatomic, weak) id<VLoadingViewControllerDelegate> delegate;
@property (nonatomic, strong) VDependencyManager *parentDependencyManager; ///< This VDependencyManager instance will be the parent of the one returned from the server

+ (VLoadingViewController *)loadingViewController; ///< Instantiates VLoadingViewController from the storyboard

@end