//
//  VLightboxViewController.h
//  victorious
//
//  Created by Josh Hinman on 5/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Displays a view with a lightbox effect on top of a
 background view, which is usually a snapshot of 
 the presenting view. This is a base class--you
 probably want to use one of its subclasses,
 either VVideoLightboxViewController or
 VImageLightboxViewController
 */
@interface VLightboxViewController : UIViewController

@property (nonatomic, copy) void (^onCloseButtonTapped)(void);

/**
 This is the background view that is displayed behind the contentView.
 */
@property (nonatomic, weak, readonly) UIView *backgroundView;

/**
 Subviews should add their content view as a subview of this view.
 */
@property (nonatomic, weak, readonly) UIView *contentSuperview;

/**
 The content being lightboxed. Subclasses need to provide 
 the implementation for this property, and it should 
 return a view that is a subclass of contentSuperview.
 */
@property (nonatomic, readonly) UIView *contentView;

@end
