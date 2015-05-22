//
//  VStandardLoginFlowViewController.h
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAuthorizationContext.h"

@class VObjectManager, VDependencyManager;

@interface VStandardLoginFlowViewController : UINavigationController

- (instancetype)initWithAuthorizationContext:(VAuthorizationContext)authorizationContext
                               ObjectManager:(VObjectManager *)objectManager
                           dependencyManager:(VDependencyManager *)dependencyManager
                                  completion:(void(^)(BOOL authorized))completionActionBlock;;

@end
