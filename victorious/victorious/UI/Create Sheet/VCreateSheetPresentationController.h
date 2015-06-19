//
//  VCreateSheetPresentationController.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@interface VCreateSheetPresentationController : UIPresentationController <VHasManagedDependencies>

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
                                         source:(UIViewController *)source;

@end
