//
//  VAuthorization.h
//  victorious
//
//  Created by Patrick Lynch on 3/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAuthorizationViewController.h"
#import "VLoginContextHelper.h"

@class VObjectManager, VDependencyManager;

@interface VAuthorization : NSObject

@property (nonatomic, weak) VObjectManager *objectManager;

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
                    dependencyManager:(VDependencyManager *)dependencyManager;

- (BOOL)performAuthorizedActionFromViewController:(UIViewController *)presentingViewController
                                      withContext:(VLoginContextType)loginContext
                                      withSuccess:(void(^)())successActionBlock;

@end
