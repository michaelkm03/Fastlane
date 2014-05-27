//
//  VLightboxTransitioningDelegate.h
//  victorious
//
//  Created by Josh Hinman on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLightboxViewController;

/**
 Use an instance of this class as your transitioning delegate when displaying
 VLightboxViewController, and you'll get a nice zooming effect
 */
@interface VLightboxTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak, readonly) UIView *referenceView;

/**
 Creates an instance of the receiver and associates it with a VLightboxViewController instance.
 
 @param lightboxController The VLightboxViewController instance that will be presented
 @param referenceView      The lightbox view will appear to "grow" and "shrink" from this view's frame
 */
+ (instancetype)addNewTransitioningDelegateToLightboxController:(VLightboxViewController *)lightboxController referenceView:(UIView *)referenceView;

/**
 Create an instance of the lightbox transitioning delegate
 
 @param referenceView The lightbox view will appear to "grow" and "shrink" from this view's frame
 */
- (instancetype)initWithReferenceView:(UIView *)referenceView;

@end
