//
//  VNewContentViewController.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VContentViewViewModel.h"

@class VNewContentViewController;

@protocol VNewContentViewControllerDelegate  <NSObject>

- (void)newContentViewControllerDidClose:(VNewContentViewController *)contentViewController;
- (void)newContentViewControllerDidDeleteContent:(VNewContentViewController *)contentViewController;

@end

/**
 *  The content view controller.
 */
@interface VNewContentViewController : UIViewController

/**
 *  VNewContentViewController informs its delegate when it is ready to be dismissed or performed a deletion action.
 */
@property (nonatomic, weak) id <VNewContentViewControllerDelegate> delegate;

/**
 *  Designated factory method for the content viewcontroller.
 *
 *  @param viewModel The viewmodel to use for representation fo the contentViewController.
 *
 *  @return An initialized content view controller.
 */
+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel;

/**
 *  The viewModel that was passed in to the content viewController's factory method.
 */
@property (nonatomic, strong, readonly) VContentViewViewModel *viewModel;

@property (nonatomic, strong) UIImage *placeholderImage;

@end
