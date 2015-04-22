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
 Protoocl for an implementaiton of a controller object that controls the initialization,
 apparance, scroll position tracking and animation associated with floating navigation views.
 The floating view itself is provided from calling code and is designed to be a subview of
 a navigation controller which allows the child view to overlap onto the navigation view
 controller's top view controller.  Implementors can selectivelty hide or show the child view
 with animation based on scroll position of some arbitary scroll view in context of calling code.
 */
@protocol VNavigationViewFloatingController <NSObject>

/**
 To drive the animated apperance and disappearance, call this from a scroll view delegate's
 `scrollViewDidScroll:` method, supplyin the current content offset of the scroll view.
 */
- (void)updateContentOffsetOnScroll:(CGPoint)contentOffset;

/**
 The threshold used to determine if floating child view should be visible or not.
 */
@property (nonatomic, assign) CGFloat verticalScrollThreshold;

@property (nonatomic, weak) id<VNavigationViewFloatingControllerDelegate> delegate;

@end