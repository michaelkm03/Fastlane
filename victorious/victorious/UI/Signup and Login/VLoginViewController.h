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

typedef NS_ENUM(NSUInteger, VLoginType)
{
    kVLoginTypeNone,
    kVLoginTypeEmail,
    kVLoginTypeFaceBook,
    kVLoginTypeTwitter,
};

@interface VLoginViewController : UIViewController <VAuthorizationViewController, VPresentWithBlurViewController>

@property (nonatomic, strong) void (^authorizationCompletionAction)();

@property (nonatomic, strong) VTransitionDelegate *transitionDelegate;

+ (VLoginViewController *)loginViewController;

/**
 VPresentWithBlurViewController
 */
@property (nonatomic, strong) UIView *blurredBackgroundView;

/**
 VPresentWithBlurViewController
 */
@property (nonatomic, strong) IBOutlet UIView *contentContainer;

/**
 VPresentWithBlurViewController
 */
@property (nonatomic, strong) NSOrderedSet *stackedElements;

@end
