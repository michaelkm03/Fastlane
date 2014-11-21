//
//  VAlertController.h
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VAlertAction.h"

/**
 Abstract way to select action sheet or alert view indedepent of iOS version.
 */
typedef NS_ENUM(NSInteger, VAlertControllerStyle)
{
    VAlertControllerStyleActionSheet,
    VAlertControllerStyleAlert
};

/*
 An abstraction of alert views and action sheets for iOS 7 and iOS 8.
 Appropriate classes for the current device OS are selected, configured and
 managed internally to support both versions and simplify use.
 */
@interface VAlertController : NSObject

/**
 Returns whether UIAlertController (iOS 8.0+) is supported on the current device.
 */
+ (BOOL)canUseAlertController;

/**
 Use this method to create the appropriate alert controller for the current OS.
 */
+ (VAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style;

/**
 Add actions to the alert controller.
 Will map to the appropriate methods of UIAlertView, UIActionSheet or UIAlertController.
 */
- (void)addAction:(VAlertAction *)action;

/**
 Present or show the alert or action sheet.
 Will present with appropriate methods of of UIAlertView, UIActionSheet or UIAlertController.
 */
- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

/*
 Title of the alert view or action sheet.
 */
@property (nonatomic, readonly) NSString *title;

/*
 Title of the alert view (does not apply to action sheet).
 */
@property (nonatomic, readonly) NSString *message;

/*
 Returns whether the alert controller has been created as an action sheet or alert;
 */
@property (nonatomic, readonly, assign) VAlertControllerStyle style;

@end