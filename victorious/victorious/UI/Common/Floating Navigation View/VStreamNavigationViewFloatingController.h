//
//  VStreamNavigationViewFloatingController.h
//  victorious
//
//  Created by Patrick Lynch on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VNavigationViewFloatingController.h"

@interface VStreamNavigationViewFloatingController : NSObject <VNavigationViewFloatingController>

/**
 Designated initialized that takes required parameters.
 */
- (instancetype)initWithFloatingView:(UIView *)floatingView
        floatingParentViewController:(UIViewController *)floatingParentViewController
             verticalScrollThreshold:(CGFloat)verticalScrollThreshold NS_DESIGNATED_INITIALIZER;

@end
