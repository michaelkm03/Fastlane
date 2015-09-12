//
//  VRootViewController+UIAutomation.h
//  victorious
//
//  Created by Michael Sena on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRootViewController.h"

@class VLoadingViewController;

@interface VRootViewController (UIAutomation)

@property (nonatomic, readonly) VLoadingViewController *__nullable loadingViewController;

@end
