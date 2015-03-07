//
//  VLoginViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAuthorizationViewController.h"
#import "VTransitionDelegate.h"
#import "VPresentWithBlurTransition.h"
#import "VLoginContextHelper.h"

typedef NS_ENUM(NSUInteger, VLoginType)
{
    kVLoginTypeNone,
    kVLoginTypeEmail,
    kVLoginTypeFaceBook,
    kVLoginTypeTwitter,
};

@class VDependencyManager;

@interface VLoginViewController : UIViewController <VAuthorizationViewController, VPresentWithBlurViewController>

+ (VLoginViewController *)loginViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) VTransitionDelegate *transitionDelegate;

/**
 VPresentWithBlurViewController
 */
@property (nonatomic, strong) UIView *blurredBackgroundView;

/**
 VPresentWithBlurViewController
 */
@property (nonatomic, strong) NSOrderedSet *stackedElements;

@property (nonatomic, assign) VLoginContextType loginContextType;

@end
