//
//  VWebBrowserHeaderState.h
//  victorious
//
//  Created by Patrick Lynch on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class VWebBrowserHeaderViewController;

static const NSTimeInterval kLayoutChangeAnimationDuration  = 0.5f;
static const CGFloat kLayoutChangeAnimationSpringDampening  = 0.8f;
static const CGFloat kLayoutChangeAnimationSpringVelocity   = 0.1f;

static const CGFloat kDefaultLeadingSpace                   = 8.0f;

@interface VWebBrowserHeaderState : NSObject

@property (nonatomic, weak) VWebBrowserHeaderViewController *webBrowserHeader;

- (void)update;

@end