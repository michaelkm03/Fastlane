//
//  VAlertController.h
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VAlertAction.h"

typedef NS_ENUM(NSInteger, VAlertControllerStyle)
{
    VAlertControllerStyleActionSheet,
    VAlertControllerStyleAlert
};

@interface VAlertController : NSObject

+ (VAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style;

- (void)addAction:(VAlertAction *)action;

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

@end