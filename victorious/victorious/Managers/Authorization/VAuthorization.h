//
//  VAuthorization.h
//  victorious
//
//  Created by Patrick Lynch on 3/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAuthorizationViewController.h"

@class VObjectManager;

@interface VAuthorization : NSObject

@property (nonatomic, weak) VObjectManager *objectManager;

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager;

- (void)performAuthorizedAction:(void(^)())actionBlock failure:(void(^)(UIViewController<VAuthorizationViewController> *viewController))failureBlock;

@end
