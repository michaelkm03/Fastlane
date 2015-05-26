//
//  VLoginViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAuthorizationProvider.h"
#import "VTransitionDelegate.h"
#import "VPresentWithBlurTransition.h"
#import "VAuthorizationContextHelper.h"
#import "VLoginType.h"

@class VDependencyManager;

@interface VLoginViewController : UIViewController <VAuthorizationProvider, VPresentWithBlurViewController>

+ (VLoginViewController *)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) VTransitionDelegate *transitionDelegate;

/**
 VPresentWithBlurViewController
 */
@property (nonatomic, strong) UIView *blurredBackgroundView;

/**
 VPresentWithBlurViewController
 */
@property (nonatomic, strong) NSOrderedSet *stackedElements;

@property (nonatomic, assign) VAuthorizationContext authorizationContextType;

@end
