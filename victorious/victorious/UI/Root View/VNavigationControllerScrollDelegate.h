//
//  VNavigationControllerScrollDelegate.h
//  victorious
//
//  Created by Josh Hinman on 2/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VNavigationController;

/**
 An implementation of UIScrollViewDelegate that hides the navigation bar on scroll.
 If you can't replace your scroll view delegate (because you have another object
 that needs to be the delegate for other reasons), make sure you forward all the
 UIScrollViewDelegate messages that appear in this header file.
 */
@interface VNavigationControllerScrollDelegate : NSObject <UIScrollViewDelegate>

@property (nonatomic, weak, readonly) VNavigationController *navigationController; ///< The navigation controller that was passed into the -init method

/**
 Initializes a new instance of this class
 
 @param navigationController The navigation controller whose navigation bar we are hiding/showing
 */
- (instancetype)initWithNavigationController:(VNavigationController *)navigationController NS_DESIGNATED_INITIALIZER;

// SCROLL VIEW DELEGATE METHODS - please forward these manually if this object is not set as your scroll view delegate //////////////////

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset; ///< This method promises not to modify targetContentOffset. If you would like to modify it, do so before calling this method.

@end
