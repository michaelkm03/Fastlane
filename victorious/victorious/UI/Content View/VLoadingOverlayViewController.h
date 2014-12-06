//
//  VLoadingOverlayViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

@interface VLoadingOverlayViewController : UIViewController

+ (VLoadingOverlayViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

/**
 Adds itself as a subview and sets up auto layout constraints.
 */
- (void)configureForUseInViewController:(UIViewController *)viewController;

- (void)showWithText:(NSString *)text animated:(BOOL)animated;

- (void)hideAnimated:(BOOL)animated;

@end
