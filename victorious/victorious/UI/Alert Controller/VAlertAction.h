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
 Abstraction of a button and associated action as would appear on an action sheet
 or alart view.  When used with VAlertViewController, this classes provides action sheet
 and alert view functionality indepedent of which version of iOS is running on the device.
 */
@interface VAlertAction : NSObject

/**
 Title of the button to represent this action in either alert view or action sheet.
 */
@property (nonatomic, readonly) NSString *title;

/**
 Style of the button in action sheet or alert view.
 */
@property (nonatomic, readonly, assign) NSInteger style;

/**
 Block to call when this action has been selected by the user.
 */
@property (nonatomic, readonly, strong) void (^handler)(VAlertAction *);

/**
 Call the hanlder block of this method if it exists.
 */
- (void)execute;

@end