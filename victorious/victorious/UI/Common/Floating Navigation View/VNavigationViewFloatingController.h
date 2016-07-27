//
//  VNavigationViewFloatingController.h
//  victorious
//
//  Created by Patrick Lynch on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VNavigationViewFloatingControllerDelegate

- (void)floatingViewSelected:(UIView *)floatingView;

@end

/**
 Protocol for an implementation of a controller object that controls the initialization,
 appearance, scroll position tracking and animation associated with floating navigation views.
 The floating view itself is provided from calling code and is designed to be a subview of
 a navigation controller which allows the child view to overlap onto the navigation view
 controller's top view controller.  Implementors can selectively hide or show the child view
 with animation based on scroll position of some arbitary scroll view in context of calling code.
 */
@protocol VNavigationViewFloatingController <NSObject>

/**
 To drive the animated apperance and disappearance, call this from a scroll view delegate's
 `scrollViewDidScroll:` method, supplying the current content offset of the scroll view.
 */
- (void)updateContentOffsetOnScroll:(CGPoint)contentOffset;

/**
 Animation should be enabled and disabled as the parent navigation controller appears
 or disappears.  Disabling animation also works as a clean up function by disabling
 any animation mechanisms that may cause retain cycles, such as timers or display links.
 */
@property (nonatomic, assign) BOOL animationEnabled;

@property (nonatomic, weak) id<VNavigationViewFloatingControllerDelegate> delegate;

@end
