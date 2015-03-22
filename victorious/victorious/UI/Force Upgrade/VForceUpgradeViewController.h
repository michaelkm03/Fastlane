//
//  VForceUpgradeViewController.h
//  victorious
//
//  Created by Josh Hinman on 6/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VForceUpgradeViewController : UIViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
