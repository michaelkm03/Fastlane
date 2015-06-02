//
//  VWorkspacePresenter.h
//  victorious
//
//  Created by Michael Sena on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VWorkspacePresenter : NSObject

+ (instancetype)workspacePresenterWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn dependencyManager:(VDependencyManager *)dependencyManager;

- (void)present;

@end
