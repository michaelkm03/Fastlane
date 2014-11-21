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
 managed internally through subclasses to support both versions and simplify use.
 */
@interface VAlertController : NSObject

/**
 Returns whether UIAlertController (iOS 8.0+) is supported on the current device.
 */
+ (BOOL)canUseAlertController;

/**
 Desginated method for creating action sheets or alert views appropriate for the device OS version.
 Don't use initWithTitle:message:style: unless you know what you're doing.
 */
+ (VAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style;

/**
 Add actions to the alert controller.  Will map to the appropriate methods of UIAlertView, UIActionSheet or UIAlertController.
 
 @discussion Internally, subclasses are generated new system action sheets and alert views each time
 the presentInViewControler:animated:completion: method is called.  The actions, title, message
 and other data persists as part of the VAlertController instance, allowing multiple system
 action sheets or alert views to be generated from it.
 */
- (void)addAction:(VAlertAction *)action;

/**
 Removes any added actions, allowing the VAlertController instance to be reused with
 any new actions that are subequently added.
 
 @see addAction: method for information about using and reusing VAlertController instances.
 */
- (void)removeAllActions;

/**
 Present or show the alert or action sheet.  Will present with appropriate methods
 of UIAlertView, UIActionSheet or UIAlertController.
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

/**
 Sets the tint color of the alert view or actionsheet
 */
@property (nonatomic, strong) UIColor *tintColor;

@end