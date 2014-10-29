//
//  UIViewController+VNavMenu.h
//  victorious
//
//  Created by Will Long on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VNavigationHeaderView.h"
#import "VUploadProgressViewController.h"

@interface UIViewController (VNavMenu)

/**
 *  The navHeaderView that is added when calling the addNewNavHeaderWithTitles: method
 */
@property (nonatomic, strong) VNavigationHeaderView *navHeaderView;

/**
 *  Adds a new nav menu to the View Controller. The nav header uses self.title to popualte the main title.  If you set the title after calling this method, you can modify self.navHeaderView directly
 *
 *  @param titles An array of NSStrings used to populate the headers nav selector.
 */
- (void)addNewNavHeaderWithTitles:(NSArray *)titles;

/**
 *  Animates the header off screen.  Must be called in an animation block to animate.
 */
- (void)hideHeader;

/**
 *  Animates the header on sceen.  Must be called in an animation block to animate.
 */
- (void)showHeader;

/**
 *  Adds a create new sequence button to the nav menu
 */
- (void)addCreateSequenceButton;

/**
 *  The upload progress view controller that is added after addUploadProgressView
 */
@property (nonatomic, strong) VUploadProgressViewController *uploadProgressViewController;

/**
 *  Creates a new uploadProgressViewController, and adds the view to self.view with the proper constraints to the header.
 */
- (void)addUploadProgressView;

/**
 *  Shows the upload progress view
 */
- (void)showUploads;

/**
 *  Hides the upload progress view.
 */
- (void)hideUploads;

@end
