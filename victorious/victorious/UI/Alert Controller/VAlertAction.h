//
//  VAlertAction.h
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Abstract way to configure button styles on alert view or action sheet.
 */
typedef NS_ENUM(NSInteger, VAlertActionStyle)
{
    VAlertActionStyleDefault,
    VAlertActionStyleDestructive,
    VAlertActionStyleCancel
};

/**
 An abstraction of a button and associated action as it would appear on an action sheet
 or alert view.  When used with VAlertViewController, this class provides action sheet
 and alert view functionality indepedent of which version of iOS is running on the device.
 */
@interface VAlertAction : NSObject

- (instancetype)initWithTitle:(NSString *)title style:(VAlertActionStyle)style handler:(void(^)(VAlertAction *))handler;

/**
 Title of the button to represent this action in either alert view or action sheet.
 */
@property (nonatomic, readonly) NSString *title;

/**
 Style of the button in action sheet or alert view.
 */
@property (nonatomic, readonly, assign) NSInteger style;

/**
 Whether the button is enabled to the user when presented.
 Default is YES.
 */
@property (nonatomic, assign) BOOL enabled;

/**
 Block to call when this action has been selected by the user.
 */
@property (nonatomic, readonly, strong) void (^handler)(VAlertAction *);

/**
 Call the hanlder block of this method if it exists.
 */
- (void)execute;

@end