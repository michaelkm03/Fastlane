//
//  VWebBrowserHeaderLayoutManager.h
//  victorious
//
//  Created by Patrick Lynch on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VWebBrowserLayout.h"

@class VWebBrowserHeaderViewController;

/**
 An object that manages the layout of the web browser header according to some
 key properties that determine the layout and some behavior of the header's contents.
 */
@interface VWebBrowserHeaderLayoutManager : NSObject

/**
 Property that determines the progress bar alignment of the header.
 
 @see VWebBrowserHeaderContentAlignment
 */
@property (nonatomic, assign) VWebBrowserHeaderProgressBarAlignment progressBarAlignment;

/**
 Property that determines the content alignment for the header.
 
 @see VWebBrowserHeaderContentAlignment
 */
@property (nonatomic, assign) VWebBrowserHeaderContentAlignment contentAlignment;

/**
 Whether or not the exit button should be visible.
 */
@property (nonatomic, assign) BOOL exitButtonVisible;

/**
 Reference to the header component configured in interface builder, necessary
 for applying layout changes.
 */
@property (nonatomic, weak, readonly) IBOutlet VWebBrowserHeaderViewController *header;

/**
 Re-apply any layout changes to ensure that the layout is up to date for
 the current state of the header.  This is also called internally during initialization
 and by `updateAnimated:`.
 */
- (void)update;

/**
 Perform same functionality as in `update` method, but animate any changes that
 can be animated.
 */
- (void)updateAnimated:(BOOL)animated;

@end
