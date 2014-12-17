//
//  VViewSelectorViewControllerBase.h
//  victorious
//
//  Created by Josh Hinman on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#include "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

@class VViewSelectorViewControllerBase;

@protocol VViewSelectorViewControllerDelegate <NSObject>

@optional

/**
 Notifies the delegate that a view controller has been selected.
 This should not be called when the view controller is changed
 by programatically setting the activeViewControllerIndex 
 property.
 
 @param index The index of the selected view controller in the sender's viewControllers array
 */
- (void)viewSelector:(VViewSelectorViewControllerBase *)viewSelector didSelectViewControllerAtIndex:(NSUInteger)index;

@end

/**
 Base class for a view controller that offers the user a
 chance to select from multiple views (e.g. a tab bar)
 */
@interface VViewSelectorViewControllerBase : UIViewController <VHasManagedDependancies>

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, weak) id<VViewSelectorViewControllerDelegate> delegate; ///< A delegate object to be notified when the selection changes
@property (nonatomic, copy) NSArray /* UIViewController */ *viewControllers; ///< The views from which we are selecting
@property (nonatomic) NSUInteger activeViewControllerIndex; ///< The index of the currently selected view controller in the viewControllers array

@end
