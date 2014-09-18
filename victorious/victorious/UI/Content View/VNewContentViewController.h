//
//  VNewContentViewController.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VContentViewViewModel.h"

/**
 *  The content view controller.
 */
@interface VNewContentViewController : UIViewController

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

@end
