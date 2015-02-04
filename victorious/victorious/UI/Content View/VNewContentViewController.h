//
//  VNewContentViewController.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VContentViewViewModel.h"

@class VDependencyManager, VSequenceActionController, VNewContentViewController;

@protocol VNewContentViewControllerDelegate  <NSObject>

/**
 *  When NCV has called this delegate method it has already begun destroying it's internal view hierarchy. It should be dismissed at this point.
 */
- (void)newContentViewControllerDidClose:(VNewContentViewController *)contentViewController;

/**
 *  NCV has issues an API request to delete itself and is giving the delegate a chance to reload it's list of items.
 */
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
+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel
                                                dependencyManager:(VDependencyManager *)dependencyManager;

- (void)disableEndcardAutoplay;

/**
 *  The viewModel that was passed in to the content viewController's factory method.
 */
@property (nonatomic, strong, readonly) VContentViewViewModel *viewModel;

@property (nonatomic, strong) UIImage *placeholderImage;

/**
 *  Need a reference to this for determining whether or not to show the histogram.
 */
@property (nonatomic, weak) VDependencyManager *dependencyManagerForHistogramExperiment;

@property (nonatomic, strong, readonly) VSequenceActionController *sequenceActionController;

@end
